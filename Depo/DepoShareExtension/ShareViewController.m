//
//  ShareViewController.m
//  DepoShareExtension
//
//  Created by Mahir on 16/07/15.
//  Copyright (c) 2015 com.igones. All rights reserved.
//

#import "ShareViewController.h"
#import "ExtensionUploadManager.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <CoreMedia/CoreMedia.h>
#import <AVFoundation/AVFoundation.h>
#import "Reachability.h"
#import "SharedUtil.h"
#import "ImageScale.h"
#import "UIImageView+WebCache.h"
#import "ALAssetRepresentation+MD5.h"

//TODO test -> prod
#define EXT_REMEMBER_ME_URL @"https://adepo.turkcell.com.tr/api/auth/rememberMe"
//#define EXT_REMEMBER_ME_URL @"http://tcloudstb.turkcell.com.tr/api/auth/rememberMe"

//TODO test -> prod
#define EXT_RADIUS_URL @"http://adepo.turkcell.com.tr/api/auth/gsm/login?rememberMe=on"
//#define EXT_RADIUS_URL @"http://tcloudstb.turkcell.com.tr/api/auth/gsm/login?rememberMe=on"

//TODO test -> prod
#define EXT_USER_BASE_URL @"https://adepo.turkcell.com.tr/api/container/baseUrl"
//#define EXT_USER_BASE_URL @"http://tcloudstb.turkcell.com.tr/api/container/baseUrl"

@interface ShareViewController () {
    double totalSize;
    NSData *currentImgData;
}
@property (nonatomic, strong) NSMutableArray *originalImages;
@property (nonatomic, strong) NSMutableArray *originalImagesForCV;
@end

@implementation ShareViewController

@synthesize cancelButton;
@synthesize uploadButton;
@synthesize previewView;
@synthesize loadingView;
@synthesize progressView;
@synthesize alertView;
@synthesize imageLoadingIndicator;
@synthesize uploadIndicator;
@synthesize uploadingLabel;
@synthesize httpSession;
@synthesize urlsToUpload;
@synthesize currentUploadIndex;

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.view.transform = CGAffineTransformMakeTranslation(0, self.view.frame.size.height);
    [UIView animateWithDuration:0.25 animations:^{
        self.view.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        [self uploadFrames];
    }];
}

- (void) uploadFrames {
    cancelButton.frame = CGRectMake(self.view.frame.size.width - 40, cancelButton.frame.origin.y, cancelButton.frame.size.width, cancelButton.frame.size.height);
    previewView.frame = CGRectMake(20, 110, self.view.frame.size.width - 40, (self.view.frame.size.width - 40)*2/3);
    //    imagesScroll.frame = CGRectMake(20, previewView.frame.origin.y + previewView.frame.size.height + 30, self.view.frame.size.width - 40, 50);
    self.imagesCollectionView.frame = CGRectMake(20, previewView.frame.origin.y + previewView.frame.size.height + 30, self.view.frame.size.width - 40, 50);
    imageLoadingIndicator.center = previewView.center;
    uploadButton.frame = CGRectMake(20, previewView.frame.origin.y + previewView.frame.size.height + 110, self.view.frame.size.width - 40, 50);
    loadingView.frame = CGRectMake(20, previewView.frame.origin.y + previewView.frame.size.height + 110, self.view.frame.size.width - 40, 50);
}

- (IBAction) dismiss {
    [UIView animateWithDuration:0.20 animations:^{
        self.view.transform = CGAffineTransformMakeTranslation(0, self.view.frame.size.height);
    } completion:^(BOOL finished) {
        [self.extensionContext completeRequestReturningItems:nil completionHandler:nil];
        [[ExtensionUploadManager sharedInstance] cancelTask];
    }];
}

