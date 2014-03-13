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

#import "HighScoreList.h"

#import <AWSRuntime/AWSRuntime.h>

#import "Constants.h"


// ========================================================
// This article provides more details on SimpleDB Queries.
// http://aws.amazon.com/articles/1231
// ========================================================

//Modified the macros to use HIGH_SCORE_DOMAIN macro for all the queries

#define HIGH_SCORE_DOMAIN    @"HighScores"

#define PLAYER_ATTRIBUTE     @"player"
#define SCORE_ATTRIBUTE      @"score"

#define COUNT_QUERY          [@"select count(*) from " stringByAppendingString: HIGH_SCORE_DOMAIN]
#define PLAYER_SORT_QUERY    [@"select player, score from "  stringByAppendingString : [HIGH_SCORE_DOMAIN stringByAppendingString: @" where player > '' order by player asc"]]
#define SCORE_SORT_QUERY     [@"select player, score from" stringByAppendingString: [HIGH_SCORE_DOMAIN stringByAppendingString: @"where score >= '0' order by score desc"]]
#define NO_SORT_QUERY        [@"select player, score from " stringByAppendingString: HIGH_SCORE_DOMAIN]


/*
 * This class provides all the functionality for the High Scores list.
 *
 * The class uses SimpleDB to store individuals Items in a Domain.
 * Each Item represents a player and their score.
 */
@implementation HighScoreList


@synthesize nextToken;


-(id)init
{
    self = [super init];
    if (self)
    {
        // Initial the SimpleDB Client.
        sdbClient      = [[AmazonSimpleDBClient alloc] initWithAccessKey:ACCESS_KEY_ID withSecretKey:SECRET_KEY];
        sdbClient.endpoint = [AmazonEndpoints sdbEndpoint:US_WEST_2];

        self.nextToken = nil;
        sortMethod     = NO_SORT;
    }
    
    return self;
}

-(id)initWithSortMethod:(int)theSortMethod
{
    self = [super init];
    if (self)
    {
        // Initial the SimpleDB Client.
        sdbClient      = [[AmazonSimpleDBClient alloc] initWithAccessKey:ACCESS_KEY_ID withSecretKey:SECRET_KEY];
        sdbClient.endpoint = [AmazonEndpoints sdbEndpoint:US_WEST_2];

        self.nextToken = nil;
        sortMethod     = theSortMethod;
    }
    
    return self;
}

/*
 * Method returns the number of items in the High Scores Domain.
 */
-(int)highScoreCount
{
    SimpleDBSelectRequest *selectRequest = [[[SimpleDBSelectRequest alloc] initWithSelectExpression:COUNT_QUERY] autorelease];
    selectRequest.consistentRead = YES;
    
    SimpleDBSelectResponse *selectResponse = [sdbClient select:selectRequest];
    if(selectResponse.error != nil)
    {
        NSLog(@"Error: %@", selectResponse.error);
        return 0;
    }
    
    SimpleDBItem *countItem = [selectResponse.items objectAtIndex:0];
    
    return [self getIntValueForAttribute:@"Count" fromList:countItem.attributes];
}

/*
 * Gets the item from the High Scores domain with the item name equal to 'thePlayer'.
 */
-(HighScore *)getPlayer:(NSString *)thePlayer
{
    SimpleDBGetAttributesRequest *gar = [[SimpleDBGetAttributesRequest alloc] initWithDomainName:HIGH_SCORE_DOMAIN andItemName:thePlayer];
    SimpleDBGetAttributesResponse *response = [sdbClient getAttributes:gar];
    [gar release];
    if(response.error != nil)
    {
        NSLog(@"Error: %@", response.error);
        return nil;
    }
    
    NSString *playerName = [self getStringValueForAttribute:PLAYER_ATTRIBUTE fromList:response.attributes];
    int score = [self getIntValueForAttribute:SCORE_ATTRIBUTE fromList:response.attributes];
    
    return [[[HighScore alloc] initWithPlayer:playerName andScore:score] autorelease];
}

