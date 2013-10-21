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

#import "MessageBoard.h"
#import "Constants.h"

#import <AWSRuntime/AWSRuntime.h>


// This singleton class provides all the functionality to manipulate the Amazon
// SNS Topic and Amazon SQS Queue used in this sample application.
@implementation MessageBoard


static MessageBoard *_instance = nil;

+(MessageBoard *)instance
{
    if (!_instance) {
        @synchronized([MessageBoard class])
        {
            if (!_instance) {
                _instance = [self new];
            }
        }
    }
    
    return _instance;
}

-(id)init
{
    self = [super init];
    if (self != nil) {
        snsClient = [[AmazonSNSClient alloc] initWithAccessKey:ACCESS_KEY_ID withSecretKey:SECRET_KEY];
        snsClient.endpoint = [AmazonEndpoints snsEndpoint:US_WEST_2];

        sqsClient = [[AmazonSQSClient alloc] initWithAccessKey:ACCESS_KEY_ID withSecretKey:SECRET_KEY];
        sqsClient.endpoint = [AmazonEndpoints sqsEndpoint:US_WEST_2];
        
        // Find the Topic for this App or create one.
        topicARN = [[self findTopicArn] retain];
        if (topicARN == nil) {
            topicARN = [[self createTopic] retain];
        }
        
        // Find the Queue for this App or create one.
        queueUrl = [[self findQueueUrl] retain];
        if (queueUrl == nil) {
            queueUrl = [[self createQueue] retain];
            
            // Allow time for the queue to be created.
            [NSThread sleepForTimeInterval:4.0];
            
            [self subscribeQueue];
        }
    }
    
    return self;
}

-(NSString *)createTopic
{
    SNSCreateTopicRequest *ctr = [[[SNSCreateTopicRequest alloc] initWithName:TOPIC_NAME] autorelease];
    SNSCreateTopicResponse *response = [snsClient createTopic:ctr];
    if(response.error != nil)
    {
        NSLog(@"Error: %@", response.error);
        return nil;
    }
    
    // Adding the DisplayName attribute to the Topic allows for SMS notifications.
    SNSSetTopicAttributesRequest *st = [[[SNSSetTopicAttributesRequest alloc] initWithTopicArn:response.topicArn andAttributeName:@"DisplayName" andAttributeValue:TOPIC_NAME] autorelease];
    SNSSetTopicAttributesResponse *setTopicAttributesResponse = [snsClient setTopicAttributes:st];
    if(setTopicAttributesResponse.error != nil)
    {
        NSLog(@"Error: %@", setTopicAttributesResponse.error);
        return nil;
    }
    
    return response.topicArn;
}

-(void)subscribeEmail:(NSString *)emailAddress
{
    SNSSubscribeRequest *sr = [[[SNSSubscribeRequest alloc] initWithTopicArn:topicARN andProtocol:@"email" andEndpoint:emailAddress] autorelease];
    SNSSubscribeResponse *subscribeResponse = [snsClient subscribe:sr];
    if(subscribeResponse.error != nil)
    {
        NSLog(@"Error: %@", subscribeResponse.error);
    }
}

-(void)subscribeSms:(NSString *)smsNumber
{
    SNSSubscribeRequest *sr = [[[SNSSubscribeRequest alloc] initWithTopicArn:topicARN andProtocol:@"sms" andEndpoint:smsNumber] autorelease];
    SNSSubscribeResponse *subscribeResponse = [snsClient subscribe:sr];
    if(subscribeResponse.error != nil)
    {
        NSLog(@"Error: %@", subscribeResponse.error);
    }
}

-(void)subscribeQueue
{
    NSString *queueArn = [self getQueueArn:queueUrl];
    
    SNSSubscribeRequest *request = [[[SNSSubscribeRequest alloc] initWithTopicArn:topicARN andProtocol:@"sqs" andEndpoint:queueArn] autorelease];
    SNSSubscribeResponse *subscribeResponse = [snsClient subscribe:request];
    if(subscribeResponse.error != nil)
    {
        NSLog(@"Error: %@", subscribeResponse.error);
    }
}

-(NSMutableArray *)listSubscribers
{
    SNSListSubscriptionsByTopicRequest  *ls       = [[[SNSListSubscriptionsByTopicRequest alloc] initWithTopicArn:topicARN] autorelease];
    SNSListSubscriptionsByTopicResponse *response = [snsClient listSubscriptionsByTopic:ls];
    if(response.error != nil)
    {
        NSLog(@"Error: %@", response.error);
        return [NSArray array];
    }
    
    return response.subscriptions;
}