- (IBAction) preUploadCheck {
    if([SharedUtil readSharedToken] == nil) {
        NetworkStatus networkStatus = [[Reachability reachabilityForInternetConnection] currentReachabilityStatus];
        if(networkStatus == kReachableViaWiFi || networkStatus == kReachableViaWWAN) {
            if([SharedUtil readSharedRememberMeToken] != nil) {
                [self requestToken];
            } else {
                alertView = [[CustomAlertView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) withTitle:NSLocalizedString(@"Error", @"") withMessage:NSLocalizedString(@"ExtLoginRequiredMessage", @"") withModalType:ModalTypeError];
                alertView.delegate = self;
                [alertView reorientateModalView:self.view.center];
                [self.view addSubview:alertView];
                [self.view bringSubviewToFront:alertView];
            }
        } else {
            alertView = [[CustomAlertView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) withTitle:NSLocalizedString(@"Error", @"") withMessage:NSLocalizedString(@"ConnectionErrorWarning", @"") withModalType:ModalTypeError];
            alertView.delegate = self;
            [alertView reorientateModalView:self.view.center];
            [self.view addSubview:alertView];
            [self.view bringSubviewToFront:alertView];
        }
    } else if([SharedUtil readSharedBaseUrl] == nil) {
        [self requestBaseUrl];
    } else {
        [self startUpload];
    }
}

- (IBAction) startUpload {
    
    if (currentUploadIndex == NSNotFound) {
        currentUploadIndex = 0;
    }
    
    NSDictionary *dict = [urlsToUpload objectAtIndex:currentUploadIndex];
    if(dict != nil) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            uploadButton.hidden = YES;
            uploadButton.enabled = NO;
            loadingView.hidden = NO;
            
            uploadingLabel.text = NSLocalizedString(@"UploadInProgress", @"");
            [self checkAndSharpenCurrentUploadInScroll];
            [self uploadFrames];
        });
        
        BOOL isPhoto = [[dict objectForKey:@"isPhoto"] boolValue];
        BOOL isMedia = [[dict objectForKey:@"isMedia"] boolValue];
        id item = [dict objectForKey:@"item"];
        
        [ExtensionUploadManager sharedInstance].delegate = self;
        if(isMedia) {
            if(isPhoto) {
                NSString *fileName = ((NSURL *) item).lastPathComponent;
                [[ExtensionUploadManager sharedInstance] startUploadForImage:previewView.image withData:currentImgData fileName:fileName];
            } else {
                NSURL *moviePath = item;
                
                //                NSData *assetData = [NSData dataWithContentsOfURL:moviePath];
                NSError *error = nil;
                NSData *assetData = [[NSData alloc] initWithContentsOfFile:[moviePath path]
                                                                   options:NSDataReadingMappedIfSafe
                                                                     error:&error];
                [[ExtensionUploadManager sharedInstance] startUploadForVideoData:assetData forPath:moviePath];
            }
        } else {
            NSURL *docPath = item;
            
            NSString *contentType = [dict objectForKey:@"contentType"];
            NSString *extension = [dict objectForKey:@"extension"];
            
            
            NSData *assetData = [NSData dataWithContentsOfURL:docPath];
            [[ExtensionUploadManager sharedInstance] startUploadForDoc:assetData withContentType:contentType withExt:extension];
            
        }
    }
}

- (void) checkAndSharpenCurrentUploadInScroll {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.imagesCollectionView reloadData];
        [self.imagesCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:currentUploadIndex inSection:0]
                                          atScrollPosition:UICollectionViewScrollPositionLeft
                                                  animated:YES];
    });
}

