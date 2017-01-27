/*
* Copyright 2010-2017 Amazon.com, Inc. or its affiliates. All Rights Reserved.
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
        case unknown
        case insert
        case update
    }
    
    @IBOutlet weak var hashKeyTextField: UITextField!
    @IBOutlet weak var rangeKeyTextField: UITextField!
    @IBOutlet weak var attribute1TextField: UITextField!
    @IBOutlet weak var attribute2TextField: UITextField!
    @IBOutlet weak var attribute3TextField: UITextField!
    
    var viewType:DDBDetailViewType = DDBDetailViewType.unknown
    var tableRow:DDBTableRow?
    
    var dataChanged = false
    
    func getTableRow() {
        let dynamoDBObjectMapper = AWSDynamoDBObjectMapper.default()
        
        //tableRow?.UserId --> (tableRow?.UserId)!
        dynamoDBObjectMapper .load(DDBTableRow.self, hashKey: (tableRow?.UserId)!, rangeKey: tableRow?.GameTitle) .continueWith(executor: AWSExecutor.mainThread(), block: { (task:AWSTask!) -> AnyObject! in
            if let error = task.error as? NSError {
                print("Error: \(error)")
                let alertController = UIAlertController(title: "Failed to get item from table.", message: error.description, preferredStyle: UIAlertControllerStyle.alert)
                let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil)
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
            } else if let tableRow = task.result as? DDBTableRow {
                self.hashKeyTextField.text = tableRow.UserId
                self.rangeKeyTextField.text = tableRow.GameTitle
                self.attribute1TextField.text = tableRow.TopScore?.stringValue
                self.attribute2TextField.text = tableRow.Wins?.stringValue
                self.attribute3TextField.text = tableRow.Losses?.stringValue
            }
            
            return nil
        })
    }
    
    func insertTableRow(_ tableRow: DDBTableRow) {
        let dynamoDBObjectMapper = AWSDynamoDBObjectMapper.default()
        
        dynamoDBObjectMapper.save(tableRow) .continueWith(executor: AWSExecutor.mainThread(), block: { (task:AWSTask!) -> AnyObject! in
            if let error = task.error as? NSError {
                print("Error: \(error)")

                let alertController = UIAlertController(title: "Failed to insert the data into the table.", message: error.description, preferredStyle: UIAlertControllerStyle.alert)
                let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil)
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
            } else {
                let alertController = UIAlertController(title: "Succeeded", message: "Successfully inserted the data into the table.", preferredStyle: UIAlertControllerStyle.alert)
                let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil)
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
                
                self.rangeKeyTextField.text = nil
                self.attribute1TextField.text = nil
                self.attribute2TextField.text = nil
                self.attribute3TextField.text = nil
                
                self.dataChanged = true
            }

            return nil
        })
    }
    
    func updateTableRow(_ tableRow:DDBTableRow) {
        let dynamoDBObjectMapper = AWSDynamoDBObjectMapper.default()
        
        dynamoDBObjectMapper .save(tableRow) .continueWith(executor: AWSExecutor.mainThread(), block: { (task:AWSTask!) -> AnyObject! in
            if let error = task.error as? NSError {
                print("Error: \(error)")
                
                let alertController = UIAlertController(title: "Failed to update the data into the table.", message: error.description, preferredStyle: UIAlertControllerStyle.alert)
                let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil)
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
            } else {
                let alertController = UIAlertController(title: "Succeeded", message: "Successfully updated the data into the table.", preferredStyle: UIAlertControllerStyle.alert)
                let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil)
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
                
                if (self.viewType == DDBDetailViewType.insert) {
                    self.rangeKeyTextField.text = nil
                    self.attribute1TextField.text = nil
                }
                
                self.dataChanged = true
            }
            
            return nil
        })
    }
    
    @IBAction func submit(_ sender: UIBarButtonItem) {
        let tableRow = DDBTableRow()
        tableRow?.UserId = self.hashKeyTextField.text
        tableRow?.GameTitle = self.rangeKeyTextField.text
        if let topScore = Int(self.attribute1TextField.text!){
            tableRow?.TopScore = topScore as NSNumber?
        }
        if let wins = Int(self.attribute2TextField.text!){
            tableRow?.Wins = wins as NSNumber?
        }
        if let losses = Int(self.attribute3TextField.text!){
            tableRow?.Losses = losses as NSNumber?
        }
        
        switch self.viewType {
        case DDBDetailViewType.insert:
            if (self.rangeKeyTextField.text!.utf16.count > 0) {
                self.insertTableRow(tableRow!)
            } else {
                let alertController = UIAlertController(title: "Error: Invalid Input", message: "Range Key Value cannot be empty.", preferredStyle: UIAlertControllerStyle.alert)
                let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil)
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
            }
        case DDBDetailViewType.update:
            if (self.rangeKeyTextField.text!.utf16.count > 0) {
                self.updateTableRow(tableRow!)
            } else {
                let alertController = UIAlertController(title: "Error: Invalid Input", message: "Range Key Value cannot be empty.", preferredStyle: UIAlertControllerStyle.alert)
                let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil)
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
            }
        default:
            print("ERROR: Invalid viewType!")
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        switch self.viewType {
        case DDBDetailViewType.insert:
            self.title = "Insert"
            self.hashKeyTextField.isEnabled = true
            self.rangeKeyTextField.isEnabled = true
            
        case DDBDetailViewType.update:
            self.title = "Update"
            self.hashKeyTextField.isEnabled = false
            self.rangeKeyTextField.isEnabled = false
            self.getTableRow()
            
        default:
            print("ERROR: Invalid viewType!")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if (self.dataChanged) {
            let c = self.navigationController?.viewControllers.count
            let mainTableViewController = self.navigationController?.viewControllers [c! - 1] as! DDBMainTableViewController
            mainTableViewController.needsToRefresh = true
        }
    }
    
}
