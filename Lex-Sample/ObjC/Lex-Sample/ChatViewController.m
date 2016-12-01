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

#import "ChatViewController.h"
#import <AWSLex/AWSLex.h>
#import <AWSCore/AWSCore.h>

#define HEIGHT 100;
#define CLIENT_SENDER_ID @"client"
#define SERVER_SENDER_ID @"server"
#define CONFIG_KEY @"chatConfig"

@interface ChatViewController() <AWSLexMicrophoneDelegate, AWSLexInteractionDelegate>

@property (nonatomic, strong) NSMutableArray *messages;

@property (nonatomic, strong) AWSLexInteractionKit *interactionKit;

@property (nonatomic, strong) NSDictionary *sessionAttributes;

@property (strong, nonatomic) JSQMessagesBubbleImage *outgoingBubbleImageData;

@property (strong, nonatomic) JSQMessagesBubbleImage *incomingBubbleImageData;

@end

@implementation ChatViewController{
    JSQMessage *speechMessage;
    NSUInteger speechIndex;
    AWSTaskCompletionSource *textModeSwitchingCompletion;
    NSUInteger count;
}

-(void)viewDidLoad{
    [super viewDidLoad];
    count = 0;
    self.interactionKit = [AWSLexInteractionKit interactionKitForKey:CONFIG_KEY];
    self.interactionKit.interactionDelegate = self;
    self.interactionKit.microphoneDelegate = self;
    
    self.showLoadEarlierMessagesHeader = NO;
    self.collectionView.collectionViewLayout.incomingAvatarViewSize = CGSizeZero;
    self.collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero;
    self.inputToolbar.contentView.textView.keyboardType = UIKeyboardTypeDefault;
    self.messages = [NSMutableArray new];
    
    JSQMessagesBubbleImageFactory *bubbleFactory = [[JSQMessagesBubbleImageFactory alloc] init];
    
    self.outgoingBubbleImageData = [bubbleFactory outgoingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleLightGrayColor]];
    self.incomingBubbleImageData = [bubbleFactory incomingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleGreenColor]];
    self.inputToolbar.contentView.leftBarButtonItem = nil;
}

- (void)didPressSendButton:(UIButton *)button
           withMessageText:(NSString *)text
                  senderId:(NSString *)senderId
         senderDisplayName:(NSString *)senderDisplayName
                      date:(NSDate *)date
{
    JSQMessage *message = [[JSQMessage alloc] initWithSenderId:senderId
                                             senderDisplayName:senderDisplayName
                                                          date:date
                                                          text:text];
    
    [self.messages addObject:message];
    
    if(textModeSwitchingCompletion){
        [textModeSwitchingCompletion setResult:text];
        textModeSwitchingCompletion = nil;
    }else{
        [self.interactionKit textInTextOut:text];
    }
    [self finishSendingMessageAnimated:YES];
}

- (NSString *)senderDisplayName
{
    return @"Sender";
}

- (NSString *)senderId
{
    return CLIENT_SENDER_ID;
}

- (id<JSQMessageData>)collectionView:(JSQMessagesCollectionView *)collectionView messageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.messages objectAtIndex:indexPath.item];
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didDeleteMessageAtIndexPath:(NSIndexPath *)indexPath
{
    //DO NOTHING
}

- (id<JSQMessageBubbleImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView messageBubbleImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    JSQMessage *message = [self.messages objectAtIndex:indexPath.item];
    
    if ([message.senderId isEqualToString:self.senderId]) {
        return self.outgoingBubbleImageData;
    }
    
    return self.incomingBubbleImageData;
}

- (id<JSQMessageAvatarImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView avatarImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.messages count];
}

- (UICollectionViewCell *)collectionView:(JSQMessagesCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessagesCollectionViewCell *cell = (JSQMessagesCollectionViewCell *)[super collectionView:collectionView cellForItemAtIndexPath:indexPath];
    
    JSQMessage *msg = [self.messages objectAtIndex:indexPath.item];
    
    if (!msg.isMediaMessage) {
        
        if ([msg.senderId isEqualToString:self.senderId]) {
            cell.textView.textColor = [UIColor blackColor];
        }else {
            cell.textView.textColor = [UIColor whiteColor];
        }
        
        cell.textView.linkTextAttributes = @{ NSForegroundColorAttributeName : cell.textView.textColor,
                                              NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle | NSUnderlinePatternSolid) };
    }
    
    return cell;
}


- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessage *message = [self.messages objectAtIndex:indexPath.item];
    return [[JSQMessagesTimestampFormatter sharedFormatter] attributedTimestampForDate:message.date];
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessage *message = [self.messages objectAtIndex:indexPath.item];
    
    /**
     *  iOS7-style sender name labels
     */
    if ([message.senderId isEqualToString:self.senderId]) {
        return nil;
    }
    
    if (indexPath.item - 1 > 0) {
        JSQMessage *previousMessage = [self.messages objectAtIndex:indexPath.item - 1];
        if ([[previousMessage senderId] isEqualToString:message.senderId]) {
            return nil;
        }
    }
    
    /**
     *  Don't specify attributes to use the defaults.
     */
    return [[NSAttributedString alloc] initWithString:message.senderDisplayName];
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

- (BOOL)composerTextView:(JSQMessagesComposerTextView *)textView shouldPasteWithSender:(id)sender
{
    return YES;
}

- (void)messageView:(JSQMessagesCollectionView *)view didTapAccessoryButtonAtIndexPath:(NSIndexPath *)path
{
    NSLog(@"Tapped accessory button!");
}

#pragma mark InteractionKit

- (void)interactionKit:(AWSLexInteractionKit *)interactionKit
               onError:(NSError *)error{
    //do nothing for now.
    NSLog(@"error occured %@", error);
}

- (void)interactionKit:(AWSLexInteractionKit *)interactionKit
       switchModeInput:(AWSLexSwitchModeInput *)switchModeInput
      completionSource:(AWSTaskCompletionSource<AWSLexSwitchModeResponse *> *)completionSource{
    
    self.sessionAttributes = switchModeInput.sessionAttributes;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        JSQMessage *message = nil;
        message = [[JSQMessage alloc] initWithSenderId:SERVER_SENDER_ID
                                     senderDisplayName:@""
                                                  date:[[NSDate alloc]init]
                                                  text:switchModeInput.outputText];
        
        [self.messages addObject:message];
        
        [self finishSendingMessageAnimated:YES];
    });
    
    //this can expand to take input from user.
    AWSLexSwitchModeResponse *switchModeResponse = [AWSLexSwitchModeResponse new];
    [switchModeResponse setInteractionMode:AWSLexInteractionModeText];
    [switchModeResponse setSessionAttributes:switchModeInput.sessionAttributes];
    [completionSource setResult:switchModeResponse];
    
}

/*
 * Sent to delegate when the Switch mode requires a user to input a text. You should set the completion source result to the string that you get from the user. This ensures that the session attribute information is carried over from the previous request to the next one.
 */
- (void)interactionKitContinueWithText:(AWSLexInteractionKit *)interactionKit
                      completionSource:(AWSTaskCompletionSource<NSString *> *)completionSource{
    textModeSwitchingCompletion = completionSource;
}
#pragma mark -

@end
