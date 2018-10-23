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
import AssetsLibrary
import AWSS3
import ELCImagePickerController

class UploadViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, ELCImagePickerControllerDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var uploadRequests = Array<AWSS3TransferManagerUploadRequest?>()
    var uploadFileURLs = Array<URL?>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        do {
            try FileManager.default.createDirectory(
                at: URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("upload"),
                withIntermediateDirectories: true,
                attributes: nil)
        } catch {
            print("Creating 'upload' directory failed. Error: \(error)")
        }
    }
    
    @IBAction func showAlertController(_ barButtonItem: UIBarButtonItem) {
        let alertController = UIAlertController(
            title: "Available Actions",
            message: "Choose your action.",
            preferredStyle: .actionSheet)
        
        let selectPictureAction = UIAlertAction(
            title: "Select Pictures",
            style: .default) { (action) -> Void in
                self.selectPictures()
        }
        alertController.addAction(selectPictureAction)
        
        let cancelAllUploadsAction = UIAlertAction(
            title: "Cancel All Uploads",
            style: .default) { (action) -> Void in
                self.cancelAllUploads()
        }
        alertController.addAction(cancelAllUploadsAction)
        
        let cancelAction = UIAlertAction(
            title: "Cancel",
            style: .cancel) { (action) -> Void in }
        alertController.addAction(cancelAction)
        
        self.present(
            alertController,
            animated: true) { () -> Void in }
    }
    
    func selectPictures() {
        let imagePickerController = ELCImagePickerController()
        imagePickerController.maximumImagesCount = 20
        imagePickerController.imagePickerDelegate = self
        
        self.present(
            imagePickerController,
            animated: true) { () -> Void in }
    }
    
    func upload(_ uploadRequest: AWSS3TransferManagerUploadRequest) {
        let transferManager = AWSS3TransferManager.default()
        
        transferManager.upload(uploadRequest).continueWith { (task) -> AnyObject! in
            if let error = task.error as NSError? {
                if error.domain == AWSS3TransferManagerErrorDomain as String {
                    if let errorCode = AWSS3TransferManagerErrorType(rawValue: error.code) {
                        switch (errorCode) {
                        case .cancelled, .paused:
                            DispatchQueue.main.async {
                                self.collectionView.reloadData()
                            }
                            break;
                            
                        default:
                            print("upload() failed: [\(error)]")
                            break;
                        }
                    } else {
                        print("upload() failed: [\(error)]")
                    }
                } else {
                    print("upload() failed: [\(error)]")
                }
            }
            
            if task.result != nil {
                DispatchQueue.main.async {
                    if let index = self.indexOfUploadRequest(self.uploadRequests, uploadRequest: uploadRequest) {
                        self.uploadRequests[index] = nil
                        self.uploadFileURLs[index] = uploadRequest.body
                        
                        let indexPath = IndexPath(row: index, section: 0)
                        self.collectionView.reloadItems(at: [indexPath])
                    }
                }
            }
            return nil
        }
    }
    
    func cancelAllUploads() {
        for (_, uploadRequest) in self.uploadRequests.enumerated() {
            if let uploadRequest = uploadRequest {
                uploadRequest.cancel().continueWith(block: { (task) -> AnyObject! in
                    if let error = task.error {
                        print("cancel() failed: [\(error)]")
                    }

                    return nil
                })
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.uploadRequests.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "UploadCollectionViewCell",
            for: indexPath) as! UploadCollectionViewCell
        
        if let uploadRequest = self.uploadRequests[indexPath.row] {
            switch uploadRequest.state {
            case .running:
                if let data = NSData(contentsOf: uploadRequest.body as URL) {
                    cell.imageView.image = UIImage(data: data as Data)
                    cell.label.isHidden = true
                }
                
                uploadRequest.uploadProgress = { (bytesSent, totalBytesSent, totalBytesExpectedToSend) -> Void in
                    DispatchQueue.main.async {
                        if totalBytesExpectedToSend > 0 {
                            cell.progressView.progress = Float(Double(totalBytesSent) / Double(totalBytesExpectedToSend))
                        }
                    }
                }
                
                break;
                
            case .canceling:
                cell.imageView.image = nil
                cell.label.isHidden = false
                cell.label.text = "Cancelled"
                break;
                
            case .paused:
                cell.imageView.image = nil
                cell.label.isHidden = false
                cell.label.text = "Paused"
                break;
                
            default:
                cell.imageView.image = nil
                cell.label.isHidden = true
                break;
            }
        }
        
        if let downloadFileURL = self.uploadFileURLs[indexPath.row] {
            if let data = try? Data(contentsOf: downloadFileURL) {
                cell.imageView.image = UIImage(data: data)
                cell.label.isHidden = false
                cell.label.text = "Uploaded"
                cell.progressView.progress = 1.0
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        if let uploadRequest = self.uploadRequests[indexPath.row] {
            switch uploadRequest.state {
            case .running:
                uploadRequest.pause().continueWith(block: { (task) -> AnyObject! in
                    if let error = task.error {
                        print("pause() failed: [\(error)]")
                    }
                    
                    return nil
                })
                break
                
            case .paused:
                self.upload(uploadRequest)
                collectionView.reloadItems(at: [indexPath])
                break
                
            default:
                break
            }
        }
    }
    
    
    func elcImagePickerController(_ picker: ELCImagePickerController!, didFinishPickingMediaWithInfo info: [Any]!) {
        self.dismiss(animated: true, completion: nil)
        
        for (_, imageDictionary) in info.enumerated() {
            if let imageDictionary = imageDictionary as? Dictionary<String, AnyObject> {
                if let mediaType = imageDictionary[UIImagePickerControllerMediaType] as? String {
                    if mediaType == ALAssetTypePhoto {
                        if let image = imageDictionary[UIImagePickerControllerOriginalImage] as? UIImage {
                            let fileName = ProcessInfo.processInfo.globallyUniqueString + ".png"
                            let fileURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("upload").appendingPathComponent(fileName)
                            let filePath = fileURL.path
                            let imageData = UIImagePNGRepresentation(image)
                            try? imageData!.write(to: URL(fileURLWithPath: filePath), options: [.atomic])
                            
                            let uploadRequest = AWSS3TransferManagerUploadRequest()
                            uploadRequest?.body = fileURL
                            uploadRequest?.key = fileName
                            uploadRequest?.bucket = S3BucketName
                            
                            self.uploadRequests.append(uploadRequest)
                            self.uploadFileURLs.append(nil)
                            
                            self.upload(uploadRequest!)
                        }
                    }
                }
            }
        }
        self.collectionView.reloadData()
    }
    
    func elcImagePickerControllerDidCancel(_ picker: ELCImagePickerController!) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func indexOfUploadRequest(_ array: Array<AWSS3TransferManagerUploadRequest?>, uploadRequest: AWSS3TransferManagerUploadRequest?) -> Int? {
        for (index, object) in array.enumerated() {
            if object == uploadRequest {
                return index
            }
        }
        return nil
    }
}

class UploadCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var label: UILabel!
}
