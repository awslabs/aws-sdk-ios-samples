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

class FirstViewController: UIViewController, NSURLSessionDelegate, NSURLSessionTaskDelegate, NSURLSessionDataDelegate{

    @IBOutlet var progressView: UIProgressView!
    @IBOutlet var statusLabel: UILabel!
    
    var session: NSURLSession?
    var uploadTask: NSURLSessionUploadTask?
    var uploadFileURL: NSURL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        struct Static {
            static var session: NSURLSession?
            static var token: dispatch_once_t = 0
        }
        
        dispatch_once(&Static.token) {
            let configuration = NSURLSessionConfiguration.backgroundSessionConfiguration(BackgroundSessionUploadIdentifier)
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
        
        if (self.uploadTask != nil) {
            return;
        }
        
        //Create a test file in the temporary directory
        self.uploadFileURL = NSURL.fileURLWithPath(NSTemporaryDirectory() + S3UploadKeyName)
        var dataString = "1234567890"
        for var i = 1; i < 22; i++ { //~20MB
            dataString += dataString
        }
        
        var error: NSError? = nil
        if NSFileManager.defaultManager().fileExistsAtPath(self.uploadFileURL!.path!) {
            NSFileManager.defaultManager().removeItemAtPath(self.uploadFileURL!.path!, error: &error)
        }
        
        dataString.writeToURL(self.uploadFileURL!, atomically: true, encoding: NSUTF8StringEncoding, error: &error)
        
        if (error) != nil {
            NSLog("Error: %@",error!);
        }
        
        let getPreSignedURLRequest = AWSS3GetPreSignedURLRequest()
        getPreSignedURLRequest.bucket = S3BucketName
        getPreSignedURLRequest.key = S3UploadKeyName
        getPreSignedURLRequest.HTTPMethod = AWSHTTPMethod.PUT
        getPreSignedURLRequest.expires = NSDate(timeIntervalSinceNow: 3600)
        
        //Important: must set contentType for PUT request
        let fileContentTypeStr = "text/plain"
        getPreSignedURLRequest.contentType = fileContentTypeStr
        
        
        AWSS3PreSignedURLBuilder.defaultS3PreSignedURLBuilder().getPreSignedURL(getPreSignedURLRequest) .continueWithBlock { (task:BFTask!) -> (AnyObject!) in
            
            if (task.error != nil) {
                NSLog("Error: %@", task.error)
            } else {
                
                let presignedURL = task.result as NSURL!
                if (presignedURL != nil) {
                    NSLog("upload presignedURL is: \n%@", presignedURL)
                    
                    var request = NSMutableURLRequest(URL: presignedURL)
                    request.cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData
                    request.HTTPMethod = "PUT"
                    
                    //contentType in the URLRequest must be the same as the one in getPresignedURLRequest
                    request .setValue(fileContentTypeStr, forHTTPHeaderField: "Content-Type")
                    
                    self.uploadTask = self.session?.uploadTaskWithRequest(request, fromFile: self.uploadFileURL!)
                    self.uploadTask?.resume()
                    
                }
            }
            return nil;
            
        }
    }
    
    func URLSession(session: NSURLSession, task: NSURLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        
        let progress = Float(totalBytesSent) / Float(totalBytesExpectedToSend)
        
        NSLog("UploadTask progress: %lf", progress)
        
        dispatch_async(dispatch_get_main_queue()) {
            self.progressView.progress = progress
            self.statusLabel.text = "Uploading..."
        }
        
    }
    
    func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
        
        if (error == nil) {
            dispatch_async(dispatch_get_main_queue()) {
                self.statusLabel.text = "Upload Successfully"
            }
            NSLog("S3 UploadTask: %@ completed successfully", task);
        } else {
            dispatch_async(dispatch_get_main_queue()) {
                self.statusLabel.text = "Upload Failed"
            }
            NSLog("S3 UploadTask: %@ completed with error: %@", task, error!.localizedDescription);
        }
        
        dispatch_async(dispatch_get_main_queue()) {
            self.progressView.progress = Float(task.countOfBytesSent) / Float(task.countOfBytesExpectedToSend)
        }
        
        self.uploadTask = nil
        
    }
    
    func URLSessionDidFinishEventsForBackgroundURLSession(session: NSURLSession) {
        
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        if ((appDelegate.backgroundUploadSessionCompletionHandler) != nil) {
            let completionHandler:() = appDelegate.backgroundUploadSessionCompletionHandler!;
            appDelegate.backgroundUploadSessionCompletionHandler = nil
            completionHandler
        }
        
        NSLog("Completion Handler has been invoked, background upload task has finished.");
    }

}

