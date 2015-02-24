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

#import "UploadViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "S3.h"
#import "Constants.h"

@interface UploadViewController ()

@property (nonatomic, strong) NSMutableArray *collection;

@end

@implementation UploadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.collection = [NSMutableArray new];

    NSError *error = nil;
    if (![[NSFileManager defaultManager] createDirectoryAtPath:[NSTemporaryDirectory() stringByAppendingPathComponent:@"upload"]
                                   withIntermediateDirectories:YES
                                                    attributes:nil
                                                         error:&error]) {
        NSLog(@"reating 'upload' directory failed: [%@]", error);
    }
}

#pragma mark - User action methods

- (IBAction)showAlertController:(id)sender {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Available Actions"
                                                                             message:@"Choose your action."
                                                                      preferredStyle:UIAlertControllerStyleActionSheet];

    __weak UploadViewController *weakSelf = self;
    UIAlertAction *selectPictureAction = [UIAlertAction actionWithTitle:@"Select Pictures"
                                                                  style:UIAlertActionStyleDefault
                                                                handler:^(UIAlertAction *action) {
                                                                    UploadViewController *strongSelf = weakSelf;
                                                                    [strongSelf selectPictures];
                                                                }];
    [alertController addAction:selectPictureAction];

    UIAlertAction *cancelAllUploadsAction = [UIAlertAction actionWithTitle:@"Cancel All Uploads"
                                                                     style:UIAlertActionStyleDefault
                                                                   handler:^(UIAlertAction *action) {
                                                                       UploadViewController *strongSelf = weakSelf;
                                                                       [strongSelf cancelAllDownloads:self];
                                                                   }];
    [alertController addAction:cancelAllUploadsAction];

    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                           style:UIAlertActionStyleCancel
                                                         handler:nil];
    [alertController addAction:cancelAction];

    [self presentViewController:alertController
                       animated:YES
                     completion:nil];
}

- (void)selectPictures {
    ELCImagePickerController *imagePickerController = [ELCImagePickerController new];
    imagePickerController.maximumImagesCount = 20;
    imagePickerController.imagePickerDelegate = self;

    [self presentViewController:imagePickerController
                       animated:YES
                     completion:nil];
}

- (void)upload:(AWSS3TransferManagerUploadRequest *)uploadRequest {
    AWSS3TransferManager *transferManager = [AWSS3TransferManager defaultS3TransferManager];

    __weak UploadViewController *weakSelf = self;
    [[transferManager upload:uploadRequest] continueWithBlock:^id(BFTask *task) {
        if (task.error) {
            if ([task.error.domain isEqualToString:AWSS3TransferManagerErrorDomain]) {
                switch (task.error.code) {
                    case AWSS3TransferManagerErrorCancelled:
                    case AWSS3TransferManagerErrorPaused:
                    {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            UploadViewController *strongSelf = weakSelf;
                            NSUInteger index = [strongSelf.collection indexOfObject:uploadRequest];
                            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index
                                                                        inSection:0];
                            [strongSelf.collectionView reloadItemsAtIndexPaths:@[indexPath]];
                        });
                    }
                        break;

                    default:
                        NSLog(@"Upload failed: [%@]", task.error);
                        break;
                }
            } else {
                NSLog(@"Upload failed: [%@]", task.error);
            }
        }

        if (task.result) {
            dispatch_async(dispatch_get_main_queue(), ^{
                UploadViewController *strongSelf = weakSelf;
                NSUInteger index = [strongSelf.collection indexOfObject:uploadRequest];
                [strongSelf.collection replaceObjectAtIndex:index withObject:uploadRequest.body];
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index
                                                            inSection:0];
                [strongSelf.collectionView reloadItemsAtIndexPaths:@[indexPath]];
            });
        }

        return nil;
    }];
}

- (void)cancelAllDownloads:(id)sender {
    [self.collection enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[AWSS3TransferManagerUploadRequest class]]) {
            AWSS3TransferManagerUploadRequest *uploadRequest = obj;
            [[uploadRequest cancel] continueWithBlock:^id(BFTask *task) {
                if (task.error) {
                    NSLog(@"The cancel request failed: [%@]", task.error);
                }
                return nil;
            }];
        }
    }];
}

