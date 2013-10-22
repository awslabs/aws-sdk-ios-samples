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

#import "JSONUtilities.h"

@implementation JSONUtilities

+(NSString *)getJSONElement:(NSString *)json element:(NSString *)elementName
{
    NSRange hasElement = [json rangeOfString:elementName];

    if (hasElement.location != NSNotFound) {
        NSRange startSearchRange = { hasElement.location, [json length] - hasElement.location };
        NSRange startRange       = [json rangeOfString:@"\"" options:NSLiteralSearch range:startSearchRange];

        NSRange endSearchRange = { startRange.location + 1, ([json length] - startRange.location) - 1 };
        NSRange endRange       = [json rangeOfString:@"\"" options:NSLiteralSearch range:endSearchRange];

        NSRange elementRange = { startRange.location + 1, endRange.location - startRange.location - 1 };
        return [json substringWithRange:elementRange];
    }

    return nil;
}


@end
