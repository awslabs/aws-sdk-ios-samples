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

#import "RequestDelegate.h"
#import <AWSRuntime/AWSRuntime.h>

@implementation RequestDelegate

@synthesize failed;
@synthesize done;
@synthesize responseBody;

-(id)init
{
    if ((self = [super init])) {
        failed       = NO;
        done         = NO;
        receivedData = [[NSMutableData data] retain];
        responseBody = nil;
    }

    return self;
}

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [receivedData setLength:0];
    NSHTTPURLResponse *httpUrlResponse = (NSHTTPURLResponse *)response;
    if ( [httpUrlResponse statusCode] != 200) {
        failed = YES;
    }
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [receivedData appendData:data];
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    AMZLogDebug(@"Error: %@", error);

    [connection release];
    connection = nil;

    responseBody = [error localizedDescription];
    [receivedData release];
    receivedData = nil;

    failed = YES;
    done   = YES;
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [connection release];
    connection = nil;

    responseBody = [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding];
    [receivedData release];
    receivedData = nil;
    done         = YES;
}

-(void)dealloc
{
    [receivedData release];
    [responseBody release];
    [super dealloc];
}

@end

