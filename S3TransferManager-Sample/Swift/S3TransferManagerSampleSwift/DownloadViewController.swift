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

class DownloadViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var downloadRequests = Array<AWSS3TransferManagerDownloadRequest?>()
    var downloadFileURLs = Array<NSURL?>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        listObjects()
        let error = NSErrorPointer()
        do {
            try NSFileManager.defaultManager().createDirectoryAtURL(
                NSURL(fileURLWithPath: NSTemporaryDirectory()).URLByAppendingPathComponent("download"),
                withIntermediateDirectories: true,
                attributes: nil)
        } catch let error1 as NSError {
            error.memory = error1
            print("Creating 'download' directory failed. Error: \(error)")
        }
    }
    
    @IBAction func showAlertController(barButtonItem: UIBarButtonItem) {
        let alertController = UIAlertController(
            title: "Available Actions",
            message: "Choose your action.",
            preferredStyle: .ActionSheet)
        
        let refreshAction = UIAlertAction(
            title: "Refresh",
            style: .Default) { (action) -> Void in
                self.downloadRequests.removeAll(keepCapacity: false)
                self.downloadFileURLs.removeAll(keepCapacity: false)
                self.collectionView.reloadData()
                self.listObjects()
        }
        alertController.addAction(refreshAction)
        
        let downloadAllAction = UIAlertAction(
            title: "Download All",
            style: .Default) { (action) -> Void in
                self.downloadAll()
        }
        alertController.addAction(downloadAllAction)
        
        let cancelAllDownloadsAction = UIAlertAction(
            title: "Cancel All Downloads",
            style: .Default) { (action) -> Void in
                self.cancelAllDownloads()
        }
        alertController.addAction(cancelAllDownloadsAction)
        
        let cancelAction = UIAlertAction(
            title: "Cancel",
            style: .Cancel,
            handler: nil)
        alertController.addAction(cancelAction)
        
        self.presentViewController(
            alertController,
            animated: true,
            completion: nil)
    }
    
    func listObjects() {
        let s3 = AWSS3.defaultS3()
        
        let listObjectsRequest = AWSS3ListObjectsRequest()
        listObjectsRequest.bucket = S3BucketName
        s3.listObjects(listObjectsRequest).continueWithBlock { (task) -> AnyObject! in
            if let error = task.error {
                print("listObjects failed: [\(error)]")
            }
            if let exception = task.exception {
                print("listObjects failed: [\(exception)]")
            }
            if let listObjectsOutput = task.result as? AWSS3ListObjectsOutput {
                if let contents = listObjectsOutput.contents as? [AWSS3Object] {
                    for s3Object in contents {
                        let downloadingFileURL = NSURL(fileURLWithPath: NSTemporaryDirectory()).URLByAppendingPathComponent("download").URLByAppendingPathComponent(s3Object.key)
                        let downloadingFilePath = downloadingFileURL.path!
                        
                        if NSFileManager.defaultManager().fileExistsAtPath(downloadingFilePath) {
                            self.downloadRequests.append(nil)
                            self.downloadFileURLs.append(downloadingFileURL)
                        } else {
                            let downloadRequest = AWSS3TransferManagerDownloadRequest()
                            downloadRequest.bucket = S3BucketName
                            downloadRequest.key = s3Object.key
                            downloadRequest.downloadingFileURL = downloadingFileURL
                            
                            self.downloadRequests.append(downloadRequest)
                            self.downloadFileURLs.append(nil)
                        }
                    }
                    
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.collectionView.reloadData()
                    })
                }
            }
            return nil
        }
    }
    
    func download(downloadRequest: AWSS3TransferManagerDownloadRequest) {
        switch (downloadRequest.state) {
        case .NotStarted, .Paused:
            let transferManager = AWSS3TransferManager.defaultS3TransferManager()
            transferManager.download(downloadRequest).continueWithBlock({ (task) -> AnyObject! in
                if let error = task.error {
                    if error.domain == AWSS3TransferManagerErrorDomain as String
                        && AWSS3TransferManagerErrorType(rawValue: error.code) == AWSS3TransferManagerErrorType.Paused {
                            print("Download paused.")
                    } else {
                        print("download failed: [\(error)]")
                    }
                } else if let exception = task.exception {
                    print("download failed: [\(exception)]")
                } else {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        if let index = self.indexOfDownloadRequest(self.downloadRequests, downloadRequest: downloadRequest) {
                            self.downloadRequests[index] = nil
                            self.downloadFileURLs[index] = downloadRequest.downloadingFileURL
                            
                            let indexPath = NSIndexPath(forRow: index, inSection: 0)
                            self.collectionView.reloadItemsAtIndexPaths([indexPath])
                        }
                    })
                }
                return nil
            })
            
            break
        default:
            break
        }
    }
    
    func downloadAll() {
        for (_, value) in self.downloadRequests.enumerate() {
            if let downloadRequest = value {
                if downloadRequest.state == .NotStarted
                    || downloadRequest.state == .Paused {
                        self.download(downloadRequest)
                }
            }
        }
        
        self.collectionView.reloadData()
    }
    
    func cancelAllDownloads() {
        for (_, value) in self.downloadRequests.enumerate() {
            if let downloadRequest = value {
                if downloadRequest.state == .Running
                    || downloadRequest.state == .Paused {
                        downloadRequest.cancel().continueWithBlock({ (task) -> AnyObject! in
                            if let error = task.error {
                                print("cancel() failed: [\(error)]")
                            } else if let exception = task.exception {
                                print("cancel() failed: [\(exception)]")
                            }
                            return nil
                        })
                }
            }
        }
        
        self.collectionView.reloadData()
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.downloadRequests.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("DownloadCollectionViewCell", forIndexPath: indexPath) as! DownloadCollectionViewCell
        
        if let downloadRequest = self.downloadRequests[indexPath.row] {
            downloadRequest.downloadProgress = { (bytesWritten, totalBytesWritten, totalBytesExpectedToWrite) -> Void in
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    if totalBytesExpectedToWrite > 0 {
                        cell.progressView.progress = Float(Double(totalBytesWritten) / Double(totalBytesExpectedToWrite));
                    }
                })
            }
            cell.label.hidden = false
            cell.imageView.image = nil
            
            switch downloadRequest.state {
            case .NotStarted, .Paused:
                cell.progressView.progress = 0.0
                cell.label.text = "Download"
                break
                
            case .Running:
                cell.label.text = "Pause"
                break
                
            case .Canceling:
                cell.progressView.progress = 1.0
                cell.label.text = "Cancelled"
                break
                
            default:
                break
            }
        }
        
        if let downloadFileURL = self.downloadFileURLs[indexPath.row] {
            cell.label.hidden = true
            cell.progressView.progress = 1.0
            if let data = NSData(contentsOfURL: downloadFileURL) {
                cell.imageView.image = UIImage(data: data)
            }
        }
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        collectionView.deselectItemAtIndexPath(indexPath, animated: true)
        if let downloadRequest = self.downloadRequests[indexPath.row] {
            
            switch (downloadRequest.state) {
            case .NotStarted, .Paused:
                self.download(downloadRequest)
                break
                
            case .Running:
                downloadRequest.pause().continueWithBlock({ (task) -> AnyObject! in
                    if let error = task.error {
                        print("pause() failed: [\(error)]")
                    } else if let exception = task.exception {
                        print("pause() failed: [\(exception)]")
                    } else {
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            collectionView.reloadItemsAtIndexPaths([indexPath])
                        })
                    }
                    return nil
                })
                break
                
            default:
                break
            }
            
            collectionView.reloadData()
        }
        
        if let downloadFileURL = self.downloadFileURLs[indexPath.row] {
            if let data = NSData(contentsOfURL: downloadFileURL) {
                let imageInfo = JTSImageInfo()
                imageInfo.image = UIImage(data: data)
                
                let imageViewer = JTSImageViewController(
                    imageInfo: imageInfo,
                    mode: .Image,
                    backgroundStyle: .Blurred)
                imageViewer.showFromViewController(self, transition: .FromOffscreen)
            }
        }
    }
    
    func indexOfDownloadRequest(array: Array<AWSS3TransferManagerDownloadRequest?>, downloadRequest: AWSS3TransferManagerDownloadRequest?) -> Int? {
        for (index, object) in array.enumerate() {
            if object == downloadRequest {
                return index
            }
        }
        return nil
    }
}

class DownloadCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var label: UILabel!
}
