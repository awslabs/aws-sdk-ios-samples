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

class CognitoDatasetListViewController: UITableViewController {
    
    var datasets: [AnyObject] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.rightBarButtonItem = self.editButtonItem()
        self.navigationController?.toolbarHidden = false
        datasets = AWSCognito.defaultCognito().listDatasets()
    }
    
    // MARK: Button Handlers

    @IBAction func createNewDataset(sender: AnyObject) {
        var newDataset: UITextField?
        let createDatasetAlert = UIAlertController(title: "New Dataset", message: "Enter a new dataset name", preferredStyle: .Alert)
        
        createDatasetAlert.addTextFieldWithConfigurationHandler { (textField) -> Void in
            newDataset = textField
        }
        
        let okAction = UIAlertAction(title: "Ok", style: .Default) { (action) -> Void in
            self.addDatasetToTableView(newDataset)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        
        createDatasetAlert.addAction(okAction)
        createDatasetAlert.addAction(cancelAction)
      
        self.presentViewController(createDatasetAlert, animated: true, completion: nil)
    }

    func addDatasetToTableView(datasetName: UITextField?) {
        if let datasetText = datasetName where !datasetText.text!.isEmpty {
            let dataset = AWSCognito.defaultCognito().openOrCreateDataset(datasetText.text)
            self.datasets.append(dataset)
            let indexPath = NSIndexPath(forRow: self.datasets.count - 1, inSection: 0)
            self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
        }
    }
    
    @IBAction func refreshClicked(sender: AnyObject) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        var tasks: [AWSTask] = []
        
        for dataset in self.datasets {
            tasks.append(AWSCognito.defaultCognito().openOrCreateDataset(dataset.name).synchronize())
        }
        
        AWSTask(forCompletionOfAllTasks: tasks).continueWithBlock { (task) -> AnyObject! in
            return AWSCognito.defaultCognito().refreshDatasetMetadata()
        }.continueWithBlock { (task) -> AnyObject! in
            dispatch_async(dispatch_get_main_queue()) {
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                
                if task.error != nil {
                    self.errorAlert(task.error.description)
                } else {
                    self.datasets = AWSCognito.defaultCognito().listDatasets()
                    self.tableView.reloadData()
                }
            }
            return nil
        }
        
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.datasets.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("DatasetListCell", forIndexPath: indexPath) 
        
        let dataset: AWSCognitoDatasetMetadata = self.datasets[indexPath.row] as! AWSCognitoDatasetMetadata
        cell.textLabel?.text = dataset.name
        
        if dataset.isDeleted() {
            let attrs: [String: AnyObject]? = [NSStrikethroughStyleAttributeName : NSUnderlineStyle.StyleSingle.rawValue]
            cell.textLabel?.attributedText = NSAttributedString(string: dataset.name, attributes: attrs)
        }

        return cell
    }

    // MARK: Table View methods
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if editingStyle == .Delete {
            
            // Delete the row from the data source
            let datasetMetadata: AWSCognitoDatasetMetadata = self.datasets[indexPath.row] as! AWSCognitoDatasetMetadata
            let dataSet = AWSCognito.defaultCognito().openOrCreateDataset(datasetMetadata.name)
            dataSet.clear()
            self.datasets[indexPath.row] = dataSet
            self.tableView.reloadData()
        }
    }
    
    // MARK: UI Alerts
    
    func errorAlert(message: String) {
        let errorAlert = UIAlertController(title: "Error", message: "\(message)", preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "Ok", style: .Default) { (alert: UIAlertAction) -> Void in }
        
        errorAlert.addAction(okAction)
        
        self.presentViewController(errorAlert, animated: true, completion: nil)
    }

    

    // MARK: Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDatasets" {
            let indexPath = self.tableView.indexPathForSelectedRow
            let datasetMetadata: AWSCognitoDatasetMetadata = self.datasets[indexPath!.row] as! AWSCognitoDatasetMetadata
            let dataset = AWSCognito.defaultCognito().openOrCreateDataset(datasetMetadata.name)
            
            if let controller = segue.destinationViewController as? CognitoDatasetViewController {
                controller.dataset = dataset
                let provider  = AWSCognito.defaultCognito().configuration.credentialsProvider
                controller.identityId = (provider as! AWSCognitoCredentialsProvider).identityId
            }
        }
    }


}
