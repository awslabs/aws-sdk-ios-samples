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
    var sessionAttributes: [NSObject : AnyObject]?
    var outgoingBubbleImageData: JSQMessagesBubbleImage?
    var incomingBubbleImageData: JSQMessagesBubbleImage?
    
    var speechMessage: JSQMessage?
    var speechIndex: Int = 0
    var textModeSwitchingCompletion: AWSTaskCompletionSource?
    var count: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        count = 0
        self.interactionKit = AWSLexInteractionKit.init(forKey: "chatConfig")
        self.interactionKit?.interactionDelegate = self
        
        self.showLoadEarlierMessagesHeader = false
        self.collectionView?.collectionViewLayout.incomingAvatarViewSize = CGSizeZero
        self.collectionView?.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero
        
        self.inputToolbar.contentView?.textView?.keyboardType = UIKeyboardType.Default
        self.messages = [JSQMessage]()
        
        let bubbleFactory = JSQMessagesBubbleImageFactory()
        self.outgoingBubbleImageData = bubbleFactory.outgoingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleLightGrayColor())
        self.incomingBubbleImageData = bubbleFactory.incomingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleGreenColor())

        self.inputToolbar.contentView?.leftBarButtonItem = nil;

    }
    
    override func didPressSendButton(button: UIButton, withMessageText text: String, senderId: String, senderDisplayName: String, date: NSDate) {
        let message = JSQMessage(senderId: senderId, senderDisplayName: senderDisplayName, date: date, text: text)
        self.messages?.append(message)
        
        if let textModeSwitchingCompletion = textModeSwitchingCompletion {
            textModeSwitchingCompletion.set(result: text)
            self.textModeSwitchingCompletion = nil
        }
        else {
            self.interactionKit?.textInTextOut(text)
        }
        self.finishSendingMessageAnimated(true)
    }
    
    override var senderDisplayName: String! {
        get{
            return "John Doe"
        }
        set{
            self.senderDisplayName = newValue
        }
    }
    
    override var senderId: String! {
        get{
            return ClientSenderId
        }
        set{
            self.senderId = newValue;
        }
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView, messageDataForItemAtIndexPath indexPath: NSIndexPath) -> JSQMessageData {
        
        return self.messages![indexPath.item]
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView, didDeleteMessageAtIndexPath indexPath: NSIndexPath) {
        //DO NOTHING
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath) -> JSQMessageBubbleImageDataSource {
        let message = self.messages![indexPath.item]
        if (message.senderId == self.senderId) {
            return self.outgoingBubbleImageData!
        }
        return self.incomingBubbleImageData!
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath) -> JSQMessageAvatarImageDataSource? {
        return nil
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let messages = messages {
            return messages.count
        }
        return 0
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {

        let cell = (super.collectionView(collectionView, cellForItemAtIndexPath: indexPath) as! JSQMessagesCollectionViewCell)
        let msg = self.messages?[indexPath.item]
        if !msg!.isMediaMessage {
            if (msg?.senderId == self.senderId) {
                cell.textView?.textColor = UIColor.blackColor()
            }
            else {
                cell.textView?.textColor = UIColor.whiteColor()
            }
        }
        return cell
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView, attributedTextForCellTopLabelAtIndexPath indexPath: NSIndexPath) -> NSAttributedString? {
        if indexPath.item % 3 == 0 {
            let message = self.messages?[indexPath.item]
            return JSQMessagesTimestampFormatter.sharedFormatter().attributedTimestampForDate(message!.date)
        }
        return nil
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView, attributedTextForMessageBubbleTopLabelAtIndexPath indexPath: NSIndexPath) -> NSAttributedString? {
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
    
    override func collectionView(collectionView: JSQMessagesCollectionView, attributedTextForCellBottomLabelAtIndexPath indexPath: NSIndexPath) -> NSAttributedString? {
        return nil
    }
    
    func composerTextView(textView: JSQMessagesComposerTextView, shouldPasteWithSender sender: AnyObject) -> Bool {
        return true
    }

}

// MARK: Interaction Kit
extension ChatViewController: AWSLexInteractionDelegate {
    func interactionKitOnRecordingEnd(interactionKit: AWSLexInteractionKit, audioStream: NSData, contentType: String) {
        dispatch_async(dispatch_get_main_queue(), {
            let audioItem = JSQAudioMediaItem(data: audioStream)
            self.speechMessage = JSQMessage(senderId: ClientSenderId, displayName: "", media: audioItem)
            
            self.messages?[self.speechIndex] = self.speechMessage!
            self.finishSendingMessageAnimated(true)
        })
    }
    
    func interactionKit(interactionKit: AWSLexInteractionKit, onError error: NSError) {
        //do nothing for now.
    }
    
    func interactionKit(interactionKit: AWSLexInteractionKit, switchModeInput: AWSLexSwitchModeInput, completionSource: AWSTaskCompletionSource?) {
        self.sessionAttributes = switchModeInput.sessionAttributes
        dispatch_async(dispatch_get_main_queue(), {
            let message = JSQMessage(senderId: ServerSenderId, senderDisplayName: "", date: NSDate(), text: switchModeInput.outputText!)
            self.messages?.append(message)
            self.finishSendingMessageAnimated(true)
        })
        //this can expand to take input from user.
        let switchModeResponse = AWSLexSwitchModeResponse()
        switchModeResponse.interactionMode = AWSLexInteractionMode.Text
        switchModeResponse.sessionAttributes = switchModeInput.sessionAttributes
        completionSource?.set(result: switchModeResponse)
    }
    
    /*
     * Sent to delegate when the Switch mode requires a user to input a text. You should set the completion source result to the string that you get from the user. This ensures that the session attribute information is carried over from the previous request to the next one.
     */
    func interactionKitContinueWithText(interactionKit: AWSLexInteractionKit, completionSource: AWSTaskCompletionSource) {
        textModeSwitchingCompletion = completionSource
    }

}
