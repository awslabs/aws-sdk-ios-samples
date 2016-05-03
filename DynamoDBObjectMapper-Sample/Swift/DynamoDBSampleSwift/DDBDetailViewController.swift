/*
* Copyright 2010-2016 Amazon.com, Inc. or its affiliates. All Rights Reserved.
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
import AWSDynamoDB

class DDBDetailViewController: UIViewController {
    
    enum DDBDetailViewType {
        case Unknown
        case Insert
        case Update
    }
    
    @IBOutlet weak var hashKeyTextField: UITextField!
    @IBOutlet weak var rangeKeyTextField: UITextField!
    @IBOutlet weak var attribute1TextField: UITextField!
    @IBOutlet weak var attribute2TextField: UITextField!
    @IBOutlet weak var attribute3TextField: UITextField!
    
    var viewType:DDBDetailViewType = DDBDetailViewType.Unknown
    var tableRow:DDBTableRow?
    
    var dataChanged = false
    
    func getTableRow() {
        let dynamoDBObjectMapper = AWSDynamoDBObjectMapper.defaultDynamoDBObjectMapper()
        
        //tableRow?.UserId --> (tableRow?.UserId)!
        dynamoDBObjectMapper .load(DDBTableRow.self, hashKey: (tableRow?.UserId)!, rangeKey: tableRow?.GameTitle) .continueWithExecutor(AWSExecutor.mainThreadExecutor(), withBlock: { (task:AWSTask!) -> AnyObject! in
            if (task.error == nil) {
                if (task.result != nil) {
                    let tableRow = task.result as! DDBTableRow
                    self.hashKeyTextField.text = tableRow.UserId
                    self.rangeKeyTextField.text = tableRow.GameTitle
                    self.attribute1TextField.text = tableRow.TopScore?.stringValue
                    self.attribute2TextField.text = tableRow.Wins?.stringValue
                    self.attribute3TextField.text = tableRow.Losses?.stringValue
                }
            } else {
                print("Error: \(task.error)")
                let alertController = UIAlertController(title: "Failed to get item from table.", message: task.error!.description, preferredStyle: UIAlertControllerStyle.Alert)
                let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: { (action:UIAlertAction) -> Void in
                })
                alertController.addAction(okAction)
                self.presentViewController(alertController, animated: true, completion: nil)
                
            }
            return nil
        })
    }
    
    func insertTableRow(tableRow: DDBTableRow) {
        let dynamoDBObjectMapper = AWSDynamoDBObjectMapper.defaultDynamoDBObjectMapper()
        
        dynamoDBObjectMapper.save(tableRow) .continueWithExecutor(AWSExecutor.mainThreadExecutor(), withBlock: { (task:AWSTask!) -> AnyObject! in
            if (task.error == nil) {
                let alertController = UIAlertController(title: "Succeeded", message: "Successfully inserted the data into the table.", preferredStyle: UIAlertControllerStyle.Alert)
                let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: { (action:UIAlertAction) -> Void in
                })
                alertController.addAction(okAction)
                self.presentViewController(alertController, animated: true, completion: nil)
                
                self.rangeKeyTextField.text = nil
                self.attribute1TextField.text = nil
                self.attribute2TextField.text = nil
                self.attribute3TextField.text = nil
                
                self.dataChanged = true
                
            } else {
                print("Error: \(task.error)")
                
                let alertController = UIAlertController(title: "Failed to insert the data into the table.", message: task.error!.description, preferredStyle: UIAlertControllerStyle.Alert)
                let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: { (action:UIAlertAction) -> Void in
                })
                alertController.addAction(okAction)
                self.presentViewController(alertController, animated: true, completion: nil)
            }
            
            return nil
        })
    }
    
    func updateTableRow(tableRow:DDBTableRow) {
        let dynamoDBObjectMapper = AWSDynamoDBObjectMapper.defaultDynamoDBObjectMapper()
        
        dynamoDBObjectMapper .save(tableRow) .continueWithExecutor(AWSExecutor.mainThreadExecutor(), withBlock: { (task:AWSTask!) -> AnyObject! in
            if (task.error == nil) {
                let alertController = UIAlertController(title: "Succeeded", message: "Successfully updated the data into the table.", preferredStyle: UIAlertControllerStyle.Alert)
                let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: { (action:UIAlertAction) -> Void in
                })
                alertController.addAction(okAction)
                self.presentViewController(alertController, animated: true, completion: nil)
                
                if (self.viewType == DDBDetailViewType.Insert) {
                    self.rangeKeyTextField.text = nil
                    self.attribute1TextField.text = nil
                }
                
                self.dataChanged = true
            } else {
                print("Error: \(task.error)")
                
                let alertController = UIAlertController(title: "Failed to update the data into the table.", message: task.error!.description, preferredStyle: UIAlertControllerStyle.Alert)
                let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: { (action:UIAlertAction) -> Void in
                })
                alertController.addAction(okAction)
                self.presentViewController(alertController, animated: true, completion: nil)
            }
            
            return nil
        })
    }
    
    @IBAction func submit(sender: UIBarButtonItem) {
        let tableRow = DDBTableRow()
        tableRow.UserId = self.hashKeyTextField.text
        tableRow.GameTitle = self.rangeKeyTextField.text
        if let topScore = Int(self.attribute1TextField.text!){
            tableRow.TopScore = topScore
        }
        if let wins = Int(self.attribute2TextField.text!){
            tableRow.Wins = wins
        }
        if let losses = Int(self.attribute3TextField.text!){
            tableRow.Losses = losses
        }
        
        switch self.viewType {
        case DDBDetailViewType.Insert:
            if (self.rangeKeyTextField.text!.utf16.count > 0) {
                self.insertTableRow(tableRow)
            } else {
                let alertController = UIAlertController(title: "Error: Invalid Input", message: "Range Key Value cannot be empty.", preferredStyle: UIAlertControllerStyle.Alert)
                let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: { (action:UIAlertAction) -> Void in
                })
                alertController.addAction(okAction)
                self.presentViewController(alertController, animated: true, completion: nil)
            }
        case DDBDetailViewType.Update:
            if (self.rangeKeyTextField.text!.utf16.count > 0) {
                self.updateTableRow(tableRow)
            } else {
                let alertController = UIAlertController(title: "Error: Invalid Input", message: "Range Key Value cannot be empty.", preferredStyle: UIAlertControllerStyle.Alert)
                let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: { (action:UIAlertAction) -> Void in
                })
                alertController.addAction(okAction)
                self.presentViewController(alertController, animated: true, completion: nil)
            }
        default:
            print("ERROR: Invalid viewType!")
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        switch self.viewType {
        case DDBDetailViewType.Insert:
            self.title = "Insert"
            self.hashKeyTextField.enabled = true
            self.rangeKeyTextField.enabled = true
            
        case DDBDetailViewType.Update:
            self.title = "Update"
            self.hashKeyTextField.enabled = false
            self.rangeKeyTextField.enabled = false
            self.getTableRow()
            
        default:
            print("ERROR: Invalid viewType!")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        if (self.dataChanged) {
            let c = self.navigationController?.viewControllers.count
            let mainTableViewController = self.navigationController?.viewControllers [c! - 1] as! DDBMainTableViewController
            mainTableViewController.needsToRefresh = true
        }
    }
    
}
