/*
 * Copyright 2010-2014 Amazon.com, Inc. or its affiliates. All Rights Reserved.
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

#import <Foundation/Foundation.h>
#import "DynamoDB.h"

@class DDBTableRow;
@class BFTask;

@interface DDBDynamoDBManager : NSObject

+ (BFTask *)describeTable;
+ (BFTask *)createTable;

@end

@interface DDBTableRow : AWSDynamoDBModel <AWSDynamoDBModeling>

@property (nonatomic, strong) NSString *hashKey;
@property (nonatomic, strong) NSString *rangeKey;
@property (nonatomic, strong) NSString *attribute1;
@property (nonatomic, strong) NSString *attribute2;
@property (nonatomic, strong) NSString *attribute3;

@end
