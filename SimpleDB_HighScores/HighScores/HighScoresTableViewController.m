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

#import "HighScoresTableViewController.h"

#import "PlayerViewController.h"

@implementation HighScoresTableViewController

@synthesize scores = _scores;
@synthesize highScoreList = _highScoreList;

-(id)initWithSortMethod:(int)theSortMethod
{
    self = [super initWithStyle:UITableViewStylePlain];
    if(self)
    {
        self.title = @"High Scores";

        _sortMethod = theSortMethod;
        _highScoreList = [[HighScoreList alloc] initWithSortMethod:self.sortMethod];
        _scores = [[NSMutableArray alloc] initWithCapacity:0];
        _doneLoading = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{

        dispatch_async(dispatch_get_main_queue(), ^{

            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        });

        [self.scores addObjectsFromArray:[self.highScoreList getHighScores]];
        int highScoreCount = [self.highScoreList highScoreCount];

        dispatch_async(dispatch_get_main_queue(), ^{

            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            
            self.title = [NSString stringWithFormat:@"High Scores (%d)", highScoreCount];
            [self.tableView reloadData];
        });
    });
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.scores count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == [self.scores count] - 1
        && _doneLoading == NO) {

        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_async(queue, ^{

            dispatch_async(dispatch_get_main_queue(), ^{

                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
            });

            NSArray *newScores = [self.highScoreList getNextPageOfScores];
            if(newScores == nil || [newScores count] == 0)
            {
                _doneLoading = YES;
            }
            else
            {
                [self.scores addObjectsFromArray:newScores];
            }

            dispatch_async(dispatch_get_main_queue(), ^{

                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                [self.tableView reloadData];
            });
        });
    }

    static NSString *CellIdentifier = @"Cell";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
        cell.textLabel.adjustsFontSizeToFitWidth = YES;
        cell.accessoryType = UITableViewCellStateShowingEditControlMask;
    }

    // Configure the cell...
    HighScore *highScore = [self.scores objectAtIndex:indexPath.row];
    cell.textLabel.text = highScore.player;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%d", highScore.score];

    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    HighScore *highScore = (HighScore *)[self.scores objectAtIndex:indexPath.row];
    PlayerViewController *playerView = [[PlayerViewController alloc] initWithPlayer:highScore];
    [self.navigationController pushViewController:playerView animated:YES];
    [playerView release];
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {

        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_async(queue, ^{

            dispatch_async(dispatch_get_main_queue(), ^{

                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
            });

            HighScore *highScore = (HighScore *)[self.scores objectAtIndex:indexPath.row];
            [self.highScoreList removeHighScore:highScore];

            [self.scores removeObjectAtIndex:indexPath.row];

            dispatch_async(dispatch_get_main_queue(), ^{

                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];

                NSArray *indexPaths = [NSArray arrayWithObjects:indexPath, nil];
                [tableView beginUpdates];
                [tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
                [tableView endUpdates];
            });
        });
    }
}

-(void)dealloc
{
    [_scores release];
    [_highScoreList release];
    
    [super dealloc];
}

@end