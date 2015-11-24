/*
* Copyright 2015 Amazon.com, Inc. or its affiliates. All Rights Reserved.
*
* Licensed under the Apache License, Version 2.0 (the "License").
* You may not use this file except in compliance with the License.
* A copy of the License is located at
*
*  http://aws.amazon.com/apache2.0
*
* or in the "license" file accompanying this file. This file is distributed
* on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either
* express or implied. See the License for the specific language governing
* permissions and limitations under the License.
*/

import UIKit
import AWSCore
import AWSCognito

class CognitoDatasetViewController: UITableViewController {
    
    let numDefaultRecords = 20
    
    var dataset: AWSCognitoDataset?
    var identityId: String?
    var objects: [AWSCognitoRecord] = []
    var selectedRecord: String?
    
    
    func getRecords() {
        if let temp = self.dataset?.getAllRecords() as? [AWSCognitoRecord] {
            self.objects = []
            
            self.objects = temp.filter {
                return $0.dirty || ($0.data.string() != nil && $0.data.string().characters.count != 0)
            };
        }
    }

    // MARK: Button Handlers
    
    @IBOutlet weak var subscribeSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem = self.editButtonItem()
        let userDefaults = NSUserDefaults.standardUserDefaults()
        self.subscribeSwitch.setOn("Subscribed" == userDefaults.stringForKey(self.dataset!.name), animated: false)
        self.refreshClicked(nil)
    }

    
    @IBAction func subscribeClicked(sender: AnyObject) {
        if (sender as! UISwitch).on {
            self.dataset?.subscribe().continueWithBlock {
                (task) -> AnyObject! in
                if task.error == nil {
                    self.subscribeSwitch.setOn(false, animated: true)
                    dispatch_async(dispatch_get_main_queue()) {
                        self.errorAlert("Unable to subscribe to dataset: " + task.error.description)
                    }
                } else {
                    let userDefaults = NSUserDefaults.standardUserDefaults()
                    if let datasetName = self.dataset?.name {
                        userDefaults.setObject("Subscribed", forKey: datasetName)
                        userDefaults.synchronize()
                    }
                }
                return nil
            }
        } else {
            self.dataset?.unsubscribe() .continueWithBlock { (task) -> AnyObject! in
                if task.error == nil {
                    self.subscribeSwitch.setOn(false, animated: false)
                    dispatch_async(dispatch_get_main_queue()) {
                        self.errorAlert("Unable to subscribe to dataset: " + task.error.description)
                    }
                } else {
                    let userDefaults = NSUserDefaults.standardUserDefaults()
                    if let datasetName = self.dataset?.name {
                        userDefaults.removeObjectForKey(datasetName)
                        userDefaults.synchronize()
                    }
                }
                return nil
            }
        }
    }
    
    @IBAction func insertNewObject(sender: AnyObject) {
        var newRecord: UITextField?
        let createRecordAlert = UIAlertController(title: "New Record", message: "Enter a new record name", preferredStyle: .Alert)
        
        createRecordAlert.addTextFieldWithConfigurationHandler { (textField) -> Void in
            newRecord = textField
        }
        
        let okAction = UIAlertAction(title: "Ok", style: .Default) { (action) -> Void in
            self.addRecordToTableView(newRecord)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        
        createRecordAlert.addAction(okAction)
        createRecordAlert.addAction(cancelAction)
        
        self.presentViewController(createRecordAlert, animated: true, completion: nil)

    }
    
    func addRecordToTableView(newObject: UITextField?) {
        if let newRecord = newObject where !newRecord.text!.isEmpty && self.dataset?.stringForKey(newRecord.text) == nil {
            self.dataset?.setString(" ", forKey: newRecord.text)
            if let record = self.dataset?.recordForKey(newRecord.text) {
                self.objects.append(record)
                let indexPath = NSIndexPath(forRow: self.objects.count - 1, inSection: 0)
                self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
            }
        }
    }

    @IBAction func refreshClicked(sender: AnyObject?) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        self.dataset?.synchronize().continueWithBlock {
            (task) -> AnyObject! in
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            self.getRecords()
            dispatch_async(dispatch_get_main_queue()) {
                self.tableView.reloadData()
            }
            return nil
        }
    }
    
    @IBAction func populateClicked(sender: AnyObject) {
        for i in 0...(numDefaultRecords - 1) {
            let value = "\(i)"
            let key = "Key\(i)"
            self.dataset?.setString(value, forKey: key)
        }
        self.getRecords()
        self.tableView.reloadData()
    }
    
    // MARK: UIAlerts
    
    func errorAlert(message: String) {
        let errorAlert = UIAlertController(title: "Error", message: "\(message)", preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "Ok", style: .Default) { (alert: UIAlertAction) -> Void in }
        
        errorAlert.addAction(okAction)
        
        self.presentViewController(errorAlert, animated: true, completion: nil)
    }
    
    // MARK: Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.objects.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("RecordCell", forIndexPath: indexPath) 
        
        let object = self.objects[indexPath.row]
        
        cell.textLabel?.text = object.recordId
        cell.detailTextLabel?.text = "Value: \(object.data.string()) SyncCount: \(object.syncCount)"
        cell.detailTextLabel?.textColor = object.dirty ? UIColor.redColor() : UIColor.blackColor()

        return cell
    }

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }

    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let record = self.objects[indexPath.row]
            self.dataset?.removeObjectForKey(record.recordId)
            self.objects.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }
    }

    
    func updateRecordInTableView(newObjectField: UITextField?) {
        if let newValue = newObjectField where !newValue.text!.isEmpty {
            self.dataset?.setString(newValue.text, forKey: self.selectedRecord)
            self.selectedRecord = nil
            self.getRecords()
            self.tableView.reloadData()
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let record = self.objects[indexPath.row]
        self.selectedRecord = record.recordId
        
        var newValue: UITextField?
        let editValueAlert = UIAlertController(title: "New Value", message: "Enter a new value", preferredStyle: .Alert)
        
        editValueAlert.addTextFieldWithConfigurationHandler { (textField) -> Void in
            newValue = textField
        }
        
        let okAction = UIAlertAction(title: "Ok", style: .Default) { (action) -> Void in
            self.updateRecordInTableView(newValue)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        
        editValueAlert.addAction(okAction)
        editValueAlert.addAction(cancelAction)
        
        self.presentViewController(editValueAlert, animated: true, completion: nil)
    }
}
