//
// Copyright 2010-2017 Amazon.com, Inc. or its affiliates. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License").
// You may not use this file except in compliance with the License.
// A copy of the License is located at
//
// http://aws.amazon.com/apache2.0
//
// or in the "license" file accompanying this file. This file is distributed
// on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either
// express or implied. See the License for the specific language governing
// permissions and limitations under the License.
//

#import "AppDelegate.h"
#import "Constants.h"
#import <AWSCore/AWSCore.h>
#import <AWSLex/AWSLex.h>

static NSString *AWSLexVoiceButtonIdentifierKey = @"AWSLexVoiceButton";
static NSString *AWSLexChatConfigIdentifierKey = @"chatConfig";

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    AWSCognitoCredentialsProvider *credentialsProvider = [[AWSCognitoCredentialsProvider alloc]
                                                          initWithRegionType:CognitoRegionType
                                                          identityPoolId:CognitoIdentityPoolId];
    
    AWSServiceConfiguration *configuration = [[AWSServiceConfiguration alloc] initWithRegion:LexRegionType credentialsProvider:credentialsProvider];
    
    [AWSServiceManager defaultServiceManager].defaultServiceConfiguration = configuration;
    
    AWSLexInteractionKitConfig *config = [AWSLexInteractionKitConfig defaultInteractionKitConfigWithBotName:BotName botAlias:BotAlias];
    
    [AWSLexInteractionKit registerInteractionKitWithServiceConfiguration:configuration interactionKitConfiguration:config forKey:AWSLexVoiceButtonIdentifierKey];
    
    AWSLexInteractionKitConfig *chatConfig = [AWSLexInteractionKitConfig defaultInteractionKitConfigWithBotName:BotName botAlias:BotAlias];
    chatConfig.autoPlayback = NO;
    [AWSLexInteractionKit registerInteractionKitWithServiceConfiguration:configuration interactionKitConfiguration:chatConfig forKey:AWSLexChatConfigIdentifierKey];

    return YES;
}

@end
