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

class FirstViewController: UIViewController{
    
    @IBOutlet var progressView: UIProgressView!
    @IBOutlet var statusLabel: UILabel!
    
    var uploadFileURL: NSURL?
    var completionHandler: AWSS3TransferUtilityUploadCompletionHandlerBlock?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.progressView.progress = 0.0;
        self.statusLabel.text = "Ready"
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func start(sender: UIButton) {
        
        //Create a test file in the temporary directory
        self.uploadFileURL = NSURL.fileURLWithPath(NSTemporaryDirectory() + S3UploadKeyName)
        var dataString = "1234567890"
        for var i = 1; i < 22; i++ { //~20MB
            dataString += dataString
        }
        
        var error: NSError? = nil
        if NSFileManager.defaultManager().fileExistsAtPath(self.uploadFileURL!.path!) {
            do {
                try NSFileManager.defaultManager().removeItemAtPath(self.uploadFileURL!.path!)
            } catch let error1 as NSError {
                error = error1
            }
        }
        
        do {
            try dataString.writeToURL(self.uploadFileURL!, atomically: true, encoding: NSUTF8StringEncoding)
        } catch let error1 as NSError {
            error = error1
        }
        
        if (error) != nil {
            NSLog("Error: %@",error!);
        }
        
        let expression = AWSS3TransferUtilityUploadExpression()
        expression.uploadProgress = {(task: AWSS3TransferUtilityTask, bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) in
            dispatch_async(dispatch_get_main_queue(), {
                let progress = Float(totalBytesSent) / Float(totalBytesExpectedToSend)
                self.progressView.progress = progress
                self.statusLabel.text = "Uploading..."
                NSLog("Progress is: %f",progress)
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
        
        let transferUtility = AWSS3TransferUtility.defaultS3TransferUtility()
        
        transferUtility?.uploadFile(self.uploadFileURL!, bucket: S3BucketName, key: S3UploadKeyName, contentType: "text/plain", expression: expression, completionHander: completionHandler).continueWithBlock { (task) -> AnyObject! in
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