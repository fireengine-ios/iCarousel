//
//  UploadingImagePreviewController.m
//  Depo
//
//  Created by Mahir on 31/03/15.
//  Copyright (c) 2015 com.igones. All rights reserved.
//

#import "UploadingImagePreviewController.h"
#import "Util.h"
#import "AppDelegate.h"
#import "BaseViewController.h"

@interface UploadingImagePreviewController ()

@end

@implementation UploadingImagePreviewController

@synthesize uploadRef;
@synthesize imageView;
@synthesize progressView;
@synthesize uploadingPhotoLabel;
@synthesize progressLabel;
@synthesize indicator;
@synthesize oldDelegateRef;

- (id) initWithUploadReference:(UploadRef *) ref withImage:(UIImage *) imgRef {
    if(self = [super init]) {
        self.uploadRef = ref;
        self.title = self.uploadRef.fileName;
        self.view.backgroundColor = [Util UIColorForHexColor:@"191e24"];
        
        self.view.autoresizesSubviews = YES;
        self.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;

        imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, self.topIndex + 20, self.view.frame.size.width-20, self.view.frame.size.height - self.bottomIndex - 200)];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        imageView.image = imgRef;
        [self.view addSubview:imageView];
        
        if(self.uploadRef.taskType == UploadTaskTypeFile) {
            UIImage *thumbImageFromCam = [UIImage imageWithContentsOfFile:self.uploadRef.tempUrl];
            imageView.image = [Util imageWithImage:thumbImageFromCam scaledToFillSize:CGSizeMake(40, 40)];
        }
        
        /*
        @autoreleasepool {
            if(self.uploadRef.taskType == UploadTaskTypeAsset) {
                if(self.uploadRef.assetUrl) {
                    NSURL *assetUrl = [NSURL URLWithString:self.uploadRef.assetUrl];
                    ALAssetsLibrary *assetsLibraryForSingle = [[ALAssetsLibrary alloc] init];
                    [assetsLibraryForSingle assetForURL:assetUrl resultBlock:^(ALAsset *myAsset) {
                        if(myAsset) {
                            CGImageRef thumbnailRef = [myAsset.defaultRepresentation fullResolutionImage];
                            if (thumbnailRef) {
                                imageView.image = [UIImage imageWithCGImage:thumbnailRef];
                            }
                        } else {
                            if(imageView.image == nil) {
                                imageView.image = imgRef;
                            }

//                            [assetsLibraryForSingle enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
//                                [group enumerateAssetsWithOptions:NSEnumerationReverse usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
//                                    if([[result.defaultRepresentation.url absoluteString] isEqualToString:self.uploadRef.assetUrl]) {
//                                        CGImageRef thumbnailRef = [result.defaultRepresentation fullResolutionImage];
//                                        if (thumbnailRef) {
//                                            imageView.image = [UIImage imageWithCGImage:thumbnailRef];
//                                        }
//                                    }
//                                }];
//                            } failureBlock:nil];
                        }
                    } failureBlock:nil];
                }
            } else if(self.uploadRef.taskType == UploadTaskTypeFile) {
                UIImage *thumbImageFromCam = [UIImage imageWithContentsOfFile:self.uploadRef.tempUrl];
                imageView.image = [Util imageWithImage:thumbImageFromCam scaledToFillSize:CGSizeMake(40, 40)];
            }
        }
        */
        
        for(UploadManager *manager in [[UploadQueue sharedInstance].uploadManagers copy]) {
            if(!manager.uploadRef.hasFinished && [manager.uploadRef.fileUuid isEqualToString:self.uploadRef.fileUuid]) {
                manager.delegate = self;
            }
        }

        indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        indicator.center = CGPointMake(30, self.view.frame.size.height - 130 - self.bottomIndex);
        [self.view addSubview:indicator];

        uploadingPhotoLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(60, self.view.frame.size.height - 150 - self.bottomIndex, self.view.frame.size.width - 80, 20) withFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:17] withColor:[UIColor whiteColor] withText:NSLocalizedString(@"UploadingPhoto", @"")];
        [self.view addSubview:uploadingPhotoLabel];
        
        progressLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(60, self.view.frame.size.height - 125 - self.bottomIndex, self.view.frame.size.width - 80, 20) withFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:16] withColor:[Util UIColorForHexColor:@"d1d1d1"] withText:@""];
        [self.view addSubview:progressLabel];

        UIView *progressPlaceholderView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-50-self.bottomIndex, self.view.frame.size.width, 2)];
        progressPlaceholderView.backgroundColor = [Util UIColorForHexColor:@"05070b"];
        [self.view addSubview:progressPlaceholderView];

        progressView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-50-self.bottomIndex, 1, 2)];
        progressView.backgroundColor = [Util UIColorForHexColor:@"3fb0e8"];
        progressView.alpha = 0.75f;
        [self.view addSubview:progressView];

        if(self.uploadRef.hasFinishedWithError) {
            uploadingPhotoLabel.text = NSLocalizedString(@"UploadingPhotoFinishedWithError", @"");
            [self updateProgressByWidth:[NSNumber numberWithLong:self.view.frame.size.width] hasError:YES];
            progressView.backgroundColor = [Util UIColorForHexColor:@"ad3110"];
        } else if([self.uploadRef hasFinished]) {
            uploadingPhotoLabel.text = NSLocalizedString(@"UploadingPhotoFinishedSuccessfully", @"");
            [self updateProgressByWidth:[NSNumber numberWithLong:self.view.frame.size.width] hasError:NO];
            progressView.backgroundColor = [Util UIColorForHexColor:@"67d74b"];
        } else {
            [indicator startAnimating];
        }
    }
    return self;
}