- (void) viewDidLoad {
    [super viewDidLoad];
    
    
    
    self.imagesCollectionView.delegate = self;
    self.imagesCollectionView.dataSource = self;
    
    self.originalImages = [[NSMutableArray alloc] init];
    self.originalImagesForCV = [[NSMutableArray alloc] init];
    
    [SharedUtil writeSharedToken:nil];
    
    currentUploadIndex = NSNotFound;
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    self.httpSession = [NSURLSession sessionWithConfiguration:configuration delegate:nil delegateQueue:nil];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    urlsToUpload = [[NSMutableArray alloc] init];
    
    int totalCount = [((NSExtensionItem*)self.extensionContext.inputItems.firstObject).attachments count];
    __block int counter = 0;
    for (NSItemProvider* itemProvider in ((NSExtensionItem*)self.extensionContext.inputItems.firstObject).attachments) {
        if([itemProvider hasItemConformingToTypeIdentifier:@"public.image"]) {
            [itemProvider loadItemForTypeIdentifier:@"public.image" options:nil completionHandler:
             ^(id<NSSecureCoding> item, NSError *error) {
                 NSDictionary *dict = [NSDictionary dictionaryWithObjects:@[item, @"YES", @"YES"] forKeys:@[@"item", @"isPhoto", @"isMedia"]];
                 [urlsToUpload addObject:dict];
                 counter ++;
                 if(counter == totalCount) {
                     [self postUrlListConstruction];
                 }
             }];
        } else if ([itemProvider hasItemConformingToTypeIdentifier:(NSString *)kUTTypeQuickTimeMovie]) {
            [itemProvider loadItemForTypeIdentifier:@"com.apple.quicktime-movie" options:nil completionHandler:^(NSURL *path,NSError *error){
                if (path) {
                    NSDictionary *dict = [NSDictionary dictionaryWithObjects:@[path, @"NO", @"YES"] forKeys:@[@"item", @"isPhoto", @"isMedia"]];
                    [urlsToUpload addObject:dict];
                    counter ++;
                    if(counter == totalCount) {
                        [self postUrlListConstruction];
                    }
                }
            }];
        } else if ([itemProvider hasItemConformingToTypeIdentifier:(NSString *)kUTTypeMovie]
                   || [itemProvider hasItemConformingToTypeIdentifier:(NSString *)kUTTypeVideo]
                   || [itemProvider hasItemConformingToTypeIdentifier:(NSString *)kUTTypeMPEG]
                   || [itemProvider hasItemConformingToTypeIdentifier:(NSString *)kUTTypeMPEG4]
                   || [itemProvider hasItemConformingToTypeIdentifier:(NSString *)kUTTypeAVIMovie]) {
            IGLog(@"ShareViewController loadItemForTypeIdentifier:public.movie");
            [itemProvider loadItemForTypeIdentifier:@"public.movie" options:nil completionHandler:^(NSURL *path,NSError *error){
                if (path) {
                    IGLog(@"ShareViewController loadItemForTypeIdentifier:public.movie path found");
                    NSDictionary *dict = [NSDictionary dictionaryWithObjects:@[path, @"NO", @"YES"] forKeys:@[@"item", @"isPhoto", @"isMedia"]];
                    [urlsToUpload addObject:dict];
                    counter ++;
                    if(counter == totalCount) {
                        [self postUrlListConstruction];
                    }
                }
            }];
        } else if ([itemProvider hasItemConformingToTypeIdentifier:(NSString *)kUTTypePDF]) {
            [itemProvider loadItemForTypeIdentifier:@"com.adobe.pdf" options:nil completionHandler:^(NSURL *path,NSError *error){
                if (path) {
                    NSDictionary *dict = [NSDictionary dictionaryWithObjects:@[path, @"NO", @"NO", @"application/pdf", @"pdf"] forKeys:@[@"item", @"isPhoto", @"isMedia", @"contentType", @"extension"]];
                    [urlsToUpload addObject:dict];
                    counter ++;
                    if(counter == totalCount) {
                        [self postUrlListConstruction];
                    }
                }
            }];
        } else {
            IGLog(@"ShareViewController loadItemForTypeIdentifier:public.data");
            [itemProvider loadItemForTypeIdentifier:@"public.data" options:nil completionHandler:^(NSURL *path,NSError *error){
                if (path) {
                    NSString *absStr = [path absoluteString];
                    NSArray *items = [absStr componentsSeparatedByString:@"."];
                    NSString *extension = [items objectAtIndex:[items count]-1];
                    
                    NSString *logData = [NSString stringWithFormat:@"ShareViewController loadItemForTypeIdentifier:public.data path found with path:%@ and extension:%@", path, extension];
                    IGLog(logData);
                    
                    NSDictionary *dict;
                    if([[extension lowercaseString] hasSuffix:@"mp4"] || [[extension lowercaseString] hasSuffix:@"mpeg"]) {
                        dict = [NSDictionary dictionaryWithObjects:@[path, @"NO", @"YES"] forKeys:@[@"item", @"isPhoto", @"isMedia"]];
                    } else {
                        dict = [NSDictionary dictionaryWithObjects:@[path, @"NO", @"NO", @"application/octet-stream", extension] forKeys:@[@"item", @"isPhoto", @"isMedia", @"contentType", @"extension"]];
                    }
                    [urlsToUpload addObject:dict];
                    counter ++;
                    if(counter == totalCount) {
                        [self postUrlListConstruction];
                    }
                }
            }];
        }
    }
}

