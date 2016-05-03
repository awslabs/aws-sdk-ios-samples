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
import AWSS3

class FirstViewController: UIViewController{

    @IBOutlet var progressView: UIProgressView!
    @IBOutlet var statusLabel: UILabel!

    var completionHandler: AWSS3TransferUtilityUploadCompletionHandlerBlock?
    var progressBlock: AWSS3TransferUtilityProgressBlock?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        self.progressView.progress = 0.0;
        self.statusLabel.text = "Ready"

        self.progressBlock = {(task, progress) in
            dispatch_async(dispatch_get_main_queue(), {
                self.progressView.progress = Float(progress.fractionCompleted)
                self.statusLabel.text = "Uploading..."
            })
        }

        self.completionHandler = { (task, error) -> Void in
            dispatch_async(dispatch_get_main_queue(), {
                if ((error) != nil){
                    NSLog("Failed with error")
                    NSLog("Error: %@",error!);
                    self.statusLabel.text = "Failed"
                }
                else if(self.progressView.progress != 1.0) {
                    self.statusLabel.text = "Failed"
                    NSLog("Error: Failed - Likely due to invalid region / filename")
                }
                else{
                    self.statusLabel.text = "Success"
                }
            })
        }
    }

    @IBAction func start(sender: UIButton) {
        statusLabel.text = "Creating a test data..."

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            //Create a test file in the temporary directory
            var dataString = "1234567890"
            for _ in 1..<22 { //~20MB
                dataString += dataString
            }
            let testData = dataString.dataUsingEncoding(NSUTF8StringEncoding)!

            self.uploadData(testData)
        }
    }

    func uploadData(data: NSData) {
        let expression = AWSS3TransferUtilityUploadExpression()
        expression.progressBlock = progressBlock

        let transferUtility = AWSS3TransferUtility.defaultS3TransferUtility()

        transferUtility.uploadData(
            data,
            bucket: S3BucketName,
            key: S3UploadKeyName,
            contentType: "text/plain",
            expression: expression,
            completionHander: completionHandler).continueWithBlock { (task) -> AnyObject! in
                if let error = task.error {
                    NSLog("Error: %@",error.localizedDescription);
                    self.statusLabel.text = "Failed"
                }
                if let exception = task.exception {
                    NSLog("Exception: %@",exception.description);
                    self.statusLabel.text = "Failed"
                }
                if let _ = task.result {
                    self.statusLabel.text = "Generating Upload File"
                    NSLog("Upload Starting!")
                    // Do something with uploadTask.
                }
                
                return nil;
        }
    }
}