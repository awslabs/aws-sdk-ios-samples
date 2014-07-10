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

#import "DDBDynamoDBManager.h"
#import "DynamoDB.h"
#import "Constants.h"

@implementation DDBDynamoDBManager

+ (BFTask *)describeTable {
    AWSDynamoDB *dynamoDB = [AWSDynamoDB defaultDynamoDB];

    // See if the test table exists.
    AWSDynamoDBDescribeTableInput *describeTableInput = [AWSDynamoDBDescribeTableInput new];
    describeTableInput.tableName = AWSSampleDynamoDBTableName;
    return [dynamoDB describeTable:describeTableInput];
}

+ (BFTask *)createTable {
    AWSDynamoDB *dynamoDB = [AWSDynamoDB defaultDynamoDB];

    // Create the test table.
    AWSDynamoDBAttributeDefinition *hashKeyAttributeDefinition = [AWSDynamoDBAttributeDefinition new];
    hashKeyAttributeDefinition.attributeName = @"hashKey";
    hashKeyAttributeDefinition.attributeType = AWSDynamoDBScalarAttributeTypeS;

    AWSDynamoDBKeySchemaElement *hashKeySchemaElement = [AWSDynamoDBKeySchemaElement new];
    hashKeySchemaElement.attributeName = @"hashKey";
    hashKeySchemaElement.keyType = AWSDynamoDBKeyTypeHash;

    AWSDynamoDBAttributeDefinition *rangeKeyAttributeDefinition = [AWSDynamoDBAttributeDefinition new];
    rangeKeyAttributeDefinition.attributeName = @"rangeKey";
    rangeKeyAttributeDefinition.attributeType = AWSDynamoDBScalarAttributeTypeS;

    AWSDynamoDBKeySchemaElement *rangeKeySchemaElement = [AWSDynamoDBKeySchemaElement new];
    rangeKeySchemaElement.attributeName = @"rangeKey";
    rangeKeySchemaElement.keyType = AWSDynamoDBKeyTypeRange;

    AWSDynamoDBProvisionedThroughput *provisionedThroughput = [AWSDynamoDBProvisionedThroughput new];
    provisionedThroughput.readCapacityUnits = @5;
    provisionedThroughput.writeCapacityUnits = @5;

    AWSDynamoDBCreateTableInput *createTableInput = [AWSDynamoDBCreateTableInput new];
    createTableInput.tableName = AWSSampleDynamoDBTableName;
    createTableInput.attributeDefinitions = @[hashKeyAttributeDefinition, rangeKeyAttributeDefinition];
    createTableInput.keySchema = @[hashKeySchemaElement, rangeKeySchemaElement];
    createTableInput.provisionedThroughput = provisionedThroughput;

    return [[dynamoDB createTable:createTableInput] continueWithSuccessBlock:^id(BFTask *task) {
        if (task.result) {
            // Wait for up to 4 minutes until the table becomes ACTIVE.

            AWSDynamoDBDescribeTableInput *describeTableInput = [AWSDynamoDBDescribeTableInput new];
            describeTableInput.tableName = AWSSampleDynamoDBTableName;
            task = [dynamoDB describeTable:describeTableInput];

            for(int32_t i = 0; i < 16; i++) {
                task = [task continueWithSuccessBlock:^id(BFTask *task) {
                    AWSDynamoDBDescribeTableOutput *describeTableOutput = task.result;
                    AWSDynamoDBTableStatus tableStatus = describeTableOutput.table.tableStatus;
                    if (tableStatus == AWSDynamoDBTableStatusActive) {
                        return task;
                    }

                    sleep(15);
                    return [dynamoDB describeTable:describeTableInput];
                }];
            }
        }
        
        return task;
    }];
}

@end

@implementation DDBTableRow

+ (NSString *)dynamoDBTableName {
    return AWSSampleDynamoDBTableName;
}

+ (NSString *)hashKeyAttribute {
    return @"hashKey";
}

+ (NSString *)rangeKeyAttribute {
    return @"rangeKey";
}

- (NSString *)hashKey {
    return [[UIDevice currentDevice].identifierForVendor UUIDString];
}

@end