/*
 * Using the pre-defined query, extracts items from the domain in a determined order using the 'select' operation.
 */
-(NSArray *)getHighScores
{
    NSString *query = nil;
    
    switch (sortMethod) {
        case PLAYER_SORT: {
            query = PLAYER_SORT_QUERY;
            break;
        }
            
        case SCORE_SORT: {
            query = SCORE_SORT_QUERY;
            break;
        }
            
        default: {
            query = NO_SORT_QUERY;
        }
    }
    
    SimpleDBSelectRequest *selectRequest = [[[SimpleDBSelectRequest alloc] initWithSelectExpression:query] autorelease];
    selectRequest.consistentRead = YES;
    if (self.nextToken != nil) {
        selectRequest.nextToken = self.nextToken;
    }
    
    SimpleDBSelectResponse *selectResponse = [sdbClient select:selectRequest];
    if(selectResponse.error != nil)
    {
        NSLog(@"Error: %@", selectResponse.error);
        return [NSArray array];
    }
    
    self.nextToken = selectResponse.nextToken;
    
    return [self convertItemsToHighScores:selectResponse.items];
}

/*
 * If a 'nextToken' was returned on the previous query execution, use the next token to get the next batch of items.
 */
-(NSArray *)getNextPageOfScores
{
    if (self.nextToken == nil) {
        return [NSArray array];
    }
    else {
        return [self getHighScores];
    }
}

/*
 * Creates a new item and adds it to the HighScores domain.
 */
-(void)addHighScore:(HighScore *)theHighScore
{
    NSString *paddedScore = [self getPaddedScore:theHighScore.score];
    
    SimpleDBReplaceableAttribute *playerAttribute = [[[SimpleDBReplaceableAttribute alloc] initWithName:PLAYER_ATTRIBUTE andValue:theHighScore.player andReplace:YES] autorelease];
    SimpleDBReplaceableAttribute *scoreAttribute  = [[[SimpleDBReplaceableAttribute alloc] initWithName:SCORE_ATTRIBUTE andValue:paddedScore andReplace:YES] autorelease];
    
    NSMutableArray *attributes = [[[NSMutableArray alloc] initWithCapacity:1] autorelease];
    [attributes addObject:playerAttribute];
    [attributes addObject:scoreAttribute];
    
    SimpleDBPutAttributesRequest *putAttributesRequest = [[[SimpleDBPutAttributesRequest alloc] initWithDomainName:HIGH_SCORE_DOMAIN andItemName:theHighScore.player andAttributes:attributes] autorelease];
    
    SimpleDBPutAttributesResponse *putAttributesResponse = [sdbClient putAttributes:putAttributesRequest];
    if(putAttributesResponse.error != nil)
    {
        NSLog(@"Error: %@", putAttributesResponse.error);
    }
}

/*
 * Removes the item from the HighScores domain.
 * The item removes is the item whose 'player' matches the theHighScore submitted.
 */
-(void)removeHighScore:(HighScore *)theHighScore
{
    @try {
        SimpleDBDeleteAttributesRequest *deleteItem = [[[SimpleDBDeleteAttributesRequest alloc] initWithDomainName:HIGH_SCORE_DOMAIN andItemName:theHighScore.player] autorelease];
        [sdbClient deleteAttributes:deleteItem];
    }
    @catch (NSException *exception) {
        NSLog(@"Exception : [%@]", exception);
    }
}

/*
 * Creates the HighScore domain.
 */
-(void)createHighScoresDomain
{
    SimpleDBCreateDomainRequest *createDomain = [[[SimpleDBCreateDomainRequest alloc] initWithDomainName:HIGH_SCORE_DOMAIN] autorelease];
    SimpleDBCreateDomainResponse *createDomainResponse = [sdbClient createDomain:createDomain];
    if(createDomainResponse.error != nil)
    {
        NSLog(@"Error: %@", createDomainResponse.error);
    }
}

