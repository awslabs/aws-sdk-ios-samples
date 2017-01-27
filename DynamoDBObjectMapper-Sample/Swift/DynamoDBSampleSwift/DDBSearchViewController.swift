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
        for i in 0..<self.rangeKeyArray.count {
            self.sortSegControl.setTitle(self.rangeKeyArray[i], forSegmentAt: i)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func searchBtnPressed(_ sender: UIButton) {

        let dynamoDBObjectMapper = AWSDynamoDBObjectMapper.default()

        //Query using GSI index table
        //What is the top score ever recorded for the game Meteor Blasters?
        let queryExpression = AWSDynamoDBQueryExpression()
        queryExpression.scanIndexForward = self.orderSegControl.selectedSegmentIndex == 0 ? true : false;
        queryExpression.indexName = self.sortSegControl.titleForSegment(at: self.sortSegControl.selectedSegmentIndex)

        queryExpression.keyConditionExpression = "GameTitle = :gameTitle AND \(self.rangeKeyArray[self.sortSegControl.selectedSegmentIndex]) > :rangeval"

        queryExpression.expressionAttributeValues = [
            ":gameTitle" : self.pickerData[self.gameTitlePickerView .selectedRow(inComponent: 0)],
            ":rangeval" : self.rangeStepper.value];

        dynamoDBObjectMapper .query(DDBTableRow.self, expression: queryExpression) .continueWith(executor: AWSExecutor.mainThread(), block: { (task:AWSTask!) -> AnyObject! in
            if let error = task.error as? NSError {
                print("Error: \(error)")

                let alertController = UIAlertController(title: "Failed to query a test table.", message: error.description, preferredStyle: UIAlertControllerStyle.alert)
                let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil)
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
            } else {
                if let result = task.result {//(task.result != nil) {
                    self.pagniatedOutput = result
                }
                self.performSegue(withIdentifier: "unwindToMainSegue", sender: self)
            }
            return nil
        })

    }

    @IBAction func rangeStepperChanged(_ sender: UIStepper) {
        self.rangeConditionLabel.text = "Larger than \(sender.value)"
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.pickerData.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.pickerData[row]
    }
    
}
