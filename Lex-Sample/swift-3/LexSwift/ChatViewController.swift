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
import JSQMessagesViewController
import AWSLex

let ClientSenderId = "Client"
let ServerSenderId = "Server"

class ChatViewController: JSQMessagesViewController, JSQMessagesComposerTextViewPasteDelegate {

    var messages: [JSQMessage]?
    var interactionKit: AWSLexInteractionKit?
    var sessionAttributes: [AnyHashable: Any]?
    var outgoingBubbleImageData: JSQMessagesBubbleImage?
    var incomingBubbleImageData: JSQMessagesBubbleImage?
    
    var speechMessage: JSQMessage?
    var speechIndex: Int = 0
    var textModeSwitchingCompletion: AWSTaskCompletionSource<NSString>?
    var count: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        count = 0
        self.interactionKit = AWSLexInteractionKit.init(forKey: "chatConfig")
        self.interactionKit?.interactionDelegate = self
        
        self.showLoadEarlierMessagesHeader = false
        self.collectionView?.collectionViewLayout.incomingAvatarViewSize = CGSize.zero
        self.collectionView?.collectionViewLayout.outgoingAvatarViewSize = CGSize.zero
        
        self.inputToolbar.contentView?.textView?.keyboardType = UIKeyboardType.default
        self.messages = [JSQMessage]()
        
        let bubbleFactory = JSQMessagesBubbleImageFactory()
        self.outgoingBubbleImageData = bubbleFactory?.outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleLightGray())
        self.incomingBubbleImageData = bubbleFactory?.incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleGreen())

        self.inputToolbar.contentView?.leftBarButtonItem = nil;

    }
    
    override func didPressSend(_ button: UIButton, withMessageText text: String, senderId: String, senderDisplayName: String, date: Date) {
        let message = JSQMessage(senderId: senderId, senderDisplayName: senderDisplayName, date: date, text: text)
        self.messages?.append(message!)
        
        if let textModeSwitchingCompletion = textModeSwitchingCompletion {
            textModeSwitchingCompletion.setResult(text as NSString)
            self.textModeSwitchingCompletion = nil
        }
        else {
            self.interactionKit?.text(inTextOut: text)
        }
        self.finishSendingMessage(animated: true)
    }
    
    override var senderDisplayName:String! {
        get{
            return "John Doe"
        }
        set{
            //do nothing
        }
    }
    
    override var senderId:String! {
        get{
            return ClientSenderId
        }
        set{
            //do nothing
        }
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView, messageDataForItemAt indexPath: IndexPath) -> JSQMessageData {
        
        return self.messages![indexPath.item]
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView, didDeleteMessageAt indexPath: IndexPath) {
        //DO NOTHING
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView, messageBubbleImageDataForItemAt indexPath: IndexPath) -> JSQMessageBubbleImageDataSource {
        let message = self.messages![indexPath.item]
        if (message.senderId == self.senderId) {
            return self.outgoingBubbleImageData!
        }
        return self.incomingBubbleImageData!
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView, avatarImageDataForItemAt indexPath: IndexPath) -> JSQMessageAvatarImageDataSource? {
        return nil
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let messages = messages {
            return messages.count
        }
        return 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = (super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell)
        let msg = self.messages?[indexPath.item]
        if !msg!.isMediaMessage {
            if (msg?.senderId == self.senderId) {
                cell.textView?.textColor = UIColor.black
            }
            else {
                cell.textView?.textColor = UIColor.white
            }
        }
        return cell
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView, attributedTextForCellTopLabelAt indexPath: IndexPath) -> NSAttributedString? {
        if indexPath.item % 3 == 0 {
            let message = self.messages?[indexPath.item]
            return JSQMessagesTimestampFormatter.shared().attributedTimestamp(for: message!.date)
        }
        return nil
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView, attributedTextForMessageBubbleTopLabelAt indexPath: IndexPath) -> NSAttributedString? {
        let message = self.messages?[indexPath.item]
        /**
         *  iOS7-style sender name labels
         */
        if (message?.senderId == self.senderId) {
            return nil
        }
        if indexPath.item - 1 > 0 {
            let previousMessage = self.messages?[indexPath.item - 1]
            if (previousMessage?.senderId == message?.senderId) {
                return nil
            }
        }
        /**
         *  Don't specify attributes to use the defaults.
         */
        return NSAttributedString(string: message!.senderDisplayName)
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView, attributedTextForCellBottomLabelAt indexPath: IndexPath) -> NSAttributedString? {
        return nil
    }
    
    public func composerTextView(_ textView: JSQMessagesComposerTextView, shouldPasteWithSender sender: Any) -> Bool {
        return true
    }

}

// MARK: Interaction Kit
extension ChatViewController: AWSLexInteractionDelegate {
    
    public func interactionKitOnRecordingEnd(_ interactionKit: AWSLexInteractionKit, audioStream: Data, contentType: String) {
        DispatchQueue.main.async(execute: {
            let audioItem = JSQAudioMediaItem(data: audioStream)
            self.speechMessage = JSQMessage(senderId: ClientSenderId, displayName: "", media: audioItem)
            
            self.messages?[self.speechIndex] = self.speechMessage!
            self.finishSendingMessage(animated: true)
        })
    }
    
    public func interactionKit(_ interactionKit: AWSLexInteractionKit, onError error: Error) {
        //do nothing for now.
    }
    
    public func interactionKit(_ interactionKit: AWSLexInteractionKit, switchModeInput: AWSLexSwitchModeInput, completionSource: AWSTaskCompletionSource<AWSLexSwitchModeResponse>?) {
        self.sessionAttributes = switchModeInput.sessionAttributes
        DispatchQueue.main.async(execute: {
            let message = JSQMessage(senderId: ServerSenderId, senderDisplayName: "", date: Date(), text: switchModeInput.outputText!)
            self.messages?.append(message!)
            self.finishSendingMessage(animated: true)
        })
        //this can expand to take input from user.
        let switchModeResponse = AWSLexSwitchModeResponse()
        switchModeResponse.interactionMode = AWSLexInteractionMode.text
        switchModeResponse.sessionAttributes = switchModeInput.sessionAttributes
        completionSource?.setResult(switchModeResponse)
    }
    
    /*
     * Sent to delegate when the Switch mode requires a user to input a text. You should set the completion source result to the string that you get from the user. This ensures that the session attribute information is carried over from the previous request to the next one.
     */
    func interactionKitContinue(withText interactionKit: AWSLexInteractionKit, completionSource: AWSTaskCompletionSource<NSString>) {
        textModeSwitchingCompletion = completionSource
    }

}
