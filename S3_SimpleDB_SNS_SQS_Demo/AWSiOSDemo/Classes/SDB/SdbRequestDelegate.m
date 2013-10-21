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

#import "SdbRequestDelegate.h"

@implementation SdbRequestDelegate

@synthesize response = _response;
@synthesize error = _error;
@synthesize exception = _exception;
@synthesize bytesIn = _bytesIn;
@synthesize bytesOut = _bytesOut;

-(id)init
{
    self = [super init];
    if (self)
    {
        _response  = nil;
        _exception = nil;
        _error     = nil;
        _bytesIn   = nil;
        _bytesOut  = nil;
    }
    return self;
}

-(bool)isFinishedOrFailed
{
    return (self.response != nil || self.error != nil || self.exception != nil);
}

-(void)request:(AmazonServiceRequest *)request didReceiveResponse:(NSURLResponse *)aResponse
{
    NSLog(@"didReceiveResponse");
}

-(void)request:(AmazonServiceRequest *)request didCompleteWithResponse:(AmazonServiceResponse *)aResponse
{
    NSLog(@"didCompleteWithResponse : %@", aResponse);
    [_response release];
    _response = [aResponse retain];
}

-(void)request:(AmazonServiceRequest *)request didReceiveData:(NSData *)data
{
    NSLog(@"didReceiveData");
    int total = [self.bytesIn.text intValue];
    total       += [data length];
    self.bytesIn.text = [NSString stringWithFormat:@"%d", total];
}

-(void)request:(AmazonServiceRequest *)request didSendData:(long long)bytesWritten totalBytesWritten:(long long)totalBytesWritten totalBytesExpectedToWrite:(long long)totalBytesExpectedToWrite
{
    NSLog(@"didSendData");
    int total = [self.bytesOut.text intValue];
    total        += bytesWritten;
    self.bytesOut.text = [NSString stringWithFormat:@"%d", total];
}

-(void)request:(AmazonServiceRequest *)request didFailWithError:(NSError *)theError
{
    NSLog(@"didFailWithError : %@", theError);
    [_error release];
    _error = [theError retain];
}

-(void)request:(AmazonServiceRequest *)request didFailWithServiceException:(NSException *)theException
{
    NSLog(@"didFailWithServiceException : %@", theException);
    [_exception release];
    _exception = [theException retain];
}

-(void)dealloc
{
    [_error release];
    [_exception release];
    [_response release];
    [_bytesIn release];
    [_bytesOut release];

    [super dealloc];
}

@end