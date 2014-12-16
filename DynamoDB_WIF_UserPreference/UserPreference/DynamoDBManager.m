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

#import "DynamoDBManager.h"


#import "AmazonClientManager.h"

@implementation DynamoDBManager

/*
 * Creates a table with the following attributes:
 *
 * Table name: TEST_TABLE_NAME
 * Hash key: userNo type N
 * Read Capacity Units: 10
 * Write Capacity Units: 5
 */
+(void)createTable
{
    DynamoDBCreateTableRequest *createTableRequest = [[DynamoDBCreateTableRequest new] autorelease];

    DynamoDBProvisionedThroughput *provisionedThroughput = [[DynamoDBProvisionedThroughput new] autorelease];
    provisionedThroughput.readCapacityUnits  = [NSNumber numberWithInt:10];
    provisionedThroughput.writeCapacityUnits = [NSNumber numberWithInt:5];

    DynamoDBKeySchemaElement *keySchemaElement = [[[DynamoDBKeySchemaElement alloc] initWithAttributeName:TEST_TABLE_HASH_KEY
                                                                                               andKeyType:@"HASH"] autorelease];
    DynamoDBAttributeDefinition *attributeDefinition = [[DynamoDBAttributeDefinition new] autorelease];
    attributeDefinition.attributeName = TEST_TABLE_HASH_KEY;
    attributeDefinition.attributeType = @"N";

    createTableRequest.tableName = TEST_TABLE_NAME;
    createTableRequest.provisionedThroughput = provisionedThroughput;
    [createTableRequest addKeySchema:keySchemaElement];
    [createTableRequest addAttributeDefinition:attributeDefinition];

    DynamoDBCreateTableResponse *response = [[AmazonClientManager ddb] createTable:createTableRequest];
    if(response.error != nil)
    {
        [AmazonClientManager wipeCredentialsOnAuthError:response.error];
        NSLog(@"Error: %@", response.error);
    }
}

/*
 * Retrieves the table description and returns the table status as a string.
 */
+(NSString *)getTestTableStatus
{
    DynamoDBDescribeTableRequest  *request  = [[[DynamoDBDescribeTableRequest alloc] initWithTableName:TEST_TABLE_NAME] autorelease];
    DynamoDBDescribeTableResponse *response = [[AmazonClientManager ddb] describeTable:request];
    if(response.error != nil)
    {
        if([[response.error.userInfo objectForKey:@"exception"] isKindOfClass:[DynamoDBResourceNotFoundException class]])
        {
            return nil;
        }

        [AmazonClientManager wipeCredentialsOnAuthError:response.error];
        NSLog(@"Error: %@", response.error);

        return nil;
    }

    return response.table.tableStatus;
}

/*
 * Inserts ten users with userNo from 1 to 10 and random names.
 */
+(void)insertUsers
{
    for (int i = 1; i <= 10; i++)
    {
        NSMutableDictionary *userDic =
        [NSDictionary dictionaryWithObjectsAndKeys:
         [[[DynamoDBAttributeValue alloc] initWithN:[NSString stringWithFormat:@"%d", i]] autorelease], TEST_TABLE_HASH_KEY,
         [[[DynamoDBAttributeValue alloc] initWithS:[Constants getRandomName]] autorelease], @"firstName",
         [[[DynamoDBAttributeValue alloc] initWithS:[Constants getRandomName]] autorelease], @"lastName",
         nil];

        DynamoDBPutItemRequest *request = [[[DynamoDBPutItemRequest alloc] initWithTableName:TEST_TABLE_NAME andItem:userDic] autorelease];
        DynamoDBPutItemResponse *response = [[AmazonClientManager ddb] putItem:request];
        if(response.error != nil)
        {
            [AmazonClientManager wipeCredentialsOnAuthError:response.error];
            NSLog(@"Error: %@", response.error);

            break;
        }
    }
}

/*
 * Scans the table and returns the list of users.
 */
+(NSMutableArray *)getUserList
{
    DynamoDBScanRequest  *request  = [[[DynamoDBScanRequest alloc] initWithTableName:TEST_TABLE_NAME] autorelease];
    DynamoDBScanResponse *response = [[AmazonClientManager ddb] scan:request];
    if(response.error != nil)
    {
        [AmazonClientManager wipeCredentialsOnAuthError:response.error];
        NSLog(@"Error: %@", response.error);

        return nil;
    }

    return response.items;
}