- (void) postUrlListConstruction {
    totalSize = 0;
    if(urlsToUpload != nil && urlsToUpload.count > 0) {
        //        NSMutableArray *images = [@[] mutableCopy];
        for(int counter = 0; counter < urlsToUpload.count; counter ++) {
            NSDictionary *dict = [urlsToUpload objectAtIndex:counter];
            BOOL isMedia = [[dict objectForKey:@"isMedia"] boolValue];
            BOOL isPhoto = [[dict objectForKey:@"isPhoto"] boolValue];
            id item = [dict objectForKey:@"item"];
            if(isMedia) {
                if(isPhoto) {
                    [self.originalImagesForCV addObject:[[NSObject alloc] init]];
                    NSDictionary *dict = [NSDictionary dictionaryWithObjects:@[item, @"YES"] forKeys:@[@"item", @"isPhoto"]];
                    [self.originalImages addObject:dict];
                    
                    if(counter == 0) {
                        UIImage *sharedImage = nil;
                        
                        if([(NSObject*)item isKindOfClass:[NSURL class]]) {
                            NSData* imgData = [NSData dataWithContentsOfURL:(NSURL*)item];
                            currentImgData = imgData;
                            totalSize += imgData.length;
                            sharedImage = [UIImage imageWithData:imgData];
                        }
                        if([(NSObject*)item isKindOfClass:[UIImage class]]) {
                            sharedImage = (UIImage*)item;
                        }
                        dispatch_async(dispatch_get_main_queue(), ^{
                            previewView.image = sharedImage;
                            uploadButton.enabled = YES;
                            imageLoadingIndicator.hidden = YES;
                            previewView.hidden = NO;
                            [self uploadFrames];
                        });
                    }
                    
                } else {
                    [self.originalImagesForCV addObject:[[NSObject alloc] init]];
                    if(counter == 0) {
                        
                        NSURL *moviePath = item;
                        UIImage *thumb = [self getVideoThumbnail:moviePath];
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            previewView.image = thumb;
                            uploadButton.enabled = YES;
                            imageLoadingIndicator.hidden = YES;
                            previewView.hidden = NO;
                            [self uploadFrames];
                        });
                    }
                    
                    NSDictionary *dict = [NSDictionary dictionaryWithObjects:@[item, @"NO"] forKeys:@[@"item", @"isPhoto"]];
                    [self.originalImages addObject:dict];
                }
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if(counter == 0) {
                        previewView.image = [UIImage imageNamed:@"documents_icon.png"];
                        uploadButton.enabled = YES;
                        imageLoadingIndicator.hidden = YES;
                        previewView.hidden = NO;
                        [self uploadFrames];
                    }
                    
                    [self.originalImages addObject:[UIImage imageNamed:@"documents_icon.png"]];
                });
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.imagesCollectionView reloadData];
            });
            
        }
    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.originalImagesForCV.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PhotoCellIdentifier" forIndexPath:indexPath];
    UIImageView *imageView = [cell viewWithTag:100];
    
    id placeholder = self.originalImagesForCV[indexPath.row];
    
    if ([placeholder isKindOfClass:[UIImage class]]) {
        imageView.image = placeholder;
    } else {
        UIImage *sharedImage = nil;
        NSDictionary *dict = self.originalImages[indexPath.row];
        id item = [dict objectForKey:@"item"];
        BOOL isPhoto = [[dict objectForKey:@"isPhoto"] boolValue];
        if([(NSObject*)item isKindOfClass:[NSURL class]]) {
            if (!isPhoto) {
                NSURL *moviePath = item;
                
                sharedImage = [self getVideoThumbnail:moviePath];
            }
            else {
                sharedImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:item]];
            }
        }
        if([(NSObject*)item isKindOfClass:[UIImage class]]) {
            sharedImage = item;
        }
