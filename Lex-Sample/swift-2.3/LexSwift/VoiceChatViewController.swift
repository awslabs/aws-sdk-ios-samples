//
// Copyright 2010-2016 Amazon.com, Inc. or its affiliates. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License").
// You may not use this file except in compliance with the License.
// A copy of the License is located at
//
// http://aws.amazon.com/apache2.0
//
// or in the "license" file accompanying this file. This file is distributed
// on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either
// express or implied. See the License for the specific language governing
// permissions and limitations under the License.
//

import Foundation
import AWSLex
import UIKit


class VoiceChatViewController: UIViewController, AWSLexVoiceButtonDelegate {
    
    @IBOutlet weak var voiceButton: AWSLexVoiceButton!
    @IBOutlet weak var output: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        (self.voiceButton as AWSLexVoiceButton).delegate = self
        
    }
    
    func voiceButton(button: AWSLexVoiceButton, onResponse response: AWSLexVoiceButtonResponse) {
        dispatch_async(dispatch_get_main_queue(), {
            print("on text output \(response.outputText)")
            self.output.text = response.outputText
        })
    }
    
    func voiceButton(button: AWSLexVoiceButton, onError error: NSError) {
        print("error \(error)")
    }
    
}