/*
 * Retrieves all of the attribute/value pairs for the specified user.
 */
+ (NSMutableDictionary *)getUserInfo:(int)userNo
{
    DynamoDBGetItemRequest *getItemRequest = [[DynamoDBGetItemRequest new] autorelease];

    DynamoDBAttributeValue *attributeValue = [[[DynamoDBAttributeValue alloc] initWithN:[NSString stringWithFormat:@"%d", userNo]] autorelease];

    getItemRequest.tableName = TEST_TABLE_NAME;
    getItemRequest.key = [NSMutableDictionary dictionaryWithObject:attributeValue
                                                            forKey:TEST_TABLE_HASH_KEY];

    DynamoDBGetItemResponse *getItemResponse = [[AmazonClientManager ddb] getItem:getItemRequest];
    if(getItemResponse.error != nil)
    {
        [AmazonClientManager wipeCredentialsOnAuthError:getItemResponse.error];
        NSLog(@"Error: %@", getItemResponse.error);

        return nil;
    }

    return getItemResponse.item;
}

/*
 * Updates one attribute/value pair for the specified user.
 */
+(void)updateAttributeStringValue:(NSString *)aValue forKey:(NSString *)aKey withPrimaryKey:(DynamoDBAttributeValue *)aPrimaryKey
{
    DynamoDBUpdateItemRequest *updateItemRequest = [[DynamoDBUpdateItemRequest new] autorelease];

    DynamoDBAttributeValue *attributeValue = [[[DynamoDBAttributeValue alloc] initWithS:aValue] autorelease];
    DynamoDBAttributeValueUpdate *attributeValueUpdate = [[[DynamoDBAttributeValueUpdate alloc] initWithValue:attributeValue
                                                                                                    andAction:@"PUT"] autorelease];


    updateItemRequest.tableName = TEST_TABLE_NAME;
    updateItemRequest.attributeUpdates = [NSMutableDictionary dictionaryWithObject:attributeValueUpdate
                                                                            forKey:aKey];
    updateItemRequest.key = [NSMutableDictionary dictionaryWithObject:aPrimaryKey
                                                               forKey:TEST_TABLE_HASH_KEY];

    DynamoDBUpdateItemResponse *updateItemResponse = [[AmazonClientManager ddb] updateItem:updateItemRequest];
    if(updateItemResponse.error != nil)
    {
        [AmazonClientManager wipeCredentialsOnAuthError:updateItemResponse.error];
        NSLog(@"Error: %@", updateItemResponse.error);
    }
}

/*
 * Deletes the specified user and all of its attribute/value pairs.
 */
+(void)deleteUser:(DynamoDBAttributeValue *)aPrimaryKey
{
    DynamoDBDeleteItemRequest *deleteItemRequest = [[DynamoDBDeleteItemRequest new] autorelease];

    deleteItemRequest.tableName = TEST_TABLE_NAME;
    deleteItemRequest.key = [NSMutableDictionary dictionaryWithObject:aPrimaryKey
                                                               forKey:TEST_TABLE_HASH_KEY];

    DynamoDBDeleteItemResponse *deleteItemResponse = [[AmazonClientManager ddb] deleteItem:deleteItemRequest];
    if(deleteItemResponse.error != nil)
    {
        [AmazonClientManager wipeCredentialsOnAuthError:deleteItemResponse.error];
        NSLog(@"Error: %@", deleteItemResponse.error);
    }
}

/*
 * Deletes the test table and all of its users and their attribute/value pairs.
 */
+(void)cleanUp
{
    DynamoDBDeleteTableRequest *request = [[[DynamoDBDeleteTableRequest alloc] initWithTableName:TEST_TABLE_NAME] autorelease];
    DynamoDBDeleteTableResponse *response = [[AmazonClientManager ddb] deleteTable:request];
    if(response.error != nil)
    {
        [AmazonClientManager wipeCredentialsOnAuthError:response.error];
        NSLog(@"Error: %@", response.error);
    }
}

@end
