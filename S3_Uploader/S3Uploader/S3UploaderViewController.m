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

#import "S3UploaderViewController.h"
#import "Constants.h"

#import <AWSRuntime/AWSRuntime.h>


@implementation S3UploaderViewController

@synthesize s3 = _s3;

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = @"S3 Uploader";

    if(![ACCESS_KEY_ID isEqualToString:@"CHANGE ME"]
       && self.s3 == nil)
    {
        // Initial the S3 Client.
        //!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        // This sample App is for demonstration purposes only.
        // It is not secure to embed your credentials into source code.
        // DO NOT EMBED YOUR CREDENTIALS IN PRODUCTION APPS.
        // We offer two solutions for getting credentials to your mobile App.
        // Please read the following article to learn about Token Vending Machine:
        // * http://aws.amazon.com/articles/Mobile/4611615499399490
        // Or consider using web identity federation:
        // * http://aws.amazon.com/articles/Mobile/4617974389850313
        //!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        self.s3 = [[[AmazonS3Client alloc] initWithAccessKey:ACCESS_KEY_ID withSecretKey:SECRET_KEY] autorelease];
        self.s3.endpoint = [AmazonEndpoints s3Endpoint:US_WEST_2];

        // Create the picture bucket.
        S3CreateBucketRequest *createBucketRequest = [[[S3CreateBucketRequest alloc] initWithName:[Constants pictureBucket] andRegion:[S3Region USWest2]] autorelease];
        S3CreateBucketResponse *createBucketResponse = [self.s3 createBucket:createBucketRequest];
        if(createBucketResponse.error != nil)
        {
            NSLog(@"Error: %@", createBucketResponse.error);
        }
    }
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if ([ACCESS_KEY_ID isEqualToString:@"CHANGE ME"])
    {
        [self showAlertMessage:CREDENTIALS_ERROR_MESSAGE withTitle:CREDENTIALS_ERROR_TITLE];
    }
}

#pragma mark - Grand Central Dispatch

-(IBAction)uploadPhotoWithGrandCentralDispatch:(id)sender
{
    [self showImagePicker:GrandCentralDispatch];
}

- (void)processGrandCentralDispatchUpload:(NSData *)imageData
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{

        // Upload image data.  Remember to set the content type.
        S3PutObjectRequest *por = [[[S3PutObjectRequest alloc] initWithKey:PICTURE_NAME
                                                                  inBucket:[Constants pictureBucket]] autorelease];
        por.contentType = @"image/jpeg";
        por.data        = imageData;

        // Put the image data into the specified s3 bucket and object.
        S3PutObjectResponse *putObjectResponse = [self.s3 putObject:por];

        dispatch_async(dispatch_get_main_queue(), ^{
            
            if(putObjectResponse.error != nil)
            {
                NSLog(@"Error: %@", putObjectResponse.error);
                [self showAlertMessage:[putObjectResponse.error.userInfo objectForKey:@"message"] withTitle:@"Upload Error"];
            }
            else
            {
                [self showAlertMessage:@"The image was successfully uploaded." withTitle:@"Upload Completed"];
            }

            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        });
    });
}

#pragma mark - AmazonServiceRequestDelegate

-(IBAction)uploadPhotoWithDelegate:(id)sender
{
    [self showImagePicker:Delegate];
}

- (void)processDelegateUpload:(NSData *)imageData
{
    // Upload image data.  Remember to set the content type.
    S3PutObjectRequest *por = [[[S3PutObjectRequest alloc] initWithKey:PICTURE_NAME
                                                              inBucket:[Constants pictureBucket]] autorelease];
    por.contentType = @"image/jpeg";
    por.data = imageData;
    por.delegate = self;

    // Put the image data into the specified s3 bucket and object.
    [self.s3 putObject:por];
}

