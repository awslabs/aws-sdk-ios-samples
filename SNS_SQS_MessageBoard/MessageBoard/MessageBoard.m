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
        
        //!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        // This sample App is for demonstration purposes only.
        // It is not secure to embed your credentials into source code.
        // DO NOT EMBED YOUR CREDENTIALS IN PRODUCTION APPS.
        // We offer two solutions for getting credentials to your mobile App.
        // Please read the following article to learn about Token Vending Machine:
        // * http://aws.amazon.com/articles/Mobile/4611615499399490
        // Or consider using web identity federation:
        // * http://aws.amazon.com/articles/Mobile/4617974389850313
        //!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        
        snsClient = [[AmazonSNSClient alloc] initWithAccessKey:ACCESS_KEY_ID withSecretKey:SECRET_KEY];
        snsClient.endpoint = [AmazonEndpoints snsEndpoint:US_EAST_1];

        sqsClient = [[AmazonSQSClient alloc] initWithAccessKey:ACCESS_KEY_ID withSecretKey:SECRET_KEY];
        sqsClient.endpoint = [AmazonEndpoints sqsEndpoint:US_EAST_1];
        
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
        
        // Find endpointARN for this device if there is one.
        endpointARN = [[self findEndpointARN] retain];
        
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

-(bool)createApplicationEndpoint{
    
    NSString *deviceToken = [[NSUserDefaults standardUserDefaults] stringForKey:@"myDeviceToken"];
    if (!deviceToken) {
        [[Constants universalAlertsWithTitle:@"deviceToken not found!" andMessage:@"Device may fail to register with Apple's Notification Service, please check debug window for details"] show];
    }
    
    SNSCreatePlatformEndpointRequest *endpointReq = [[SNSCreatePlatformEndpointRequest alloc] init];
    endpointReq.platformApplicationArn = PLATFORM_APPLICATION_ARN;
    endpointReq.token = deviceToken;
    
    SNSCreatePlatformEndpointResponse *endpointResponse = [snsClient createPlatformEndpoint:endpointReq];
    if (endpointResponse.error != nil) {
        NSLog(@"Error: %@", endpointResponse.error);
        [[Constants universalAlertsWithTitle:@"CreateApplicationEndpoint Error" andMessage:endpointResponse.error.userInfo.description] show];
        return NO;
    }
    
    endpointARN = endpointResponse.endpointArn;
    [[NSUserDefaults standardUserDefaults] setObject:endpointResponse.endpointArn forKey:@"DEVICE_ENDPOINT"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    return YES;
}

-(bool)subscribeDevice {
    if (endpointARN == nil) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [[Constants universalAlertsWithTitle:@"endpointARN not found!" andMessage:@"Please create an endpoint for this device before subscribe to topic"] show];
        });
        return NO;
    }
    
    SNSSubscribeRequest *sr = [[[SNSSubscribeRequest alloc] initWithTopicArn:topicARN andProtocol:@"application" andEndpoint:endpointARN] autorelease];
    SNSSubscribeResponse *subscribeResponse = [snsClient subscribe:sr];
    if(subscribeResponse.error != nil)
    {
        NSLog(@"Error: %@", subscribeResponse.error);
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [[Constants universalAlertsWithTitle:@"Subscription Error" andMessage:subscribeResponse.error.userInfo.description] show];
        });
        
        return NO;
    }
    
    return YES;
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

-(NSMutableArray *)listEndpoints
{
    SNSListEndpointsByPlatformApplicationRequest *le = [[[SNSListEndpointsByPlatformApplicationRequest alloc] init] autorelease];
    le.platformApplicationArn = PLATFORM_APPLICATION_ARN;
    SNSListEndpointsByPlatformApplicationResponse *response = [snsClient listEndpointsByPlatformApplication:le];
    if(response.error != nil)
    {
        NSLog(@"Error: %@", response.error);
        return [NSMutableArray array];
    }
    
    /*
     The results for ListEndpointsByPlatformApplication are paginated and return a limited list of endpoints, up to 100.
     If additional records are available after the first page results, then a NextToken string will be returned. 
     To receive the next page, you call ListEndpointsByPlatformApplication again using the NextToken string received from the previous call. 
     When there are no more records to return, NextToken will be null. 
     For more information, see http://docs.aws.amazon.com/sns/latest/dg/SNSMobilePush.html
    */
    
    return response.endpoints;
}

-(NSMutableArray *)listSubscribers
{
    SNSListSubscriptionsByTopicRequest  *ls       = [[[SNSListSubscriptionsByTopicRequest alloc] initWithTopicArn:topicARN] autorelease];
    SNSListSubscriptionsByTopicResponse *response = [snsClient listSubscriptionsByTopic:ls];
    if(response.error != nil)
    {
        NSLog(@"Error: %@", response.error);
        return [NSMutableArray array];
    }
    
    return response.subscriptions;
}

