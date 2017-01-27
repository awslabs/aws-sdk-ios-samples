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

class UploadViewController: UIViewController, UINavigationControllerDelegate {

    @IBOutlet var progressView: UIProgressView!
    @IBOutlet var statusLabel: UILabel!

    var completionHandler: AWSS3TransferUtilityUploadCompletionHandlerBlock?
    var progressBlock: AWSS3TransferUtilityProgressBlock?
    
    let imagePicker = UIImagePickerController()
    let transferUtility = AWSS3TransferUtility.default()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        self.progressView.progress = 0.0;
        self.statusLabel.text = "Ready"
        self.imagePicker.delegate = self

        self.progressBlock = {(task, progress) in
            DispatchQueue.main.async(execute: {
                self.progressView.progress = Float(progress.fractionCompleted)
                self.statusLabel.text = "Uploading..."
            })
        }

        self.completionHandler = { (task, error) -> Void in
            DispatchQueue.main.async(execute: {
                if let error = error {
                    print("Failed with error: \(error)")
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

    @IBAction func selectAndUpload(_ sender: UIButton) {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    func uploadImage(with data: Data) {
        let expression = AWSS3TransferUtilityUploadExpression()
        expression.progressBlock = progressBlock

        transferUtility.uploadData(
            data,
            bucket: S3BucketName,
            key: S3UploadKeyName,
            contentType: "image/png",
            expression: expression,
            completionHandler: completionHandler).continueWith { (task) -> AnyObject! in
                if let error = task.error {
                    print("Error: \(error.localizedDescription)")
                    self.statusLabel.text = "Failed"
                }
                
                if let _ = task.result {
                    self.statusLabel.text = "Generating Upload File"
                    print("Upload Starting!")
                    // Do something with uploadTask.
                }
                
                return nil;
        }
    }
}

extension UploadViewController: UIImagePickerControllerDelegate {
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if "public.image" == info[UIImagePickerControllerMediaType] as? String {
            let image: UIImage = info[UIImagePickerControllerOriginalImage] as! UIImage
            self.uploadImage(with: UIImagePNGRepresentation(image)!)
        }
        
        
        dismiss(animated: true, completion: nil)
    }
}
