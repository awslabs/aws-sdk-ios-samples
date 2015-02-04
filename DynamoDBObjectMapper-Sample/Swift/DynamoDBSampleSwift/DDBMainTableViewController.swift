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

class DDBMainTableViewController: UITableViewController {

    var tableRows:Array<DDBTableRow>?
    var lock:NSLock?
    var lastEvaluatedKey:NSDictionary?
    var  doneLoading = false
    
    var needsToRefresh = false
    
    @IBAction func unwindToMainTableViewControllerFromSearchViewController(unwindSegue:UIStoryboardSegue) {
        let searchVC = unwindSegue.sourceViewController as DDBSearchViewController
        self.tableRows?.removeAll(keepCapacity: true)
        
        if searchVC.pagniatedOutput != nil{
            for item in searchVC.pagniatedOutput!.items as [DDBTableRow] {
                self.tableRows?.append(item)
            }
        }

        self.doneLoading = true
        
        dispatch_async(dispatch_get_main_queue()) {
            self.tableView.reloadData()
        }
    }
    
    func setupTable() {
        //See if the test table exists.
        DDBDynamoDBManger.describeTable().continueWithExecutor(BFExecutor.mainThreadExecutor(), withBlock: { (task:BFTask!) -> AnyObject! in
       

   
            // If the test table doesn't exist, create one.
            if (task.error != nil && task.error.domain == AWSDynamoDBErrorDomain) && (task.error.code == AWSDynamoDBErrorType.ResourceNotFound.rawValue) {
                
                self.performSegueWithIdentifier("DDBLoadingViewSegue", sender: self)
                
                return DDBDynamoDBManger.createTable() .continueWithExecutor(BFExecutor.mainThreadExecutor(), withBlock: { (task:BFTask!) -> AnyObject! in
                    //Handle erros.
                    if ((task.error) != nil) {
                        println("Error: \(task.error)")
                        
                        
                        let alertController = UIAlertController(title: "Failed to setup a test table.", message: task.error.description, preferredStyle: UIAlertControllerStyle.Alert)
                        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: { (action:UIAlertAction!) -> Void in
                        })
                        alertController.addAction(okAction)
                        
                        self.presentViewController(alertController, animated: true, completion: nil)
                        
                        
                        
                    } else {
                        self.dismissViewControllerAnimated(false, completion: nil)
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
    
    func refreshList(startFromBeginning: Bool)  {
        if (self.lock?.tryLock() != nil) {
            if startFromBeginning {
                self.lastEvaluatedKey = nil;
                self.doneLoading = false
            }
            
            
            UIApplication.sharedApplication().networkActivityIndicatorVisible = true
            
            let dynamoDBObjectMapper = AWSDynamoDBObjectMapper.defaultDynamoDBObjectMapper()
            let queryExpression = AWSDynamoDBScanExpression()
            queryExpression.exclusiveStartKey = self.lastEvaluatedKey
            queryExpression.limit = 20;
            dynamoDBObjectMapper.scan(DDBTableRow.self, expression: queryExpression).continueWithExecutor(BFExecutor.mainThreadExecutor(), withBlock: { (task:BFTask!) -> AnyObject! in
        
                if self.lastEvaluatedKey == nil {
                    self.tableRows?.removeAll(keepCapacity: true)
                }
                
                if task.result != nil {
                    let paginatedOutput = task.result as AWSDynamoDBPaginatedOutput
                    for item in paginatedOutput.items as [DDBTableRow] {
                        self.tableRows?.append(item)
                    }
                    
                    self.lastEvaluatedKey = paginatedOutput.lastEvaluatedKey
                    if paginatedOutput.lastEvaluatedKey == nil {
                        self.doneLoading = true
                    }
                }

                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                self.tableView.reloadData()
                
                if ((task.error) != nil) {
                    println("Error: \(task.error)")
                }
                return nil
            })
        }
    }
    
    func deleteTableRow(row: DDBTableRow) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        let dynamoDBObjectMapper = AWSDynamoDBObjectMapper.defaultDynamoDBObjectMapper()
        dynamoDBObjectMapper.remove(row).continueWithExecutor(BFExecutor.mainThreadExecutor(), withBlock: { (task:BFTask!) -> AnyObject! in

            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            
            if ((task.error) != nil) {
                println("Error: \(task.error)")
                
                let alertController = UIAlertController(title: "Failed to delete a row.", message: task.error.description, preferredStyle: UIAlertControllerStyle.Alert)
                let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: { (action:UIAlertAction!) -> Void in
                })
                alertController.addAction(okAction)
                self.presentViewController(alertController, animated: true, completion: nil)
                
                
            }
            return nil
        })
        
    }
    
    func generateTestData() {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        let dynamoDBObjectMapper = AWSDynamoDBObjectMapper.defaultDynamoDBObjectMapper()
        
        let tasks = NSMutableArray()
        let gameTitleArray =  ["Galaxy Invaders","Meteor Blasters", "Starship X", "Alien Adventure","Attack Ships"]
        for var i = 0; i < 25; i++ {
            for var j = 0; j < 2; j++ {
                let tableRow = DDBTableRow();
                tableRow.UserId = "\(i)"
                if j == 0 {
                    let c = Int(arc4random_uniform(UInt32(gameTitleArray.count)))
                    tableRow.GameTitle = gameTitleArray[c]
                } else {
                    tableRow.GameTitle = "Comet Quest"
                }
                tableRow.TopScore = Int(arc4random_uniform(3000))
                tableRow.Wins = Int(arc4random_uniform(100))
                tableRow.Losses = Int(arc4random_uniform(100))
                tasks.addObject(dynamoDBObjectMapper.save(tableRow))
            }
        }
        
        BFTask(forCompletionOfAllTasks: tasks) .continueWithExecutor(BFExecutor.mainThreadExecutor(), withBlock: { (task:BFTask!) -> AnyObject! in
            if ((task.error) != nil) {
                println("Error: \(task.error)")
            }
            
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            
            self.refreshList(true)
            return nil
        })
    }
    
    @IBAction func showActionSheet(sender: AnyObject) {
        let alertController = UIAlertController(title: "Choose Your Action", message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        let addAction = UIAlertAction(title: "Add", style: UIAlertActionStyle.Default, handler: { (action:UIAlertAction!) -> Void in
            self.performSegueWithIdentifier("DDBSeguePushDetailViewController", sender: alertController)
        })
        
        let editTitle = self.tableView.editing ? "End Editing" : "Edit" ;
        let editAction = UIAlertAction(title: editTitle, style: UIAlertActionStyle.Default, handler: { (action:UIAlertAction!) -> Void in
            if self.tableView.editing {
                self.tableView.editing = false
            } else {
                self.tableView.editing = true
            }
        })
        
        let genAction = UIAlertAction(title: "Generate Test Data", style: UIAlertActionStyle.Default, handler: { (action:UIAlertAction!) -> Void in
            self.generateTestData()
        })
        
        let refreshAction = UIAlertAction(title: "Refresh", style: UIAlertActionStyle.Default, handler: { (action:UIAlertAction!) -> Void in
            self.refreshList(true)
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: { (action:UIAlertAction!) -> Void in
            
        })
        
        alertController.addAction(addAction)
        alertController.addAction(editAction)
        alertController.addAction(genAction)
        alertController.addAction(refreshAction)
        alertController.addAction(cancelAction)
        
        self.presentViewController(alertController, animated: true, completion: nil)

        
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        tableRows = []
        lock = NSLock()
        
        self.setupTable()
    }
    
    override func viewWillAppear(animated: Bool) {
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

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        if let rowCount = self.tableRows?.count {
            return rowCount;
        } else {
            return 0
        }
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell

        // Configure the cell...
        if let myTableRows = self.tableRows? {
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
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    

    
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            if var myTableRows = self.tableRows? {
                let item = myTableRows[indexPath.row]
                self.deleteTableRow(item)
                myTableRows.removeAtIndex(indexPath.row)
                self.tableRows = myTableRows
                
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            }
            
            
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        self.performSegueWithIdentifier("DDBSeguePushDetailViewController", sender: tableView.cellForRowAtIndexPath(indexPath))
    }

    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
        if segue.identifier == "DDBSeguePushDetailViewController" {
            let detailViewController = segue.destinationViewController as DDBDetailViewController
            if sender != nil {
                if (sender!.isKindOfClass(UIAlertController)) {
                    detailViewController.viewType = .Insert
                } else if (sender!.isKindOfClass(UITableViewCell)) {
                    let cell = sender as UITableViewCell
                    detailViewController.viewType = .Update
                    
                    let indexPath = self.tableView.indexPathForCell(cell)
                    let tableRow = self.tableRows?[indexPath!.row]
                    detailViewController.tableRow = tableRow
                    
                }
                
            }
        }
        
       
        
    }
    

}