-(void)request:(AmazonServiceRequest *)request didCompleteWithResponse:(AmazonServiceResponse *)response
{
    [self showAlertMessage:@"The image was successfully uploaded." withTitle:@"Upload Completed"];
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

-(void)request:(AmazonServiceRequest *)request didFailWithError:(NSError *)error
{
    NSLog(@"Error: %@", error);
    [self showAlertMessage:error.description withTitle:@"Upload Error"];
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

#pragma mark - Background Thread

-(IBAction)uploadPhotoWithBackgroundThread:(id)sender
{
    [self showImagePicker:BackgroundThread];
}

- (void)processBackgroundThreadUpload:(NSData *)imageData
{
    [self performSelectorInBackground:@selector(processBackgroundThreadUploadInBackground:)
                           withObject:imageData];
}

- (void)processBackgroundThreadUploadInBackground:(NSData *)imageData
{
    // Upload image data.  Remember to set the content type.
    S3PutObjectRequest *por = [[[S3PutObjectRequest alloc] initWithKey:PICTURE_NAME
                                                              inBucket:[Constants pictureBucket]] autorelease];
    por.contentType = @"image/jpeg";
    por.data        = imageData;

    // Put the image data into the specified s3 bucket and object.
    S3PutObjectResponse *putObjectResponse = [self.s3 putObject:por];
    [self performSelectorOnMainThread:@selector(showCheckErrorMessage:)
                           withObject:putObjectResponse.error
                        waitUntilDone:NO];
}

- (void)showCheckErrorMessage:(NSError *)error
{
    if(error != nil)
    {
        NSLog(@"Error: %@", error);
        [self showAlertMessage:[error.userInfo objectForKey:@"message"] withTitle:@"Upload Error"];
    }
    else
    {
        [self showAlertMessage:@"The image was successfully uploaded." withTitle:@"Upload Completed"];
    }

    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

#pragma mark - Show the image in the browser

-(IBAction)showInBrowser:(id)sender
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        
        // Set the content type so that the browser will treat the URL as an image.
        S3ResponseHeaderOverrides *override = [[[S3ResponseHeaderOverrides alloc] init] autorelease];
        override.contentType = @"image/jpeg";

        // Request a pre-signed URL to picture that has been uplaoded.
        S3GetPreSignedURLRequest *gpsur = [[[S3GetPreSignedURLRequest alloc] init] autorelease];
        gpsur.key                     = PICTURE_NAME;
        gpsur.bucket                  = [Constants pictureBucket];
        gpsur.expires                 = [NSDate dateWithTimeIntervalSinceNow:(NSTimeInterval) 3600]; // Added an hour's worth of seconds to the current time.
        gpsur.responseHeaderOverrides = override;

        // Get the URL
        NSError *error = nil;
        NSURL *url = [self.s3 getPreSignedURL:gpsur error:&error];

        if(url == nil)
        {
            if(error != nil)
            {
                dispatch_async(dispatch_get_main_queue(), ^{

                    NSLog(@"Error: %@", error);
                    [self showAlertMessage:[error.userInfo objectForKey:@"message"] withTitle:@"Browser Error"];
                });
            }
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                // Display the URL in Safari
                [[UIApplication sharedApplication] openURL:url];
            });
        }

    });
}

#pragma mark - UIImagePickerControllerDelegate methods

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    // Get the selected image.
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];

    // Convert the image to JPEG data.
    NSData *imageData = UIImageJPEGRepresentation(image, 1.0);

    if(_uploadType == GrandCentralDispatch)
    {
        [self processGrandCentralDispatchUpload:imageData];
    }
    else if(_uploadType == Delegate)
    {
        [self processDelegateUpload:imageData];
    }
    else if(_uploadType == BackgroundThread)
    {
        [self processBackgroundThreadUpload:imageData];
    }
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];

    [picker dismissModalViewControllerAnimated:YES];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissModalViewControllerAnimated:YES];
}

#pragma mark - Helper Methods

- (void)showImagePicker:(UploadType)uploadType
{
    UIImagePickerController *imagePicker = [[[UIImagePickerController alloc] init] autorelease];
    imagePicker.delegate = self;

    _uploadType = uploadType;

    [self presentModalViewController:imagePicker animated:YES];
}

- (void)showAlertMessage:(NSString *)message withTitle:(NSString *)title
{
    UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:title
                                                         message:message
                                                        delegate:nil
                                               cancelButtonTitle:@"OK"
                                               otherButtonTitles:nil] autorelease];
    [alertView show];
}

#pragma mark -

@end
