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

#import "Constants.h"

@implementation Constants

+(NSString *)getRandomName
{
    NSArray *nameList = [NSArray arrayWithObjects:@"Norm", @"Jim", @"Jason", @"Zach", @"Matt", @"Glenn", @"Will", @"Wade", @"Trevor", @"Jeremy", @"Ryan", @"Matty", @"Steve", @"Pavel", nil];
    int     name1     = arc4random() % [nameList count];

    return [nameList objectAtIndex:name1];
}

+(NSArray *)getColors
{
    return [NSArray arrayWithObjects:@"Black", @"Blue", @"Green", @"Red", @"Yellow", nil];
}

+(UIAlertView *)errorAlert:(NSString *)message
{
    return [[[UIAlertView alloc] initWithTitle:@"Error" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease];
}

@end
