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

class SecondViewController: UIViewController,NSURLSessionDelegate, NSURLSessionTaskDelegate, NSURLSessionDownloadDelegate {

    @IBOutlet var imageView: UIImageView!
    @IBOutlet var progressView: UIProgressView!
    @IBOutlet var statusLabel: UILabel!
    
    var session: NSURLSession?
    var downloadTask: NSURLSessionDownloadTask?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        struct Static {
            static var session: NSURLSession?
            static var token: dispatch_once_t = 0
        }
        
        dispatch_once(&Static.token) {
            let configuration = NSURLSessionConfiguration.backgroundSessionConfiguration(BackgroundSessionDownloadIdentifier)
            Static.session = NSURLSession(configuration: configuration, delegate: self, delegateQueue: nil)
        }
        
        self.session = Static.session;
        
        self.progressView.progress = 0;
        self.statusLabel.text = "Ready"
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func start(sender: UIButton) {
        
        if (self.downloadTask != nil) {
            return;
        }
        
        self.imageView.image = nil;
        
        let getPreSignedURLRequest = AWSS3GetPreSignedURLRequest()
        getPreSignedURLRequest.bucket = S3BucketName
        getPreSignedURLRequest.key = S3DownloadKeyName
        getPreSignedURLRequest.HTTPMethod = AWSHTTPMethod.GET
        getPreSignedURLRequest.expires = NSDate(timeIntervalSinceNow: 3600)
        
        
        AWSS3PreSignedURLBuilder.defaultS3PreSignedURLBuilder().getPreSignedURL(getPreSignedURLRequest) .continueWithBlock { (task:AWSTask!) -> (AnyObject!) in
            
            if (task.error != nil) {
                NSLog("Error: %@", task.error)
            } else {
                
                let presignedURL = task.result as! NSURL!
                if (presignedURL != nil) {
                    NSLog("download presignedURL is: \n%@", presignedURL)
                    
                    let request = NSURLRequest(URL: presignedURL)
                    self.downloadTask = self.session?.downloadTaskWithRequest(request)
                    self.downloadTask?.resume()
                }
            }
            return nil;
        }
        
        
    }
    
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        
        let progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
        
        NSLog("DownloadTask progress: %lf", progress)
        
        dispatch_async(dispatch_get_main_queue()) {
            self.progressView.progress = progress
            self.statusLabel.text = "Downloading..."
        }
        
    }
    
    
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didFinishDownloadingToURL location: NSURL) {
        
        NSLog("[%@ %@]", reflect(self).summary, __FUNCTION__)
        
        let paths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
        
        let documentsPath = paths.first as? String
        let filePath = documentsPath! + S3DownloadKeyName
        
        //move the downloaded file to docs directory
        if NSFileManager.defaultManager().fileExistsAtPath(filePath) {
            NSFileManager.defaultManager().removeItemAtPath(filePath, error: nil)
        }
        
        NSFileManager.defaultManager().moveItemAtURL(location, toURL: NSURL.fileURLWithPath(filePath)!, error: nil)
        
        
        //update UI elements
        dispatch_async(dispatch_get_main_queue()) {
            self.imageView.image = UIImage(contentsOfFile: filePath)
        }
    }


    func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
        if (error == nil) {
            dispatch_async(dispatch_get_main_queue()) {
                self.statusLabel.text = "Download Successfully"
            }
            NSLog("S3 DownloadTask: %@ completed successfully", task);
        } else {
            dispatch_async(dispatch_get_main_queue()) {
                self.statusLabel.text = "Download Failed"
            }
            NSLog("S3 DownloadTask: %@ completed with error: %@", task, error!.localizedDescription);
        }
        
        dispatch_async(dispatch_get_main_queue()) {
             self.progressView.progress = Float(task.countOfBytesReceived) / Float(task.countOfBytesExpectedToReceive)
        }
        
        self.downloadTask = nil
    }
    
    func URLSessionDidFinishEventsForBackgroundURLSession(session: NSURLSession) {
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        if ((appDelegate.backgroundDownloadSessionCompletionHandler) != nil) {
            let completionHandler:() = appDelegate.backgroundDownloadSessionCompletionHandler!;
            appDelegate.backgroundDownloadSessionCompletionHandler = nil
            completionHandler
        }
        
        NSLog("Completion Handler has been invoked, background download task has finished.");
    }
}