// update attributes for an endpoint
-(void)updateEndpointAttributesWithendPointARN:(NSString *)endpointArn Attributes:(NSMutableDictionary *)attributeDic {
    SNSSetEndpointAttributesRequest *req = [[[SNSSetEndpointAttributesRequest alloc] init] autorelease];
    req.endpointArn = endpointArn;
    req.attributes = attributeDic;
    SNSSetEndpointAttributesResponse *response = [snsClient setEndpointAttributes:req];
    if (response.error != nil) {
        NSLog(@"Error: %@", response.error);
    }
    
}
// remove an endpoint from endpoints list
-(void)removeEndpoint:(NSString *)endpointArn {
    SNSDeleteEndpointRequest *deleteEndpointReq = [[[SNSDeleteEndpointRequest alloc] init] autorelease];
    deleteEndpointReq.endpointArn = endpointArn;
    SNSDeleteEndpointResponse *response = [snsClient deleteEndpoint:deleteEndpointReq];
    if (response.error != nil) {
        NSLog(@"Error: %@", response.error);
    }
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

//Push a message to Mobile Device
-(bool)pushToMobile:(NSString*)theMessage
{
    SNSPublishRequest *pr = [[SNSPublishRequest alloc] init];
    pr.targetArn = endpointARN;
    pr.message = theMessage;
    
    SNSPublishResponse *publishResponse = [snsClient publish:pr];
    if(publishResponse.error != nil)
    {
        NSLog(@"Error: %@", publishResponse.error);
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [[Constants universalAlertsWithTitle:@"Push to Mobile Error" andMessage:publishResponse.error.userInfo.description] show];
        });
        
        return NO;
    }
    return YES;
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
    [self changeVisibilityTimeoutForQueue:response.queueUrl toSeconds:30]; //Default is 30, can have range between 0 - 43200 seconds
    
    return response.queueUrl;
}

/*
 * This method uses long polling technique for getting the messages from the queue.
 * The visibility timeout is set to 30 seconds at the start.
 * Once all the messages are received a batch operation is run to update the visibility timeout
    of all the recieved messages to 0 seconds so that the messages are again visible.
 * The batch operation to change visibility of multiple messages in a batch has a limit of 10 messages per request. In this code each request is restricted to 10 messages.
 * Developers can also use the Result of the batch operation to get the list of failed messages. Please refer to API docs for more information.
 * http://docs.aws.amazon.com/AWSSimpleQueueService/latest/APIReference/API_ChangeMessageVisibilityBatch.html
 */
-(NSMutableArray *)getMessagesFromQueue
{
    SQSReceiveMessageRequest *rmr = [[[SQSReceiveMessageRequest alloc] initWithQueueUrl:queueUrl] autorelease];
    rmr.maxNumberOfMessages = [NSNumber numberWithInt:10];
    //The visibility timeout is set to 30 seconds for this operation
    rmr.visibilityTimeout   = [NSNumber numberWithInt:30];
    /* A long poll of 3 seconds helps us to fetch more than one message in each recveive message call, when there are not that many number of messages in the queue.
     */
    rmr.waitTimeSeconds = [NSNumber numberWithInt:3];
    
    SQSReceiveMessageResponse *response    = nil;
    NSMutableArray *allMessages = [NSMutableArray array];
    SQSChangeMessageVisibilityBatchRequest *batchRequest = [[SQSChangeMessageVisibilityBatchRequest alloc] init];
    batchRequest.queueUrl = queueUrl;
    SQSChangeMessageVisibilityBatchRequestEntry *batchEntry;
    NSMutableArray *batchRequestList = [NSMutableArray array];
  
    do {
        response = [sqsClient receiveMessage:rmr];
        if(response.error != nil)
        {
            NSLog(@"Error: %@", response.error);
            return [NSMutableArray array];
        }
        [allMessages addObjectsFromArray:response.messages];
    } while ( [response.messages count] != 0);
    
    if([allMessages count] != 0)
    {
        int8_t counter = 0;
        int16_t total = [allMessages count];
        for (SQSMessage *message in allMessages)
        {
            batchEntry = [[SQSChangeMessageVisibilityBatchRequestEntry alloc] init];
            batchEntry.idValue = [message messageId];
            batchEntry.receiptHandle = [message receiptHandle];
            batchEntry.visibilityTimeout = [NSNumber numberWithInt:0];
            [batchRequestList addObject:batchEntry];
            counter++;
            total--;
            if(counter == 10 || total == 0)
            {
                counter = 0;
                batchRequest.entries = batchRequestList;
                SQSChangeMessageVisibilityBatchResponse *batchResponse = nil;
                batchResponse = [sqsClient changeMessageVisibilityBatch:batchRequest];
                batchRequestList = [NSMutableArray array];
            }
        }
        
    }
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

// Change Visibility Timeout for a queue.
// For more details about Visibility timeout, please visit
// http://docs.aws.amazon.com/AWSSimpleQueueService/latest/SQSDeveloperGuide/AboutVT.html
-(void)changeVisibilityTimeoutForQueue:(NSString*)theQueueUrl toSeconds:(int)seconds{
    NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
    [attributes setValue:[NSNumber numberWithInt:seconds] forKey:@"VisibilityTimeout"];
    
    SQSSetQueueAttributesRequest *request = [[[SQSSetQueueAttributesRequest alloc] initWithQueueUrl:theQueueUrl andAttributes:attributes] autorelease];
    SQSSetQueueAttributesResponse *setQueueAttributesResponse = [sqsClient setQueueAttributes:request];
    if(setQueueAttributesResponse.error != nil)
    {
        NSLog(@"Error: %@", setQueueAttributesResponse.error);
    }
    // It can take some time for policy to propagate to the queue.
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

-(NSString *)findEndpointARN
{
    if (endpointARN != nil) {
        return endpointARN;
    }else {
        NSString *storedEndpoint = [[NSUserDefaults standardUserDefaults] stringForKey:@"DEVICE_ENDPOINT"];
        return storedEndpoint;
    }
    
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
