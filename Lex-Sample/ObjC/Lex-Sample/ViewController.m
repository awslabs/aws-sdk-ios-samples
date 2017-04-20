//
// Copyright 2010-2016 Amazon.com, Inc. or its affiliates. All Rights Reserved.
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

#import "ViewController.h"

@interface ViewController ()<AWSLexVoiceButtonDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.voiceButton.delegate = self;
    // Do any additional setup after loading the view, typically from a nib.
}

#pragma mark - VoiceButtonDelegate Methods

- (void)voiceButton:(AWSLexVoiceButton *)button onResponse:(nonnull AWSLexVoiceButtonResponse *)response{
    // `inputranscript` is the transcript of the voice input to the operation
    NSLog(@"Input Transcript: %@", response.inputTranscript);
    self.input.text = [NSString stringWithFormat:@"\"%@\"", response.inputTranscript];
    NSLog(@"on text output %@", response.outputText);
    self.output.text = response.outputText;
}

- (void)voiceButton:(AWSLexVoiceButton *)button onError:(NSError *)error{
    NSLog(@"error %@", error);
}

#pragma mark -

@end
