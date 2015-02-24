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

#import "DownloadViewController.h"

#import "S3.h"
#import "JTSImageViewController.h"
#import "Constants.h"

@interface DownloadViewController ()

@property (nonatomic, strong) NSMutableArray *collection;

@end

@implementation DownloadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.collection = [NSMutableArray new];
    [self listObjects:self];

    NSError *error = nil;
    if (![[NSFileManager defaultManager] createDirectoryAtPath:[NSTemporaryDirectory() stringByAppendingPathComponent:@"download"]
                                   withIntermediateDirectories:YES
                                                    attributes:nil
                                                         error:&error]) {
        NSLog(@"Creating 'download' directory failed. Error: [%@]", error);
    }
}

#pragma mark - User action methods

- (IBAction)showAlertController:(id)sender {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Available Actions"
                                                                             message:@"Choose your action."
                                                                      preferredStyle:UIAlertControllerStyleActionSheet];

    __weak DownloadViewController *weakSelf = self;
    UIAlertAction *refreshAction = [UIAlertAction actionWithTitle:@"Refresh"
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction *action) {
                                                              DownloadViewController *strongSelf = weakSelf;
                                                              [strongSelf.collection removeAllObjects];
                                                              [strongSelf listObjects:self];
                                                          }];
    [alertController addAction:refreshAction];

    UIAlertAction *downloadAllAction = [UIAlertAction actionWithTitle:@"Download All"
                                                                style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction *action) {
                                                                  DownloadViewController *strongSelf = weakSelf;
                                                                  [strongSelf downloadAll];
                                                              }];
    [alertController addAction:downloadAllAction];

    UIAlertAction *cancelAllDownloadsAction = [UIAlertAction actionWithTitle:@"Cancel All Downloads"
                                                                       style:UIAlertActionStyleDefault
                                                                     handler:^(UIAlertAction *action) {
                                                                         DownloadViewController *strongSelf = weakSelf;
                                                                         [strongSelf cancelAllDownloads:self];
                                                                     }];
    [alertController addAction:cancelAllDownloadsAction];

    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                           style:UIAlertActionStyleCancel
                                                         handler:nil];
    [alertController addAction:cancelAction];

    [self presentViewController:alertController
                       animated:YES
                     completion:nil];
}

- (void)listObjects:(id)sender {
    AWSS3 *s3 = [AWSS3 defaultS3];

    AWSS3ListObjectsRequest *listObjectsRequest = [AWSS3ListObjectsRequest new];
    listObjectsRequest.bucket = S3BucketName;
    [[s3 listObjects:listObjectsRequest] continueWithBlock:^id(BFTask *task) {
        if (task.error) {
            NSLog(@"listObjects failed: [%@]", task.error);
        } else {
            AWSS3ListObjectsOutput *listObjectsOutput = task.result;
            for (AWSS3Object *s3Object in listObjectsOutput.contents) {
                NSString *downloadingFilePath = [[NSTemporaryDirectory() stringByAppendingPathComponent:@"download"] stringByAppendingPathComponent:s3Object.key];
                NSURL *downloadingFileURL = [NSURL fileURLWithPath:downloadingFilePath];

                if ([[NSFileManager defaultManager] fileExistsAtPath:downloadingFilePath]) {
                    [self.collection addObject:downloadingFileURL];
                } else {
                    AWSS3TransferManagerDownloadRequest *downloadRequest = [AWSS3TransferManagerDownloadRequest new];
                    downloadRequest.bucket = S3BucketName;
                    downloadRequest.key = s3Object.key;
                    downloadRequest.downloadingFileURL = downloadingFileURL;
                    [self.collection addObject:downloadRequest];
                }
            }

            dispatch_async(dispatch_get_main_queue(), ^{
                [self.collectionView reloadData];
            });
        }
        return nil;
    }];
}

- (void)download:(AWSS3TransferManagerDownloadRequest *)downloadRequest {
    switch (downloadRequest.state) {
        case AWSS3TransferManagerRequestStateNotStarted:
        case AWSS3TransferManagerRequestStatePaused:
        {
            AWSS3TransferManager *transferManager = [AWSS3TransferManager defaultS3TransferManager];
            [[transferManager download:downloadRequest] continueWithBlock:^id(BFTask *task) {
                if ([task.error.domain isEqualToString:AWSS3TransferManagerErrorDomain]
                    && task.error.code == AWSS3TransferManagerErrorPaused) {
                    NSLog(@"Download paused.");
                } else if (task.error) {
                    NSLog(@"Upload failed: [%@]", task.error);
                } else {
                    __weak DownloadViewController *weakSelf = self;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        DownloadViewController *strongSelf = weakSelf;

                        NSUInteger index = [strongSelf.collection indexOfObject:downloadRequest];
                        [strongSelf.collection replaceObjectAtIndex:index
                                                         withObject:downloadRequest.downloadingFileURL];
                        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index
                                                                    inSection:0];
                        [strongSelf.collectionView reloadItemsAtIndexPaths:@[indexPath]];
                    });
                }
                return nil;
            }];
        }
            break;
        default:
            break;
    }
}