// Unscribe an endpoint from the topic.
-(void)removeSubscriber:(NSString *)subscriptionArn
{
    SNSUnsubscribeRequest *unsubscribeRequest = [[[SNSUnsubscribeRequest alloc] initWithSubscriptionArn:subscriptionArn] autorelease];
    SNSUnsubscribeResponse *unsubscribeResponse = [snsClient unsubscribe:unsubscribeRequest];
    if(unsubscribeResponse.error != nil)
    {
        NSLog(@"Error: %@", unsubscribeResponse.error);
    }
}

// Post a notification to the topic.
-(void)post:(NSString *)theMessage;
{
    if ( [theMessage isEqualToString:@"wipe"]) {
        [self deleteQueue];
        [self deleteTopic];
    }
    else {
        SNSPublishRequest *pr = [[[SNSPublishRequest alloc] initWithTopicArn:topicARN andMessage:theMessage] autorelease];
        SNSPublishResponse *publishResponse = [snsClient publish:pr];
        if(publishResponse.error != nil)
        {
            NSLog(@"Error: %@", publishResponse.error);
        }
    }
}

-(void)deleteTopic
{
    SNSDeleteTopicRequest *dtr = [[[SNSDeleteTopicRequest alloc] initWithTopicArn:topicARN] autorelease];
    SNSDeleteTopicResponse *deleteTopicResponse = [snsClient deleteTopic:dtr];
    if(deleteTopicResponse.error != nil)
    {
        NSLog(@"Error: %@", deleteTopicResponse.error);
    }
}

-(void)deleteQueue
{
    SQSDeleteQueueRequest *request = [[[SQSDeleteQueueRequest alloc] initWithQueueUrl:queueUrl] autorelease];
    SQSDeleteQueueResponse *deleteQueueResponse = [sqsClient deleteQueue:request];
    if(deleteQueueResponse.error != nil)
    {
        NSLog(@"Error: %@", deleteQueueResponse.error);
    }
}

-(NSString *)createQueue
{
    SQSCreateQueueRequest *cqr = [[[SQSCreateQueueRequest alloc] initWithQueueName:QUEUE_NAME] autorelease];
    SQSCreateQueueResponse *response = [sqsClient createQueue:cqr];
    if(response.error != nil)
    {
        NSLog(@"Error: %@", response.error);
        return nil;
    }
    
    NSString *queueArn = [self getQueueArn:response.queueUrl];
    [self addPolicyToQueueForTopic:response.queueUrl queueArn:queueArn];
    
    return response.queueUrl;
}

-(NSMutableArray *)getMessagesFromQueue
{
    SQSReceiveMessageRequest *rmr = [[[SQSReceiveMessageRequest alloc] initWithQueueUrl:queueUrl] autorelease];
    rmr.maxNumberOfMessages = [NSNumber numberWithInt:10];
    rmr.visibilityTimeout   = [NSNumber numberWithInt:50];
    
    SQSReceiveMessageResponse *response    = nil;
    NSMutableArray *allMessages = [NSMutableArray array];
    do {
        response = [sqsClient receiveMessage:rmr];
        if(response.error != nil)
        {
            NSLog(@"Error: %@", response.error);
            return [NSArray array];
        }
        
        [allMessages addObjectsFromArray:response.messages];
        [NSThread sleepForTimeInterval:0.2];
    } while ( [response.messages count] != 0);
    
    return allMessages;
}

-(void)deleteMessageFromQueue:(SQSMessage *)message
{
    SQSDeleteMessageRequest *request = [[[SQSDeleteMessageRequest alloc] initWithQueueUrl:queueUrl andReceiptHandle:message.receiptHandle] autorelease];
    SQSDeleteMessageResponse *deleteMessageResponse = [sqsClient deleteMessage:request];
    if(deleteMessageResponse.error != nil)
    {
        NSLog(@"Error: %@", deleteMessageResponse.error);
    }
}

// Get the QueueArn attribute from the Queue.  The QueueArn is necessary for create a policy on the queue
// that allows for messages from the Amazon SNS Topic.
-(NSString *)getQueueArn:(NSString *)theQueueUrl
{
    SQSGetQueueAttributesRequest *gqar = [[[SQSGetQueueAttributesRequest alloc] initWithQueueUrl:theQueueUrl] autorelease];
    [gqar.attributeNames addObject:@"QueueArn"];
    
    SQSGetQueueAttributesResponse *response = [sqsClient getQueueAttributes:gqar];
    if(response.error != nil)
    {
        NSLog(@"Error: %@", response.error);
        return nil;
    }
    
    return [response.attributes valueForKey:@"QueueArn"];
}