- (void) uploadManagerDidSendData:(long)sentBytes inTotal:(long)totalBytes {
    int progressWidth = sentBytes * (self.view.frame.size.width) / totalBytes;
    [self performSelectorOnMainThread:@selector(updateProgressByWidth:) withObject:[NSNumber numberWithInt:progressWidth] waitUntilDone:NO];
}

- (void) updateProgressByWidth:(NSNumber *) newWidth {
    progressView.frame = CGRectMake(0, self.view.frame.size.height-50, [newWidth intValue], 2);
    int percent = [newWidth intValue] * 100 / self.view.frame.size.width;
    progressLabel.text = [NSString stringWithFormat:NSLocalizedString(@"UploadingPhotoCompleteStatus", @""), percent];
}

- (void) updateProgressByWidth:(NSNumber *) newWidth hasError:(BOOL) errorFlag {
    progressView.frame = CGRectMake(0, self.view.frame.size.height-50, [newWidth intValue], 2);
    int percent = [newWidth intValue] * 100 / self.view.frame.size.width;
    if(!errorFlag) {
        progressLabel.text = [NSString stringWithFormat:NSLocalizedString(@"UploadingPhotoCompleteStatus", @""), percent];
    }
}

- (void) uploadManagerDidFailUploadingForAsset:(NSString *) assetToUpload {
    uploadingPhotoLabel.text = NSLocalizedString(@"UploadingPhotoFinishedWithError", @"");
    progressView.backgroundColor = [Util UIColorForHexColor:@"ad3110"];
    [indicator stopAnimating];
}

- (void) uploadManagerQuotaExceedForAsset:(NSString *) assetToUpload {
    uploadingPhotoLabel.text = NSLocalizedString(@"UploadingPhotoFinishedWithError", @"");
    [self updateProgressByWidth:[NSNumber numberWithLong:self.view.frame.size.width] hasError:YES];
    progressView.backgroundColor = [Util UIColorForHexColor:@"ad3110"];
    [indicator stopAnimating];
}

- (void) uploadManagerLoginRequiredForAsset:(NSString *) assetToUpload {
    uploadingPhotoLabel.text = NSLocalizedString(@"UploadingPhotoFinishedWithError", @"");
    [self updateProgressByWidth:[NSNumber numberWithLong:self.view.frame.size.width] hasError:YES];
    progressView.backgroundColor = [Util UIColorForHexColor:@"ad3110"];
    [indicator stopAnimating];
}

