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
import AWSS3

class DownloadViewController: UIViewController{
    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var progressView: UIProgressView!
    @IBOutlet var statusLabel: UILabel!
    
    var completionHandler: AWSS3TransferUtilityDownloadCompletionHandlerBlock?
    
    let transferUtility = AWSS3TransferUtility.default()
    
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
    
    @IBAction func start(_ sender: UIButton) {
        
        self.imageView.image = nil;
        
        let expression = AWSS3TransferUtilityDownloadExpression()
        expression.progressBlock = {(task, progress) in
            DispatchQueue.main.async(execute: {
                self.progressView.progress = Float(progress.fractionCompleted)
                self.statusLabel.text = "Downloading..."
            })
        }
        
        self.completionHandler = { (task, location, data, error) -> Void in
            DispatchQueue.main.async(execute: {
                if let error = error {
                    NSLog("Failed with error: \(error)")
                    self.statusLabel.text = "Failed"
                }
                else if(self.progressView.progress != 1.0) {
                    self.statusLabel.text = "Failed"
                    NSLog("Error: Failed - Likely due to invalid region / filename")
                }
                else{
                    self.statusLabel.text = "Success"
                    self.imageView.image = UIImage(data: data!)
                }
            })
        }

        transferUtility.downloadData(
            fromBucket: S3BucketName,
            key: S3DownloadKeyName,
            expression: expression,
            completionHandler: completionHandler).continueWith { (task) -> AnyObject? in
                if let error = task.error {
                    NSLog("Error: %@",error.localizedDescription);
                    self.statusLabel.text = "Failed"
                }
                
                if let _ = task.result {
                    self.statusLabel.text = "Starting Download"
                    NSLog("Download Starting!")
                    // Do something with uploadTask.
                }
                return nil;
            }
    }
}