// Add a policy to a specific queue by setting the queue's Policy attribute.
// Assigning a policy to the queue is necessary as described in Amazon SNS' FAQ:
// http://aws.amazon.com/sns/faqs/#26
-(void)addPolicyToQueueForTopic:(NSString *)theQueueUrl queueArn:(NSString *)queueArn
{
    NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
    [attributes setValue:[self generateSqsPolicyForTopic:queueArn] forKey:@"Policy"];
    
    SQSSetQueueAttributesRequest *request = [[[SQSSetQueueAttributesRequest alloc] initWithQueueUrl:theQueueUrl andAttributes:attributes] autorelease];
    SQSSetQueueAttributesResponse *setQueueAttributesResponse = [sqsClient setQueueAttributes:request];
    if(setQueueAttributesResponse.error != nil)
    {
        NSLog(@"Error: %@", setQueueAttributesResponse.error);
    }
    // It can take some time for policy to propagate to the queue.
}

// Creates the policy object that is necessary to allow the topic to send message to the queue.  The topic will
// send all topic notifications to the queue.
-(NSString *)generateSqsPolicyForTopic:(NSString *)queueArn
{
    NSDictionary *policyDic = [NSDictionary dictionaryWithObjectsAndKeys:
                               @"2008-10-17", @"Version",
                               [NSString stringWithFormat:@"%@/policyId", queueArn], @"Id",
                               [NSArray arrayWithObjects:[NSDictionary dictionaryWithObjectsAndKeys:
                                                          [NSString stringWithFormat:@"%@/statementId", queueArn], @"Sid",
                                                          @"Allow", @"Effect",
                                                          [NSDictionary dictionaryWithObject:@"*" forKey:@"AWS"], @"Principal",
                                                          @"SQS:SendMessage", @"Action",
                                                          queueArn, @"Resource",
                                                          [NSDictionary dictionaryWithObject:
                                                           [NSDictionary dictionaryWithObject:topicARN forKey:@"aws:SourceArn"] forKey:@"StringEquals"], @"Condition",
                                                          nil], 
                                nil], @"Statement",
                               nil];
    AWS_SBJsonWriter *writer = [[AWS_SBJsonWriter new] autorelease];
    
    return [writer stringWithObject:policyDic];
}

// Determines if a topic exists with the given topic name.
// The topic name is assigned in the Constants.h file.
-(NSString *)findTopicArn
{
    NSString *topicNameToFind = [NSString stringWithFormat:@":%@", TOPIC_NAME];
    NSString *nextToken = nil;
    do {
        SNSListTopicsRequest *listTopicsRequest = [[[SNSListTopicsRequest alloc] initWithNextToken:nextToken] autorelease];
        SNSListTopicsResponse *response = [snsClient listTopics:listTopicsRequest];
        if(response.error != nil)
        {
            NSLog(@"Error: %@", response.error);
            return nil;
        }
        
        for (SNSTopic *topic in response.topics) {
            if ( [topic.topicArn hasSuffix:topicNameToFind]) {
                return topic.topicArn;
            }
        }
        
        nextToken = response.nextToken;
    } while (nextToken != nil);
    
    return nil;
}

// Determine if a queue exists with the given queue name.
// The queue name is assigned in the Constants.h file.
-(NSString *)findQueueUrl
{
    NSString *queueNameToFind = [NSString stringWithFormat:@"/%@", QUEUE_NAME];
    
    SQSListQueuesRequest *request = [[SQSListQueuesRequest new] autorelease];
    SQSListQueuesResponse *queuesResponse = [sqsClient listQueues:request];
    if(queuesResponse.error != nil)
    {
        NSLog(@"Error: %@", queuesResponse.error);
        return nil;
    }
    
    for (NSString *qUrl in queuesResponse.queueUrls) {
        if ( [qUrl hasSuffix:queueNameToFind]) {
            return qUrl;
        }
    }
    
    return nil;
}

-(void)dealloc
{
    [topicARN release];
    [queueUrl release];
    [sqsClient release];
    [snsClient release];
    
    [super dealloc];
}

@end
