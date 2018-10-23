/*
* Copyright 2010-2018 Amazon.com, Inc. or its affiliates. All Rights Reserved.
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
import JTSImageViewController

class DownloadViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var downloadRequests = Array<AWSS3TransferManagerDownloadRequest?>()
    var downloadFileURLs = Array<URL?>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        listObjects()

        do {
            try FileManager.default.createDirectory(
                at: URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("download"),
                withIntermediateDirectories: true,
                attributes: nil)
        } catch {
            print("Creating 'download' directory failed. Error: \(error)")
        }
    }
    
    @IBAction func showAlertController(_ barButtonItem: UIBarButtonItem) {
        let alertController = UIAlertController(
            title: "Available Actions",
            message: "Choose your action.",
            preferredStyle: .actionSheet)
        
        let refreshAction = UIAlertAction(
            title: "Refresh",
            style: .default) { (action) -> Void in
                self.downloadRequests.removeAll(keepingCapacity: false)
                self.downloadFileURLs.removeAll(keepingCapacity: false)
                self.collectionView.reloadData()
                self.listObjects()
        }
        alertController.addAction(refreshAction)
        
        let downloadAllAction = UIAlertAction(
            title: "Download All",
            style: .default) { (action) -> Void in
                self.downloadAll()
        }
        alertController.addAction(downloadAllAction)
        
        let cancelAllDownloadsAction = UIAlertAction(
            title: "Cancel All Downloads",
            style: .default) { (action) -> Void in
                self.cancelAllDownloads()
        }
        alertController.addAction(cancelAllDownloadsAction)
        
        let cancelAction = UIAlertAction(
            title: "Cancel",
            style: .cancel,
            handler: nil)
        alertController.addAction(cancelAction)
        
        self.present(
            alertController,
            animated: true,
            completion: nil)
    }
    
    func listObjects() {
        let s3 = AWSS3.default()
        
        let listObjectsRequest = AWSS3ListObjectsRequest()
        listObjectsRequest?.bucket = S3BucketName
        s3.listObjects(listObjectsRequest!).continueWith { (task) -> AnyObject! in
            if let error = task.error {
                print("listObjects failed: [\(error)]")
            }

            if let listObjectsOutput = task.result {
                if let contents = listObjectsOutput.contents {
                    for s3Object in contents {
                        let downloadingFileURL = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("download")?.appendingPathComponent(s3Object.key!)
                        let downloadingFilePath = downloadingFileURL?.path
                        
                        if FileManager.default.fileExists(atPath: downloadingFilePath!) {
                            self.downloadRequests.append(nil)
                            self.downloadFileURLs.append(downloadingFileURL)
                        } else {
                            let downloadRequest = AWSS3TransferManagerDownloadRequest()
                            downloadRequest?.bucket = S3BucketName
                            downloadRequest?.key = s3Object.key
                            downloadRequest?.downloadingFileURL = downloadingFileURL
                            
                            self.downloadRequests.append(downloadRequest)
                            self.downloadFileURLs.append(nil)
                        }
                    }
                    
                    DispatchQueue.main.async {
                        self.collectionView.reloadData()
                    }
                }
            }
            return nil
        }
    }
    
    func download(_ downloadRequest: AWSS3TransferManagerDownloadRequest) {
        switch (downloadRequest.state) {
        case .notStarted, .paused:
            let transferManager = AWSS3TransferManager.default()
            transferManager.download(downloadRequest).continueWith(block: { (task) -> AnyObject! in
                if let error = task.error as NSError? {
                    if error.domain == AWSS3TransferManagerErrorDomain as String
                        && AWSS3TransferManagerErrorType(rawValue: error.code) == AWSS3TransferManagerErrorType.paused {
                            print("Download paused.")
                    } else {
                        print("download failed: [\(error)]")
                    }
                } else {
                    DispatchQueue.main.async {
                        if let index = self.indexOfDownloadRequest(self.downloadRequests, downloadRequest: downloadRequest) {
                            self.downloadRequests[index] = nil
                            self.downloadFileURLs[index] = downloadRequest.downloadingFileURL
                            
                            let indexPath = NSIndexPath(row: index, section: 0)
                            self.collectionView.reloadItems(at: [indexPath as IndexPath])
                        }
                    }
                }
                return nil
            })
            
            break
        default:
            break
        }
    }
    
    func downloadAll() {
        for (_, value) in self.downloadRequests.enumerated() {
            if let downloadRequest = value {
                if downloadRequest.state == .notStarted
                    || downloadRequest.state == .paused {
                        self.download(downloadRequest)
                }
            }
        }
        
        self.collectionView.reloadData()
    }
    
    func cancelAllDownloads() {
        for (_, value) in self.downloadRequests.enumerated() {
            if let downloadRequest = value {
                if downloadRequest.state == .running
                    || downloadRequest.state == .paused {
                    downloadRequest.cancel().continueWith(block: { (task) -> AnyObject! in
                            if let error = task.error {
                                print("cancel() failed: [\(error)]")
                            }
                        
                            return nil
                        })
                }
            }
        }
        
        self.collectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.downloadRequests.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DownloadCollectionViewCell", for: indexPath) as! DownloadCollectionViewCell
        
        if let downloadRequest = self.downloadRequests[indexPath.row] {
            downloadRequest.downloadProgress = { (bytesWritten, totalBytesWritten, totalBytesExpectedToWrite) -> Void in
                DispatchQueue.main.async {
                    if totalBytesExpectedToWrite > 0 {
                        cell.progressView.progress = Float(Double(totalBytesWritten) / Double(totalBytesExpectedToWrite));
                    }
                }
            }
            cell.label.isHidden = false
            cell.imageView.image = nil
            
            switch downloadRequest.state {
            case .notStarted, .paused:
                cell.progressView.progress = 0.0
                cell.label.text = "Download"
                break
                
            case .running:
                cell.label.text = "Pause"
                break
                
            case .canceling:
                cell.progressView.progress = 1.0
                cell.label.text = "Cancelled"
                break
                
            default:
                break
            }
        }
        
        if let downloadFileURL = self.downloadFileURLs[indexPath.row] {
            cell.label.isHidden = true
            cell.progressView.progress = 1.0
            if let data = try? Data(contentsOf: downloadFileURL) {
                cell.imageView.image = UIImage(data: data)
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        if let downloadRequest = self.downloadRequests[indexPath.row] {
            
            switch (downloadRequest.state) {
            case .notStarted, .paused:
                self.download(downloadRequest)
                break
                
            case .running:
                downloadRequest.pause().continueWith(block: { (task) -> AnyObject! in
                    if let error = task.error {
                        print("pause() failed: [\(error)]")
                    } else {
                        DispatchQueue.main.async {
                            collectionView.reloadItems(at: [indexPath])
                        }
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
            if let data = try? Data(contentsOf: downloadFileURL) {
                let imageInfo = JTSImageInfo()
                imageInfo.image = UIImage(data: data)
                
                let imageViewer = JTSImageViewController(
                    imageInfo: imageInfo,
                    mode: .image,
                    backgroundStyle: .blurred)
                imageViewer?.show(from: self, transition: .fromOffscreen)
            }
        }
    }
    
    func indexOfDownloadRequest(_ array: Array<AWSS3TransferManagerDownloadRequest?>, downloadRequest: AWSS3TransferManagerDownloadRequest?) -> Int? {
        for (index, object) in array.enumerated() {
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