//        UIImage *newImage = [ImageScale imageWithImage:sharedImage
//                                          scaledToSize:CGSizeMake(100, 100)];
        
        UIImage *newImage = [self imageResize:sharedImage andResizeTo:CGSizeMake(100, 100)];
        
        [self.originalImagesForCV replaceObjectAtIndex:indexPath.row
                                            withObject:newImage];
        imageView.image = newImage;
    }
    imageView.alpha = 0.6f;
    if (currentUploadIndex == indexPath.row) {
        imageView.alpha = 1.f;
    }
    
    return cell;
}

- (BOOL)isContentValid {
    // Do validation of contentText and/or NSExtensionContext attachments here
    return YES;
}

- (void)didSelectPost {
    // This is called after the user selects Post. Do the upload of contentText and/or NSExtensionContext attachments.
    
    // Inform the host that we're done, so it un-blocks its UI. Note: Alternatively you could call super's -didSelectPost, which will similarly complete the extension context.
    [self.extensionContext completeRequestReturningItems:@[] completionHandler:nil];
}

- (NSArray *)configurationItems {
    // To add configuration options via table cells at the bottom of the sheet, return an array of SLComposeSheetConfigurationItem here.
    return @[];
}

#pragma mark ExtensionUploadManagerDelegate

- (void) extensionUploadHasFailed:(NSError *)error {
    
    if(currentUploadIndex < urlsToUpload.count - 1) {
        progressView.frame = CGRectMake(progressView.frame.origin.x, progressView.frame.origin.y, 0, progressView.frame.size.height);
        
        currentUploadIndex ++;
        
        NSDictionary *dict = self.originalImages[currentUploadIndex];
        id item = [dict objectForKey:@"item"];
        
        UIImage *image = nil;
        
        if ([item isKindOfClass:[NSURL class]]) {
            image = [UIImage imageWithData:[NSData dataWithContentsOfURL:item]];
        } else if ([item isKindOfClass:[UIImage class]]) {
            image = item;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            previewView.image = image;
        });
        
        [self startUpload];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            uploadingLabel.text = NSLocalizedString(@"UploadFinishedPlaceholder", @"");
            [uploadIndicator stopAnimating];
            uploadIndicator.hidden = YES;
            [self uploadFrames];
            
            if(alertView) {
                [alertView removeFromSuperview];
                alertView = nil;
            }
            
            alertView = [[CustomAlertView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) withTitle:NSLocalizedString(@"Error", @"") withMessage:NSLocalizedString(@"UploadError", @"") withModalType:ModalTypeError];
            alertView.delegate = self;
            [alertView reorientateModalView:self.view.center];
            [self.view addSubview:alertView];
            [self.view bringSubviewToFront:alertView];
        });
    }
}

