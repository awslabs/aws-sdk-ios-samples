/*
 * Copyright 2010-2013 Amazon.com, Inc. or its affiliates. All Rights Reserved.
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

#import <AWSSNS/AWSSNS.h>
#import <AWSSQS/AWSSQS.h>

@interface MessageBoard:NSObject {
    AmazonSNSClient *snsClient;
    AmazonSQSClient *sqsClient;
    NSString        *topicARN;
    NSString        *queueUrl;
    
    NSString        *endpointARN;
}

+(MessageBoard *)instance;

-(id)init;
-(NSString *)createTopic;
-(bool)createApplicationEndpoint;
-(void)deleteTopic;
-(NSString *)findTopicArn;
-(NSString *)findEndpointARN;
-(bool)subscribeDevice;
-(void)subscribeEmail:(NSString *)emailAddress;
-(void)subscribeSms:(NSString *)smsNumber;
-(void)post:(NSString *)theMessage;
-(bool)pushToMobile:(NSString*)theMessage;
-(NSMutableArray *)listSubscribers;
-(NSMutableArray *)listEndpoints;
-(void)updateEndpointAttributesWithendPointARN:(NSString *)endpointArn Attributes:(NSMutableDictionary *)attributeDic;
-(void)removeSubscriber:(NSString *)subscriptionArn;
-(void)removeEndpoint:(NSString *)endpointArn;
-(NSString *)findQueueUrl;
-(NSMutableArray *)getMessagesFromQueue;
-(void)subscribeQueue;
-(NSString *)createQueue;
-(void)deleteQueue;
-(NSString *)getQueueArn:(NSString *)queueUrl;
-(void)addPolicyToQueueForTopic:(NSString *)queueUrl queueArn:(NSString *)queueArn;
-(NSString *)generateSqsPolicyForTopic:(NSString *)queueArn;
-(void)deleteMessageFromQueue:(SQSMessage *)message;

-(void)changeVisibilityTimeoutForQueue:(NSString*)theQueueUrl toSeconds:(int)seconds;
@end