- (void) uploadManagerDidFinishUploadingForAsset:(NSString *)assetToUpload withFinalFile:(MetaFile *) finalFile {
    uploadingPhotoLabel.text = NSLocalizedString(@"UploadingPhotoFinishedSuccessfully", @"");
    [self updateProgressByWidth:[NSNumber numberWithLong:self.view.frame.size.width] hasError:NO];
    progressView.backgroundColor = [Util UIColorForHexColor:@"67d74b"];
    [indicator stopAnimating];
}

- (void) uploadManagerDidFailUploadingAsData {
    uploadingPhotoLabel.text = NSLocalizedString(@"UploadingPhotoFinishedWithError", @"");
    [self updateProgressByWidth:[NSNumber numberWithLong:self.view.frame.size.width] hasError:YES];
    progressView.backgroundColor = [Util UIColorForHexColor:@"ad3110"];
    [indicator stopAnimating];
}

- (void) uploadManagerDidFinishUploadingAsData {
    uploadingPhotoLabel.text = NSLocalizedString(@"UploadingPhotoFinishedSuccessfully", @"");
    [self updateProgressByWidth:[NSNumber numberWithLong:self.view.frame.size.width] hasError:NO];
    progressView.backgroundColor = [Util UIColorForHexColor:@"67d74b"];
    [indicator stopAnimating];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.nav setNavigationBarHidden:NO animated:NO];
    
    self.navigationController.navigationBar.barTintColor =[Util UIColorForHexColor:@"191e24"];
    
    [[UINavigationBar appearance] setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:[UIColor colorWithRed:245.0/255.0 green:245.0/255.0 blue:245.0/255.0 alpha:1.0], NSForegroundColorAttributeName, nil]];
    
    [[UINavigationBar appearance] setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys: [UIColor whiteColor], NSForegroundColorAttributeName, [UIFont fontWithName:@"TurkcellSaturaDem" size:18], NSFontAttributeName, nil]];
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [indicator stopAnimating];
    if(oldDelegateRef) {
        for(UploadManager *manager in [[UploadQueue sharedInstance].uploadManagers copy]) {
            if([manager.uploadRef.fileUuid isEqualToString:self.uploadRef.fileUuid]) {
                manager.delegate = oldDelegateRef;
                
                // TODO tekrar kontrol et. Daha sağlıklı bir çözüm varsa kullan.
                SEL postDismissMethod = NULL;
                if(manager.uploadRef.hasFinishedWithError) {
                    postDismissMethod = @selector(uploadManagerDidFailUploadingAsData);
                } else if(manager.uploadRef.hasFinished) {
                    postDismissMethod = @selector(uploadManagerDidFinishUploadingAsData);
                }
                if(postDismissMethod) {
                    if([oldDelegateRef respondsToSelector:postDismissMethod]) {
                        [oldDelegateRef performSelector:postDismissMethod withObject:nil];
                    }
               }
            }
        }
    }

    self.navigationController.navigationBar.barTintColor =[Util UIColorForHexColor:@"3fb0e8"];
    
    [[UINavigationBar appearance] setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:[UIColor colorWithRed:245.0/255.0 green:245.0/255.0 blue:245.0/255.0 alpha:1.0], NSForegroundColorAttributeName, nil]];
    
    [[UINavigationBar appearance] setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys: [UIColor whiteColor], NSForegroundColorAttributeName, [UIFont fontWithName:@"TurkcellSaturaDem" size:18], NSFontAttributeName, nil]];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    CustomButton *customBackButton = [[CustomButton alloc] initWithFrame:CGRectMake(10, 0, 20, 34) withImageName:@"white_left_arrow.png"];
    [customBackButton addTarget:self action:@selector(triggerDismiss) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithCustomView:customBackButton];
    self.navigationItem.leftBarButtonItem = backButton;
}

- (void) triggerDismiss {
    [self dismissViewControllerAnimated:YES completion:nil];
    [APPDELEGATE.base checkAndShowAddButton];
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationPortrait;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    IGLog(@"UploadingImagePreviewController viewDidLoad");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