- (void) extensionUploadHasFinished {
    
    NSDictionary *dictt = self.originalImages[currentUploadIndex];
    id itemm = [dictt objectForKey:@"item"];
    NSString *fileName = ((NSURL *) itemm).lastPathComponent;
    MetaFileSummary *summary = [[MetaFileSummary alloc] init];
    summary.fileName = fileName;
    summary.bytes = currentImgData.length;
    [SharedUtil cacheSyncFileSummary:summary];
    
    
    if(currentUploadIndex < urlsToUpload.count - 1) {
        progressView.frame = CGRectMake(progressView.frame.origin.x, progressView.frame.origin.y, 0, progressView.frame.size.height);
        
        
        currentUploadIndex ++;
        
        NSDictionary *dict = self.originalImages[currentUploadIndex];
        id item = [dict objectForKey:@"item"];
        BOOL isPhoto = [[dict objectForKey:@"isPhoto"] boolValue];
        UIImage *image = nil;
        if ([item isKindOfClass:[NSURL class]]) {
            if (!isPhoto) {
                NSURL *moviePath = item;
                image = [self getVideoThumbnail:moviePath];
            }
            else {
                NSData *imgData = [NSData dataWithContentsOfURL:item];
                currentImgData = imgData;
                image = [UIImage imageWithData:[NSData dataWithContentsOfURL:item]];
            }
        } else if ([item isKindOfClass:[UIImage class]]) {
            image = item;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            previewView.image = image;
        });
        [self startUpload];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            uploadingLabel.text = NSLocalizedString(@"UploadFinishedPlaceholder", @"");
            [uploadIndicator stopAnimating];
            uploadIndicator.hidden = YES;
            [self uploadFrames];
            
            if(alertView) {
                [alertView removeFromSuperview];
                alertView = nil;
            }
            
            alertView = [[CustomAlertView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) withTitle:NSLocalizedString(@"Info", @"") withMessage:NSLocalizedString(@"UploadSuccess", @"") withModalType:ModalTypeSuccess];
            alertView.delegate = self;
            [alertView reorientateModalView:self.view.center];
            [self.view addSubview:alertView];
            [self.view bringSubviewToFront:alertView];
        });
    }
}

- (void) extensionUploadIsAtPercent:(int)percent {
    dispatch_async(dispatch_get_main_queue(), ^(){
        progressView.frame = CGRectMake(progressView.frame.origin.x, progressView.frame.origin.y, percent * loadingView.frame.size.width/100, progressView.frame.size.height);
    });
}

- (void) extensionUploadShouldRelogin {
    NetworkStatus networkStatus = [[Reachability reachabilityForInternetConnection] currentReachabilityStatus];
    if(networkStatus == kReachableViaWiFi || networkStatus == kReachableViaWWAN) {
        if([SharedUtil readSharedRememberMeToken] != nil) {
            [self requestToken];
        } else {
            if(networkStatus == kReachableViaWiFi) {
                alertView = [[CustomAlertView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) withTitle:NSLocalizedString(@"Error", @"") withMessage:NSLocalizedString(@"ExtLoginRequiredMessage", @"") withModalType:ModalTypeError];
                alertView.delegate = self;
                [alertView reorientateModalView:self.view.center];
                [self.view addSubview:alertView];
                [self.view bringSubviewToFront:alertView];
            } else {
                [self requestRadius];
            }
        }
    }
}