- (void)downloadAll {
    [self.collection enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[AWSS3TransferManagerDownloadRequest class]]) {
            AWSS3TransferManagerDownloadRequest *downloadRequest = obj;
            if (downloadRequest.state == AWSS3TransferManagerRequestStateNotStarted
                || downloadRequest.state == AWSS3TransferManagerRequestStatePaused) {
                [self download:downloadRequest];
            }
        }
    }];

    [self.collectionView reloadData];
}

- (void)cancelAllDownloads:(id)sender {
    [self.collection enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[AWSS3TransferManagerDownloadRequest class]]) {
            AWSS3TransferManagerDownloadRequest *downloadRequest = obj;
            if (downloadRequest.state == AWSS3TransferManagerRequestStateRunning
                || downloadRequest.state == AWSS3TransferManagerRequestStatePaused) {
                [[downloadRequest cancel] continueWithBlock:^id(BFTask *task) {
                    if (task.error) {
                        NSLog(@"The cancel request failed: [%@]", task.error);
                    }
                    return nil;
                }];
            }
        }
    }];

    [self.collectionView reloadData];
}

#pragma mark - Collection View methods

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
    return [self.collection count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    id object = [self.collection objectAtIndex:indexPath.row];
    DownloadCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"DownloadCollectionViewCell"
                                                                                 forIndexPath:indexPath];

    if ([object isKindOfClass:[AWSS3TransferManagerDownloadRequest class]]) {
        AWSS3TransferManagerDownloadRequest *downloadRequest = object;
        downloadRequest.downloadProgress = ^(int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (totalBytesExpectedToWrite > 0) {
                    cell.progressView.progress = (float)((double) totalBytesWritten / totalBytesExpectedToWrite);
                }
            });
        };

        cell.label.hidden = NO;
        cell.imageView.image = nil;
        switch (downloadRequest.state) {
            case AWSS3TransferManagerRequestStateNotStarted:
            case AWSS3TransferManagerRequestStatePaused:
                cell.progressView.progress = 0.0f;
                cell.label.text = @"Download";
                break;

            case AWSS3TransferManagerRequestStateRunning:
                cell.label.text = @"Pause";
                break;

            case AWSS3TransferManagerRequestStateCanceling:
                cell.progressView.progress = 1.0f;
                cell.label.text = @"Cancelled";
                break;

            default:
                break;
        }
    } else if ([object isKindOfClass:[NSURL class]]) {
        cell.label.hidden = YES;
        NSURL *downloadFileURL = object;
        cell.progressView.progress = 1.0f;
        cell.imageView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:downloadFileURL]];
    }

    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    id object = [self.collection objectAtIndex:indexPath.row];

    if ([object isKindOfClass:[AWSS3TransferManagerDownloadRequest class]]) {
        AWSS3TransferManagerDownloadRequest *downloadRequest = object;

        switch (downloadRequest.state) {
            case AWSS3TransferManagerRequestStateNotStarted:
            case AWSS3TransferManagerRequestStatePaused:
                [self download:downloadRequest];
                break;

            case AWSS3TransferManagerRequestStateRunning:
            {
                [[downloadRequest pause] continueWithBlock:^id(BFTask *task) {
                    if (task.error) {
                        NSLog(@"The pause request failed: [%@]", task.error);
                    } else {
                        __weak DownloadViewController *weakSelf = self;
                        dispatch_async(dispatch_get_main_queue(), ^{
                            DownloadViewController *strongSelf = weakSelf;

                            NSUInteger index = [strongSelf.collection indexOfObject:downloadRequest];
                            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index
                                                                        inSection:0];
                            [strongSelf.collectionView reloadItemsAtIndexPaths:@[indexPath]];
                        });
                    }
                    return nil;
                }];
            }
                break;

            default:
                break;
        }

        [self.collectionView reloadData];
    } else if ([object isKindOfClass:[NSURL class]]) {
        NSURL * downloadingFileURL = object;

        JTSImageInfo *imageInfo = [JTSImageInfo new];
        imageInfo.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:downloadingFileURL]];

        JTSImageViewController *imageViewer = [[JTSImageViewController alloc]
                                               initWithImageInfo:imageInfo
                                               mode:JTSImageViewControllerMode_Image
                                               backgroundStyle:JTSImageViewControllerBackgroundOption_Blurred];
        [imageViewer showFromViewController:self
                                 transition:JTSImageViewControllerTransition_FromOffscreen];
    }
}

@end

@implementation DownloadCollectionViewCell

@end
