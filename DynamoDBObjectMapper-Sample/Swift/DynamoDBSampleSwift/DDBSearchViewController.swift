/*
* Copyright 2010-2015 Amazon.com, Inc. or its affiliates. All Rights Reserved.
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

class DDBSearchViewController: UIViewController,UIPickerViewDataSource,UIPickerViewDelegate {
    
    @IBOutlet weak var gameTitlePickerView: UIPickerView!
    @IBOutlet weak var sortSegControl: UISegmentedControl!
    @IBOutlet weak var orderSegControl: UISegmentedControl!
    @IBOutlet weak var rangeStepper: UIStepper!
    @IBOutlet weak var rangeConditionLabel: UILabel!
    
    var pagniatedOutput: AWSDynamoDBPaginatedOutput?
    var pickerData:Array<String>!
    var rangeKeyArray:Array<String>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        pickerData = ["Comet Quest","Galaxy Invaders","Meteor Blasters", "Starship X", "Alien Adventure","Attack Ships"]
        rangeKeyArray = ["TopScore","Wins","Losses"]
        for var i=0;i<self.rangeKeyArray.count;i++ {
            self.sortSegControl.setTitle(self.rangeKeyArray[i], forSegmentAtIndex: i)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func searchBtnPressed(sender: UIButton) {
        
        let dynamoDBObjectMapper = AWSDynamoDBObjectMapper.defaultDynamoDBObjectMapper()
        
        //Query using GSI index table
        //What is the top score ever recorded for the game Meteor Blasters?
        let queryExpression = AWSDynamoDBQueryExpression()
        queryExpression.hashKeyValues = self.pickerData[self.gameTitlePickerView .selectedRowInComponent(0)];
        queryExpression.scanIndexForward = self.orderSegControl.selectedSegmentIndex==0 ? true : false;
        queryExpression.indexName = self.sortSegControl.titleForSegmentAtIndex(self.sortSegControl.selectedSegmentIndex)
        
        queryExpression.hashKeyAttribute = "GameTitle";
        
        //example expression: @"TopScore <= 5000" or @"Wins >= 10"
        queryExpression.rangeKeyConditionExpression = "\(self.rangeKeyArray[self.sortSegControl.selectedSegmentIndex]) > :rangeval"
        
        queryExpression.expressionAttributeValues = [":rangeval":self.rangeStepper.value];
        
        dynamoDBObjectMapper .query(DDBTableRow.self, expression: queryExpression) .continueWithExecutor(AWSExecutor.mainThreadExecutor(), withBlock: { (task:AWSTask!) -> AnyObject! in
            if (task.error != nil) {
                print("Error: \(task.error)")
                
                let alertController = UIAlertController(title: "Failed to query a test table.", message: task.error.description, preferredStyle: UIAlertControllerStyle.Alert)
                let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: { (action:UIAlertAction) -> Void in
                })
                alertController.addAction(okAction)
                self.presentViewController(alertController, animated: true, completion: nil)
            } else {
                if (task.result != nil) {
                    self.pagniatedOutput = task.result as? AWSDynamoDBPaginatedOutput
                }
                self.performSegueWithIdentifier("unwindToMainSegue", sender: self)
            }
            return nil
        })
        
    }
    
    @IBAction func rangeStepperChanged(sender: UIStepper) {
        self.rangeConditionLabel.text = "Larger than \(sender.value)"
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.pickerData.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.pickerData[row]
    }
    
}