- (void) requestToken {
    NSURL *url = [NSURL URLWithString:EXT_REMEMBER_ME_URL];
    
    NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:
                          [[UIDevice currentDevice] identifierForVendor].UUIDString, @"uuid",
                          [[UIDevice currentDevice] name], @"name",
                          (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? @"IPAD" : @"IPHONE"), @"deviceType",
                          nil];
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:info options:(NSJSONWritingOptions)0 error:&error];
    
    NSMutableURLRequest *postRequest = [NSMutableURLRequest requestWithURL:url];
    [postRequest setTimeoutInterval:60];
    [postRequest setValue:[SharedUtil readSharedRememberMeToken] forHTTPHeaderField:@"X-Remember-Me-Token"];
    [postRequest setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [postRequest setValue:@"application/json; encoding=utf-8" forHTTPHeaderField:@"Content-Type"];
    [postRequest setHTTPMethod:@"POST"];
    [postRequest setHTTPBody:jsonData];
    
    NSURLSessionDataTask *task = [self.httpSession dataTaskWithRequest:postRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if(error) {
            dispatch_async(dispatch_get_main_queue(), ^(){
                alertView = [[CustomAlertView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) withTitle:NSLocalizedString(@"Error", @"") withMessage:NSLocalizedString(@"LoginError", @"") withModalType:ModalTypeError];
                alertView.delegate = self;
                [alertView reorientateModalView:self.view.center];
                [self.view addSubview:alertView];
                [self.view bringSubviewToFront:alertView];
            });
        } else {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
            if ([httpResponse respondsToSelector:@selector(allHeaderFields)]) {
                NSDictionary *dictionary = [httpResponse allHeaderFields];
                NSString *authToken = [dictionary objectForKey:@"X-Auth-Token"];
                if(authToken != nil) {
                    [SharedUtil writeSharedToken:authToken];
                    dispatch_async(dispatch_get_main_queue(), ^(){
                        [self requestBaseUrl];
                    });
                } else {
                    dispatch_async(dispatch_get_main_queue(), ^(){
                        alertView = [[CustomAlertView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) withTitle:NSLocalizedString(@"Error", @"") withMessage:NSLocalizedString(@"LoginError", @"") withModalType:ModalTypeError];
                        alertView.delegate = self;
                        [alertView reorientateModalView:self.view.center];
                        [self.view addSubview:alertView];
                        [self.view bringSubviewToFront:alertView];
                    });
                }
            }
        }
    }];
    [task resume];
}

- (void) requestBaseUrl {
    NSURL *url = [NSURL URLWithString:EXT_USER_BASE_URL];
    
    NSMutableURLRequest *getRequest = [NSMutableURLRequest requestWithURL:url];
    [getRequest setTimeoutInterval:60];
    [getRequest setValue:[SharedUtil readSharedToken] forHTTPHeaderField:@"X-Auth-Token"];
    [getRequest setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [getRequest setValue:@"application/json; encoding=utf-8" forHTTPHeaderField:@"Content-Type"];
    [getRequest setHTTPMethod:@"GET"];
    
    NSURLSessionDataTask *task = [self.httpSession dataTaskWithRequest:getRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if(error) {
            dispatch_async(dispatch_get_main_queue(), ^(){
                alertView = [[CustomAlertView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) withTitle:NSLocalizedString(@"Error", @"") withMessage:NSLocalizedString(@"LoginError", @"") withModalType:ModalTypeError];
                alertView.delegate = self;
                [alertView reorientateModalView:self.view.center];
                [self.view addSubview:alertView];
                [self.view bringSubviewToFront:alertView];
            });
        } else {
            NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            if(jsonDict != nil && ![jsonDict isKindOfClass:[NSNull class]] && [jsonDict objectForKey:@"value"] != nil) {
                NSString *baseUrl = [jsonDict objectForKey:@"value"];
                [SharedUtil writeSharedBaseUrl:baseUrl];
                [self startUpload];
            } else {
                dispatch_async(dispatch_get_main_queue(), ^(){
                    alertView = [[CustomAlertView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) withTitle:NSLocalizedString(@"Error", @"") withMessage:NSLocalizedString(@"LoginError", @"") withModalType:ModalTypeError];
                    alertView.delegate = self;
                    [alertView reorientateModalView:self.view.center];
                    [self.view addSubview:alertView];
                    [self.view bringSubviewToFront:alertView];
                });
            }
        }
    }];
    [task resume];
}