/*
 * Deletes the HighScore domain.
 */
-(void)clearHighScores
{
    SimpleDBDeleteDomainRequest *deleteDomain = [[[SimpleDBDeleteDomainRequest alloc] initWithDomainName:HIGH_SCORE_DOMAIN] autorelease];
    SimpleDBDeleteDomainResponse *deleteDomainResponse = [sdbClient deleteDomain:deleteDomain];
    if(deleteDomainResponse.error != nil)
    {
        NSLog(@"Error: %@", deleteDomainResponse.error);
    }
    
    SimpleDBCreateDomainRequest *createDomain = [[[SimpleDBCreateDomainRequest alloc] initWithDomainName:HIGH_SCORE_DOMAIN] autorelease];
    SimpleDBCreateDomainResponse *createDomainResponse = [sdbClient createDomain:createDomain];
    if(createDomainResponse.error != nil)
    {
        NSLog(@"Error: %@", createDomainResponse.error);
    }
}

/*
 * Converts an array of Items into an array of HighScore objects.
 */
-(NSArray *)convertItemsToHighScores:(NSArray *)theItems
{
    NSMutableArray *highScores = [[[NSMutableArray alloc] initWithCapacity:[theItems count]] autorelease];
    for (SimpleDBItem *item in theItems) {
        [highScores addObject:[self convertSimpleDBItemToHighScore:item]];
    }
    
    return highScores;
}

/*
 * Converts a single SimpleDB Item into a HighScore object.
 */
-(HighScore *)convertSimpleDBItemToHighScore:(SimpleDBItem *)theItem
{
    return [[[HighScore alloc] initWithPlayer:[self getPlayerNameFromItem:theItem] andScore:[self getPlayerScoreFromItem:theItem]] autorelease];
}

/*
 * Extracts the 'player' attribute from the SimpleDB Item.
 */
-(NSString *)getPlayerNameFromItem:(SimpleDBItem *)theItem
{
    return [self getStringValueForAttribute:PLAYER_ATTRIBUTE fromList:theItem.attributes];
}

/*
 * Extracts the 'score' attribute from the SimpleDB Item.
 */
-(int)getPlayerScoreFromItem:(SimpleDBItem *)theItem
{
    return [self getIntValueForAttribute:SCORE_ATTRIBUTE fromList:theItem.attributes];
}

/*
 * Extracts the value for the given attribute from the list of attributes.
 * Extracted value is returned as a NSString.
 */
-(NSString *)getStringValueForAttribute:(NSString *)theAttribute fromList:(NSArray *)attributeList
{
    for (SimpleDBAttribute *attribute in attributeList) {
        if ( [attribute.name isEqualToString:theAttribute]) {
            return attribute.value;
        }
    }
    
    return @"";
}

/*
 * Extracts the value for the given attribute from the list of attributes.
 * Extracted value is returned as an int.
 */
-(int)getIntValueForAttribute:(NSString *)theAttribute fromList:(NSArray *)attributeList
{
    for (SimpleDBAttribute *attribute in attributeList) {
        if ( [attribute.name isEqualToString:theAttribute]) {
            return [attribute.value intValue];
        }
    }
    
    return 0;
}

/*
 * Creates a padded number and returns it as a string.
 * All strings returned will have 10 characters.
 */
-(NSString *)getPaddedScore:(int)theScore
{
    NSString *pad        = @"0000000000";
    NSString *scoreValue = [NSString stringWithFormat:@"%d", theScore];
    
    NSRange  range;
    
    range.location = [pad length] - [scoreValue length];
    range.length   = [scoreValue length];
    
    return [pad stringByReplacingCharactersInRange:range withString:scoreValue];
}

-(void)dealloc
{
    [sdbClient release];
    [nextToken release];
    [super dealloc];
}

@end
