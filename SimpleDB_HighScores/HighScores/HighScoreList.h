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

#import <AWSSimpleDB/AWSSimpleDB.h>

#import "HighScore.h"

#define NO_SORT        0
#define PLAYER_SORT    1
#define SCORE_SORT     2


@interface HighScoreList:NSObject {
    AmazonSimpleDBClient *sdbClient;
    NSString             *nextToken;
    int                  sortMethod;
}

@property (nonatomic, retain) NSString *nextToken;

-(id)initWithSortMethod:(int)theSortMethod;
-(int)highScoreCount;
-(NSArray *)getHighScores;
-(NSArray *)getNextPageOfScores;
-(void)addHighScore:(HighScore *)theHighScore;
-(void)removeHighScore:(HighScore *)theHighScore;
-(void)createHighScoresDomain;
-(void)clearHighScores;
-(HighScore *)getPlayer:(NSString *)playerName;


// Utility Methods
-(NSArray *)convertItemsToHighScores:(NSArray *)items;
-(HighScore *)convertSimpleDBItemToHighScore:(SimpleDBItem *)theItem;
-(NSString *)getPlayerNameFromItem:(SimpleDBItem *)theItem;
-(int)getPlayerScoreFromItem:(SimpleDBItem *)theItem;
-(int)getIntValueForAttribute:(NSString *)theAttribute fromList:(NSArray *)attributeList;
-(NSString *)getStringValueForAttribute:(NSString *)theAttribute fromList:(NSArray *)attributeList;
-(NSString *)getPaddedScore:(int)theScore;

@end
