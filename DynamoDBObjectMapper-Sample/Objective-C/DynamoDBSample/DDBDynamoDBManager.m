/*
 * Copyright 2010-2015 Amazon.com, Inc. or its affiliates. All Rights Reserved.
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
#import <AWSDynamoDB/AWSDynamoDB.h>
#import "Constants.h"

@implementation DDBDynamoDBManager

+ (AWSTask *)describeTable {
    AWSDynamoDB *dynamoDB = [AWSDynamoDB defaultDynamoDB];

    // See if the test table exists.
    AWSDynamoDBDescribeTableInput *describeTableInput = [AWSDynamoDBDescribeTableInput new];
    describeTableInput.tableName = AWSSampleDynamoDBTableName;
    return [dynamoDB describeTable:describeTableInput];
}

+ (AWSTask *)createTable {
    AWSDynamoDB *dynamoDB = [AWSDynamoDB defaultDynamoDB];

    // Create the test table.
    AWSDynamoDBAttributeDefinition *hashKeyAttributeDefinition = [AWSDynamoDBAttributeDefinition new];
    hashKeyAttributeDefinition.attributeName = @"UserId";
    hashKeyAttributeDefinition.attributeType = AWSDynamoDBScalarAttributeTypeS;

    AWSDynamoDBKeySchemaElement *hashKeySchemaElement = [AWSDynamoDBKeySchemaElement new];
    hashKeySchemaElement.attributeName = @"UserId";
    hashKeySchemaElement.keyType = AWSDynamoDBKeyTypeHash;

    AWSDynamoDBAttributeDefinition *rangeKeyAttributeDefinition = [AWSDynamoDBAttributeDefinition new];
    rangeKeyAttributeDefinition.attributeName = @"GameTitle";
    rangeKeyAttributeDefinition.attributeType = AWSDynamoDBScalarAttributeTypeS;

    AWSDynamoDBKeySchemaElement *rangeKeySchemaElement = [AWSDynamoDBKeySchemaElement new];
    rangeKeySchemaElement.attributeName = @"GameTitle";
    rangeKeySchemaElement.keyType = AWSDynamoDBKeyTypeRange;

    //Add non-key attributes
    AWSDynamoDBAttributeDefinition *topScoreAttrDef = [AWSDynamoDBAttributeDefinition new];
    topScoreAttrDef.attributeName = @"TopScore";
    topScoreAttrDef.attributeType = AWSDynamoDBScalarAttributeTypeN;
    
    AWSDynamoDBAttributeDefinition *winsAttrDef = [AWSDynamoDBAttributeDefinition new];
    winsAttrDef.attributeName = @"Wins";
    winsAttrDef.attributeType = AWSDynamoDBScalarAttributeTypeN;
    
    AWSDynamoDBAttributeDefinition *lossesAttrDef = [AWSDynamoDBAttributeDefinition new];
    lossesAttrDef.attributeName = @"Losses";
    lossesAttrDef.attributeType = AWSDynamoDBScalarAttributeTypeN;

    AWSDynamoDBProvisionedThroughput *provisionedThroughput = [AWSDynamoDBProvisionedThroughput new];
    provisionedThroughput.readCapacityUnits = @5;
    provisionedThroughput.writeCapacityUnits = @5;

    //Create Global Secondary Index
    NSArray *rangeKeyArray = @[@"TopScore",@"Wins",@"Losses"];
    NSMutableArray *gsiArray = [NSMutableArray new];
    for (NSString *rangeKey in rangeKeyArray) {
        AWSDynamoDBGlobalSecondaryIndex *gsi = [AWSDynamoDBGlobalSecondaryIndex new];
        
        AWSDynamoDBKeySchemaElement *gsiHashKeySchema = [AWSDynamoDBKeySchemaElement new];
        gsiHashKeySchema.attributeName = @"GameTitle";
        gsiHashKeySchema.keyType = AWSDynamoDBKeyTypeHash;
        
        AWSDynamoDBKeySchemaElement *gsiRangeKeySchema = [AWSDynamoDBKeySchemaElement new];
        gsiRangeKeySchema.attributeName = rangeKey;
        gsiRangeKeySchema.keyType = AWSDynamoDBKeyTypeRange;
        
        AWSDynamoDBProjection *gsiProjection = [AWSDynamoDBProjection new];
        gsiProjection.projectionType = AWSDynamoDBProjectionTypeAll;
        
        gsi.keySchema = @[gsiHashKeySchema,gsiRangeKeySchema];
        gsi.indexName = rangeKey;
        gsi.projection = gsiProjection;
        gsi.provisionedThroughput = provisionedThroughput;

        [gsiArray addObject:gsi];
    }
    

    //Create TableInput
    AWSDynamoDBCreateTableInput *createTableInput = [AWSDynamoDBCreateTableInput new];
    createTableInput.tableName = AWSSampleDynamoDBTableName;
    createTableInput.attributeDefinitions = @[hashKeyAttributeDefinition, rangeKeyAttributeDefinition, topScoreAttrDef, winsAttrDef,lossesAttrDef];
    createTableInput.keySchema = @[hashKeySchemaElement, rangeKeySchemaElement];
    createTableInput.provisionedThroughput = provisionedThroughput;
    createTableInput.globalSecondaryIndexes = gsiArray;

    return [[dynamoDB createTable:createTableInput] continueWithSuccessBlock:^id(AWSTask *task) {
        if (task.result) {
            // Wait for up to 4 minutes until the table becomes ACTIVE.

            AWSDynamoDBDescribeTableInput *describeTableInput = [AWSDynamoDBDescribeTableInput new];
            describeTableInput.tableName = AWSSampleDynamoDBTableName;
            task = [dynamoDB describeTable:describeTableInput];

            for(int32_t i = 0; i < 16; i++) {
                task = [task continueWithSuccessBlock:^id(AWSTask *task) {
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
    return @"UserId";
}

+ (NSString *)rangeKeyAttribute {
    return @"GameTitle";
}

@end

@implementation DDBTableRowTopScore

+ (NSString *)dynamoDBTableName {
    return AWSSampleDynamoDBTableName;
}

+ (NSString *)hashKeyAttribute {
    return @"GameTitle";
}

+ (NSString *)rangeKeyAttribute {
    return @"TopScore";
}

@end

@implementation DDBTableRowWins

+ (NSString *)dynamoDBTableName {
    return AWSSampleDynamoDBTableName;
}

+ (NSString *)hashKeyAttribute {
    return @"GameTitle";
}

+ (NSString *)rangeKeyAttribute {
    return @"Wins";
}

@end

@implementation DDBTableRowLosses

+ (NSString *)dynamoDBTableName {
    return AWSSampleDynamoDBTableName;
}

+ (NSString *)hashKeyAttribute {
    return @"GameTitle";
}

+ (NSString *)rangeKeyAttribute {
    return @"Losses";
}

@end
