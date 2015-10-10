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

import Foundation

class DDBDynamoDBManger : NSObject {
    class func describeTable() -> AWSTask {
        let dynamoDB = AWSDynamoDB.defaultDynamoDB()
        
        // See if the test table exists.
        let describeTableInput = AWSDynamoDBDescribeTableInput()
        describeTableInput.tableName = AWSSampleDynamoDBTableName
        return dynamoDB.describeTable(describeTableInput)
    }
    
    class func createTable() -> AWSTask {
        let dynamoDB = AWSDynamoDB.defaultDynamoDB()
        
        //Create the test table
        let hashKeyAttributeDefinition = AWSDynamoDBAttributeDefinition()
        hashKeyAttributeDefinition.attributeName = "UserId"
        hashKeyAttributeDefinition.attributeType = AWSDynamoDBScalarAttributeType.S
        
        let hashKeySchemaElement = AWSDynamoDBKeySchemaElement()
        hashKeySchemaElement.attributeName = "UserId"
        hashKeySchemaElement.keyType = AWSDynamoDBKeyType.Hash
        
        let rangeKeyAttributeDefinition = AWSDynamoDBAttributeDefinition()
        rangeKeyAttributeDefinition.attributeName = "GameTitle"
        rangeKeyAttributeDefinition.attributeType = AWSDynamoDBScalarAttributeType.S
        
        let rangeKeySchemaElement = AWSDynamoDBKeySchemaElement()
        rangeKeySchemaElement.attributeName = "GameTitle"
        rangeKeySchemaElement.keyType = AWSDynamoDBKeyType.Range
        
        //Add non-key attributes
        let topScoreAttrDef = AWSDynamoDBAttributeDefinition()
        topScoreAttrDef.attributeName = "TopScore"
        topScoreAttrDef.attributeType = AWSDynamoDBScalarAttributeType.N
        
        let winsAttrDef = AWSDynamoDBAttributeDefinition()
        winsAttrDef.attributeName = "Wins"
        winsAttrDef.attributeType = AWSDynamoDBScalarAttributeType.N
        
        let lossesAttrDef = AWSDynamoDBAttributeDefinition()
        lossesAttrDef.attributeName = "Losses"
        lossesAttrDef.attributeType = AWSDynamoDBScalarAttributeType.N
        
        let provisionedThroughput = AWSDynamoDBProvisionedThroughput()
        provisionedThroughput.readCapacityUnits = 5
        provisionedThroughput.writeCapacityUnits = 5
        
        //Create Global Secondary Index
        let rangeKeyArray = ["TopScore","Wins","Losses"]
        let gsiArray = NSMutableArray()
        
        for rangeKey in rangeKeyArray {
            let gsi = AWSDynamoDBGlobalSecondaryIndex()
            
            let gsiHashKeySchema = AWSDynamoDBKeySchemaElement()
            gsiHashKeySchema.attributeName = "GameTitle"
            gsiHashKeySchema.keyType = AWSDynamoDBKeyType.Hash
            
            let gsiRangeKeySchema = AWSDynamoDBKeySchemaElement()
            gsiRangeKeySchema.attributeName = rangeKey
            gsiRangeKeySchema.keyType = AWSDynamoDBKeyType.Range
            
            let gsiProjection = AWSDynamoDBProjection()
            gsiProjection.projectionType = AWSDynamoDBProjectionType.All;
            
            gsi.keySchema = [gsiHashKeySchema,gsiRangeKeySchema];
            gsi.indexName = rangeKey;
            gsi.projection = gsiProjection;
            gsi.provisionedThroughput = provisionedThroughput;
            
            gsiArray .addObject(gsi)
        }
        
        //Create TableInput
        let createTableInput = AWSDynamoDBCreateTableInput()
        createTableInput.tableName = AWSSampleDynamoDBTableName;
        createTableInput.attributeDefinitions = [hashKeyAttributeDefinition, rangeKeyAttributeDefinition, topScoreAttrDef, winsAttrDef,lossesAttrDef]
        createTableInput.keySchema = [hashKeySchemaElement, rangeKeySchemaElement]
        createTableInput.provisionedThroughput = provisionedThroughput
        createTableInput.globalSecondaryIndexes = gsiArray as [AnyObject]
        
        return dynamoDB.createTable(createTableInput).continueWithSuccessBlock({ (var task:AWSTask!) -> AnyObject! in
            if ((task.result) != nil) {
                // Wait for up to 4 minutes until the table becomes ACTIVE.
                
                let describeTableInput = AWSDynamoDBDescribeTableInput()
                describeTableInput.tableName = AWSSampleDynamoDBTableName;
                task = dynamoDB.describeTable(describeTableInput)
                
                for var i = 0; i < 16; i++ {
                    task = task.continueWithSuccessBlock({ (task:AWSTask!) -> AnyObject! in
                        let describeTableOutput:AWSDynamoDBDescribeTableOutput = task.result as! AWSDynamoDBDescribeTableOutput
                        let tableStatus = describeTableOutput.table.tableStatus
                        if tableStatus == AWSDynamoDBTableStatus.Active {
                            return task
                        }
                        
                        sleep(15)
                        return dynamoDB .describeTable(describeTableInput)
                    })
                }
            }
            
            return task
        })
        
    }
}

class DDBTableRow :AWSDynamoDBObjectModel ,AWSDynamoDBModeling  {
    
    var UserId:String?
    var GameTitle:String?
    
    //set the default values of scores, wins and losses to 0
    var TopScore:NSNumber? = 0
    var Wins:NSNumber? = 0
    var Losses:NSNumber? = 0
    
    //should be ignored according to ignoreAttributes
    var internalName:String?
    var internalState:NSNumber?
    
    class func dynamoDBTableName() -> String! {
        return AWSSampleDynamoDBTableName
    }
    
    class func hashKeyAttribute() -> String! {
        return "UserId"
    }
    
    class func rangeKeyAttribute() -> String! {
        return "GameTitle"
    }
    
    class func ignoreAttributes() -> Array<AnyObject>! {
        return ["internalName","internalState"]
    }
    
    //MARK: NSObjectProtocol hack
    override func isEqual(object: AnyObject?) -> Bool {
        return super.isEqual(object)
    }
    
    override func `self`() -> Self {
        return self
    }
}