- (void) requestRadius {
    NSURL *url = [NSURL URLWithString:EXT_RADIUS_URL];
    
    NSDictionary *deviceInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                [[UIDevice currentDevice] identifierForVendor].UUIDString, @"uuid",
                                [[UIDevice currentDevice] name], @"name",
                                (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? @"IPAD" : @"IPHONE"), @"deviceType",
                                //                                ([AppUtil readFirstVisitOverFlag] ? @"false" : @"true"), @"newDevice",
                                nil];
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:deviceInfo options:(NSJSONWritingOptions)0 error:&error];
    
    NSMutableURLRequest *postRequest = [NSMutableURLRequest requestWithURL:url];
    [postRequest setTimeoutInterval:60];
    [postRequest setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [postRequest setValue:@"application/json; encoding=utf-8" forHTTPHeaderField:@"Content-Type"];
    [postRequest setHTTPMethod:@"POST"];
    [postRequest setHTTPBody:jsonData];
    //    if([SharedUtil readSharedToken]) {
    //        [postRequest setValue:[SharedUtil readSharedToken] forHTTPHeaderField:@"X-Auth-Token"];
    //    }
    
    NSURLSessionDataTask *task = [self.httpSession dataTaskWithRequest:postRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if(error) {
            dispatch_async(dispatch_get_main_queue(), ^(){
                alertView = [[CustomAlertView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) withTitle:NSLocalizedString(@"Error", @"") withMessage:NSLocalizedString(@"LoginError", @"") withModalType:ModalTypeError];
                alertView.delegate = self;
                [alertView reorientateModalView:self.view.center];
                [self.view addSubview:alertView];
                [self.view bringSubviewToFront:alertView];
            });
        } else {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
            if ([httpResponse respondsToSelector:@selector(allHeaderFields)]) {
                NSDictionary *dictionary = [httpResponse allHeaderFields];
                NSString *authToken = [dictionary objectForKey:@"X-Auth-Token"];
                if(authToken != nil) {
                    [SharedUtil writeSharedToken:authToken];
                    dispatch_async(dispatch_get_main_queue(), ^(){
                        [self requestBaseUrl];
                    });
                } else {
                    dispatch_async(dispatch_get_main_queue(), ^(){
                        alertView = [[CustomAlertView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) withTitle:NSLocalizedString(@"Error", @"") withMessage:NSLocalizedString(@"LoginError", @"") withModalType:ModalTypeError];
                        alertView.delegate = self;
                        [alertView reorientateModalView:self.view.center];
                        [self.view addSubview:alertView];
                        [self.view bringSubviewToFront:alertView];
                    });
                }
            }
        }
    }];
    [task resume];
}

- (void) didDismissCustomAlert:(CustomAlertView *)alertView {
    [self dismiss];
}

- (UIImage*) getVideoThumbnail:(NSURL*) url {
    UIImage *image = nil;
    NSURL *moviePath = url;
    
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:moviePath options:nil];
    AVAssetImageGenerator *gen = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    gen.appliesPreferredTrackTransform = YES;
    CMTime time = CMTimeMakeWithSeconds(0.0, 600);
    NSError *error = nil;
    CMTime actualTime;
    
    CGImageRef img = [gen copyCGImageAtTime:time actualTime:&actualTime error:&error];
    image = [[UIImage alloc] initWithCGImage:img];
    CGImageRelease(img);
    
    return image;
}

- (UIImage *)imageResize :(UIImage*)img andResizeTo:(CGSize)newSize {
    CGFloat scale = [[UIScreen mainScreen]scale];
    /*You can remove the below comment if you dont want to scale the image in retina   device .Dont forget to comment UIGraphicsBeginImageContextWithOptions*/
    //UIGraphicsBeginImageContext(newSize);
    UIGraphicsBeginImageContextWithOptions(newSize, NO, scale);
    [img drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

@end