#pragma mark - Collection View methods

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
    return [self.collection count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UploadCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"UploadCollectionViewCell"
                                                                               forIndexPath:indexPath];
    id object = [self.collection objectAtIndex:indexPath.row];
    if ([object isKindOfClass:[AWSS3TransferManagerUploadRequest class]]) {
        AWSS3TransferManagerUploadRequest *uploadRequest = object;

        switch (uploadRequest.state) {
            case AWSS3TransferManagerRequestStateRunning: {
                cell.imageView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:uploadRequest.body]];
                cell.label.hidden = YES;

                uploadRequest.uploadProgress = ^(int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (totalBytesExpectedToSend > 0) {
                            cell.progressView.progress = (float)((double) totalBytesSent / totalBytesExpectedToSend);
                        }
                    });
                };
            }
                break;

            case AWSS3TransferManagerRequestStateCanceling:
            {
                cell.imageView.image = nil;
                cell.label.hidden = NO;
                cell.label.text = @"Cancelled";
            }
                break;

            case AWSS3TransferManagerRequestStatePaused:
            {
                cell.imageView.image = nil;
                cell.label.hidden = NO;
                cell.label.text = @"Paused";
            }
                break;

            default:
            {
                cell.imageView.image = nil;
                cell.label.hidden = YES;
            }
                break;
        }
    } else if ([object isKindOfClass:[NSURL class]]) {
        NSURL *downloadFileURL = object;
        cell.imageView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:downloadFileURL]];
        cell.label.hidden = NO;
        cell.label.text = @"Uploaded";
        cell.progressView.progress = 1.0f;
    }

    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    id object = [self.collection objectAtIndex:indexPath.row];

    if ([object isKindOfClass:[AWSS3TransferManagerUploadRequest class]]) {
        AWSS3TransferManagerUploadRequest *uploadRequest = object;
        switch (uploadRequest.state) {
            case AWSS3TransferManagerRequestStateRunning:
                [[uploadRequest pause] continueWithBlock:^id(BFTask *task) {
                    if (task.error) {
                        NSLog(@"The pause request failed: [%@]", task.error);
                    }
                    return nil;
                }];
                break;

            case AWSS3TransferManagerRequestStatePaused:
                [self upload:uploadRequest];
                [self.collectionView reloadItemsAtIndexPaths:@[indexPath]];

                break;

            default:
                break;
        }
    }
}

#pragma mark - ELCImagePickerController delegate methods

- (void)elcImagePickerController:(ELCImagePickerController *)picker
   didFinishPickingMediaWithInfo:(NSArray *)info {
    [self dismissViewControllerAnimated:YES completion:nil];

    for (NSDictionary *imageDictionary in info) {
        if ([ALAssetTypePhoto isEqualToString:imageDictionary[UIImagePickerControllerMediaType]]) {
            UIImage *image = imageDictionary[UIImagePickerControllerOriginalImage];
            NSString *fileName = [[[NSProcessInfo processInfo] globallyUniqueString] stringByAppendingString:@".png"];
            NSString *filePath = [[NSTemporaryDirectory() stringByAppendingPathComponent:@"upload"] stringByAppendingPathComponent:fileName];
            NSData * imageData = UIImagePNGRepresentation(image);

            [imageData writeToFile:filePath atomically:YES];

            AWSS3TransferManagerUploadRequest *uploadRequest = [AWSS3TransferManagerUploadRequest new];
            uploadRequest.body = [NSURL fileURLWithPath:filePath];
            uploadRequest.key = fileName;
            uploadRequest.bucket = S3BucketName;

            [self.collection insertObject:uploadRequest atIndex:0];

            [self upload:uploadRequest];
        }
    }
    
    [self.collectionView reloadData];
}

- (void)elcImagePickerControllerDidCancel:(ELCImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end

@implementation UploadCollectionViewCell

@end
