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

class DDBMainTableViewController: UITableViewController {

    var tableRows:Array<DDBTableRow>?
    var lock:NSLock?
    var lastEvaluatedKey:[String : AWSDynamoDBAttributeValue]!
    var  doneLoading = false

    var needsToRefresh = false

    @IBAction func unwindToMainTableViewControllerFromSearchViewController(_ unwindSegue:UIStoryboardSegue) {
        let searchVC = unwindSegue.source as! DDBSearchViewController
        self.tableRows?.removeAll(keepingCapacity: true)

        if searchVC.pagniatedOutput != nil{
            for item in searchVC.pagniatedOutput!.items as! [DDBTableRow] {
                self.tableRows?.append(item)
            }
        }

        self.doneLoading = true

        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }

    func setupTable() {
        //See if the test table exists.
        DDBDynamoDBManger.describeTable().continueWith(executor: AWSExecutor.mainThread(), block: { (task:AWSTask!) -> AnyObject! in

            // If the test table doesn't exist, create one.
            if let error = task.error as? NSError, error.domain == AWSDynamoDBErrorDomain && error.code == AWSDynamoDBErrorType.resourceNotFound.rawValue {
                    self.performSegue(withIdentifier: "DDBLoadingViewSegue", sender: self)

                    return DDBDynamoDBManger.createTable() .continueWith(executor: AWSExecutor.mainThread(), block: { (task:AWSTask!) -> AnyObject! in
                        if let error = task.error as? NSError {
                            //Handle errors.
                            print("Error: \(error)")
                            
                            let alertController = UIAlertController(title: "Failed to setup a test table.", message: error.description, preferredStyle: UIAlertControllerStyle.alert)
                            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil)
                            alertController.addAction(okAction)
                            
                            self.present(alertController, animated: true, completion: nil)
                        } else {
                            self.dismiss(animated: false, completion: nil)
                        }

                        return nil

                    })
            } else {
                //load table contents
                self.refreshList(true)
            }

            return nil
        })
    }

    func refreshList(_ startFromBeginning: Bool)  {
        if (self.lock?.try() != nil) {
            if startFromBeginning {
                self.lastEvaluatedKey = nil;
                self.doneLoading = false
            }


            UIApplication.shared.isNetworkActivityIndicatorVisible = true

            let dynamoDBObjectMapper = AWSDynamoDBObjectMapper.default()
            let queryExpression = AWSDynamoDBScanExpression()
            queryExpression.exclusiveStartKey = self.lastEvaluatedKey
            queryExpression.limit = 20
            dynamoDBObjectMapper.scan(DDBTableRow.self, expression: queryExpression).continueWith(executor: AWSExecutor.mainThread(), block: { (task:AWSTask!) -> AnyObject! in

                if self.lastEvaluatedKey == nil {
                    self.tableRows?.removeAll(keepingCapacity: true)
                }

                if let paginatedOutput = task.result {
                    for item in paginatedOutput.items as! [DDBTableRow] {
                        self.tableRows?.append(item)
                    }

                    self.lastEvaluatedKey = paginatedOutput.lastEvaluatedKey
                    if paginatedOutput.lastEvaluatedKey == nil {
                        self.doneLoading = true
                    }
                }

                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                self.tableView.reloadData()

                if let error = task.error as? NSError {
                    print("Error: \(error)")
                }

                return nil
            })
        }
    }

    func deleteTableRow(_ row: DDBTableRow) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true

        let dynamoDBObjectMapper = AWSDynamoDBObjectMapper.default()
        dynamoDBObjectMapper.remove(row).continueWith(executor: AWSExecutor.mainThread(), block: { (task:AWSTask!) -> AnyObject! in

            UIApplication.shared.isNetworkActivityIndicatorVisible = false

            if let error = task.error as? NSError {
                print("Error: \(error)")

                let alertController = UIAlertController(title: "Failed to delete a row.", message: error.description, preferredStyle: UIAlertControllerStyle.alert)
                let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil)
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
            }

            return nil
        })

    }

    func generateTestData() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true

        let dynamoDBObjectMapper = AWSDynamoDBObjectMapper.default()

        var tasks = [AWSTask<AnyObject>]()
        let gameTitleArray =  ["Galaxy Invaders","Meteor Blasters", "Starship X", "Alien Adventure","Attack Ships"]
        for i in 0..<25 {
            for j in 0..<2 {
                let tableRow = DDBTableRow();
                tableRow?.UserId = "\(i)"
                if j == 0 {
                    let c = Int(arc4random_uniform(UInt32(gameTitleArray.count)))
                    tableRow?.GameTitle = gameTitleArray[c]
                } else {
                    tableRow?.GameTitle = "Comet Quest"
                }
                tableRow?.TopScore = Int(arc4random_uniform(3000)) as NSNumber?
                tableRow?.Wins = Int(arc4random_uniform(100)) as NSNumber?
                tableRow?.Losses = Int(arc4random_uniform(100)) as NSNumber?

                //Those two properties won't be saved to DynamoDB since it has been defined in ignoredAttributes
                tableRow?.internalName = "internal attributes(should not be saved to dynamoDB)"
                tableRow?.internalState = i as NSNumber?;

                tasks.append(dynamoDBObjectMapper.save(tableRow!))
            }
        }

        AWSTask<AnyObject>(forCompletionOfAllTasks: Optional(tasks)).continueWith(executor: AWSExecutor.mainThread(), block: { (task: AWSTask) -> AnyObject? in
            if let error = task.error as? NSError {
                print("Error: \(error)")
            }

            UIApplication.shared.isNetworkActivityIndicatorVisible = false

            self.refreshList(true)
            return nil
        })
    }

    @IBAction func showActionSheet(_ sender: AnyObject) {
        let alertController = UIAlertController(title: "Choose Your Action", message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)

        let addAction = UIAlertAction(title: "Add", style: UIAlertActionStyle.default, handler: { (action:UIAlertAction) -> Void in
            self.performSegue(withIdentifier: "DDBSeguePushDetailViewController", sender: alertController)
        })

        let editTitle = self.tableView.isEditing ? "End Editing" : "Edit" ;
        let editAction = UIAlertAction(title: editTitle, style: UIAlertActionStyle.default, handler: { (action:UIAlertAction) -> Void in
            if self.tableView.isEditing {
                self.tableView.isEditing = false
            } else {
                self.tableView.isEditing = true
            }
        })

        let genAction = UIAlertAction(title: "Generate Test Data", style: UIAlertActionStyle.default, handler: { (action:UIAlertAction) -> Void in
            self.generateTestData()
        })

        let refreshAction = UIAlertAction(title: "Refresh", style: UIAlertActionStyle.default, handler: { (action:UIAlertAction) -> Void in
            self.refreshList(true)
        })

        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: { (action:UIAlertAction) -> Void in

        })

        alertController.addAction(addAction)
        alertController.addAction(editAction)
        alertController.addAction(genAction)
        alertController.addAction(refreshAction)
        alertController.addAction(cancelAction)

        self.present(alertController, animated: true, completion: nil)


    }
    override func viewDidLoad() {
        super.viewDidLoad()

        tableRows = []
        lock = NSLock()

        self.setupTable()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if self.needsToRefresh {
            self.refreshList(true)
            self.needsToRefresh = false
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // Return the number of sections.
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        if let rowCount = self.tableRows?.count {
            return rowCount;
        } else {
            return 0
        }
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        // Configure the cell...
        if let myTableRows = self.tableRows {
            let item = myTableRows[indexPath.row]
            cell.textLabel?.text = "ID: \(item.UserId!), Title: \(item.GameTitle!)"

            if let myDetailTextLabel = cell.detailTextLabel {
                myDetailTextLabel.text = "TopScore:\(item.TopScore!), Wins:\(item.Wins!), Losses:\(item.Losses!                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  )"
            }

            if indexPath.row == myTableRows.count - 1 && !self.doneLoading {
                self.refreshList(false)
            }
        }

        return cell
    }



    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }



    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            if var myTableRows = self.tableRows {
                let item = myTableRows[indexPath.row]
                self.deleteTableRow(item)
                myTableRows.remove(at: indexPath.row)
                self.tableRows = myTableRows

                tableView.deleteRows(at: [indexPath], with: .fade)
            }


        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        self.performSegue(withIdentifier: "DDBSeguePushDetailViewController", sender: tableView.cellForRow(at: indexPath))
    }




    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
        if segue.identifier == "DDBSeguePushDetailViewController" {
            let detailViewController = segue.destination as! DDBDetailViewController
            if sender != nil {
                if sender is UIAlertController {
                    detailViewController.viewType = .insert
                } else if sender is UITableViewCell {
                    let cell = sender as! UITableViewCell
                    detailViewController.viewType = .update
                    
                    let indexPath = self.tableView.indexPath(for: cell)
                    let tableRow = self.tableRows?[indexPath!.row]
                    detailViewController.tableRow = tableRow
                }
            }
        }
    }
    
    
}
