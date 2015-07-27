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

#define EXT_REMEMBER_ME_URL @"https://adepo.turkcell.com.tr/api/auth/rememberMe"

#define EXT_RADIUS_URL @"http://adepo.turkcell.com.tr/api/auth/gsm/login?rememberMe=on"

#define EXT_USER_BASE_URL @"https://adepo.turkcell.com.tr/api/container/baseUrl"

@interface ShareViewController ()

@end

@implementation ShareViewController

@synthesize cancelButton;
@synthesize uploadButton;
@synthesize previewView;
@synthesize loadingView;
@synthesize progressView;
@synthesize alertView;
@synthesize imageLoadingIndicator;
@synthesize imagesScroll;
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
    imagesScroll.frame = CGRectMake(20, previewView.frame.origin.y + previewView.frame.size.height + 30, self.view.frame.size.width - 40, 50);
    imageLoadingIndicator.center = previewView.center;
    uploadButton.frame = CGRectMake(20, previewView.frame.origin.y + previewView.frame.size.height + 110, self.view.frame.size.width - 40, 50);
    loadingView.frame = CGRectMake(20, previewView.frame.origin.y + previewView.frame.size.height + 110, self.view.frame.size.width - 40, 50);
}

- (IBAction) dismiss {
    [UIView animateWithDuration:0.20 animations:^{
        self.view.transform = CGAffineTransformMakeTranslation(0, self.view.frame.size.height);
    } completion:^(BOOL finished) {
        [self.extensionContext completeRequestReturningItems:nil completionHandler:nil];
    }];
}

- (IBAction) preUploadCheck {
    if([SharedUtil readSharedToken] == nil) {
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
    } else if([SharedUtil readSharedBaseUrl] == nil) {
        [self requestBaseUrl];
    } else {
        [self startUpload];
    }
}

- (IBAction) startUpload {
    
    NSDictionary *dict = [urlsToUpload objectAtIndex:currentUploadIndex];
    if(dict != nil) {
        BOOL isPhoto = [[dict objectForKey:@"isPhoto"] boolValue];
        id item = [dict objectForKey:@"item"];

        [ExtensionUploadManager sharedInstance].delegate = self;
        if(isPhoto) {
            [[ExtensionUploadManager sharedInstance] startUploadForImage:previewView.image];
        } else {
            NSURL *moviePath = item;

            dispatch_async(dispatch_get_main_queue(), ^{
                NSData *assetData = [NSData dataWithContentsOfURL:moviePath];
                [[ExtensionUploadManager sharedInstance] startUploadForVideoData:assetData];
            });
        }
        uploadButton.hidden = YES;
        uploadButton.enabled = NO;
        loadingView.hidden = NO;
        
        uploadingLabel.text = NSLocalizedString(@"UploadInProgress", @"");
        [self checkAndSharpenCurrentUploadInScroll];
        [self uploadFrames];
    }
}

- (void) checkAndSharpenCurrentUploadInScroll {
    for(UIView *subView in [imagesScroll subviews]) {
        if([subView isKindOfClass:[UIImageView class]]) {
            if(subView.tag == currentUploadIndex) {
                subView.alpha = 1.0f;
                imagesScroll.contentOffset = CGPointMake(subView.frame.origin.x, imagesScroll.contentOffset.y);
            } else {
                subView.alpha = 0.6f;
            }
        }
    }
}

- (void) viewDidLoad {
    [super viewDidLoad];
    
    currentUploadIndex = 0;
    
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
                 NSDictionary *dict = [NSDictionary dictionaryWithObjects:@[item, @"YES"] forKeys:@[@"item", @"isPhoto"]];
                 [urlsToUpload addObject:dict];
                 counter ++;
                 if(counter == totalCount) {
                     [self postUrlListConstruction];
                 }
             }];
        } else if ([itemProvider hasItemConformingToTypeIdentifier:(NSString *)kUTTypeQuickTimeMovie]) {
            [itemProvider loadItemForTypeIdentifier:@"com.apple.quicktime-movie" options:nil completionHandler:^(NSURL *path,NSError *error){
                if (path) {
                    NSDictionary *dict = [NSDictionary dictionaryWithObjects:@[path, @"NO"] forKeys:@[@"item", @"isPhoto"]];
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
    if(urlsToUpload != nil && urlsToUpload.count > 0) {
        for(int counter = 0; counter < urlsToUpload.count; counter ++) {
            NSDictionary *dict = [urlsToUpload objectAtIndex:counter];
            BOOL isPhoto = [[dict objectForKey:@"isPhoto"] boolValue];
            id item = [dict objectForKey:@"item"];
            if(isPhoto) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIImage *sharedImage = nil;
                    if([(NSObject*)item isKindOfClass:[NSURL class]]) {
                        sharedImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:(NSURL*)item]];
                    }
                    if([(NSObject*)item isKindOfClass:[UIImage class]]) {
                        sharedImage = (UIImage*)item;
                    }
                    if(counter == 0) {
                        previewView.image = sharedImage;
                        uploadButton.enabled = YES;
                        imageLoadingIndicator.hidden = YES;
                        previewView.hidden = NO;
                        [self uploadFrames];
                    }

                    UIImageView *scrollableImgView = [[UIImageView alloc] initWithFrame:CGRectMake(counter * 60, 0, 50, 50)];
                    scrollableImgView.image = sharedImage;
                    scrollableImgView.alpha = 0.6;
                    scrollableImgView.tag = counter;
                    [imagesScroll addSubview:scrollableImgView];
                });
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSURL *moviePath = item;
                    
                    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:moviePath options:nil];
                    AVAssetImageGenerator *gen = [[AVAssetImageGenerator alloc] initWithAsset:asset];
                    gen.appliesPreferredTrackTransform = YES;
                    CMTime time = CMTimeMakeWithSeconds(0.0, 600);
                    NSError *error = nil;
                    CMTime actualTime;
                    
                    CGImageRef image = [gen copyCGImageAtTime:time actualTime:&actualTime error:&error];
                    UIImage *thumb = [[UIImage alloc] initWithCGImage:image];
                    CGImageRelease(image);

                    if(counter == 0) {
                        previewView.image = thumb;
                        uploadButton.enabled = YES;
                        imageLoadingIndicator.hidden = YES;
                        previewView.hidden = NO;
                        [self uploadFrames];
                    }

                    UIImageView *scrollableImgView = [[UIImageView alloc] initWithFrame:CGRectMake(counter * 60, 0, 50, 50)];
                    scrollableImgView.image = thumb;
                    scrollableImgView.alpha = 0.6;
                    scrollableImgView.tag = counter;
                    [imagesScroll addSubview:scrollableImgView];

                });
            }
        }
    }
    imagesScroll.contentSize = CGSizeMake(60 * (urlsToUpload.count + 1), imagesScroll.frame.size.height);
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
    dispatch_async(dispatch_get_main_queue(), ^{
        if(currentUploadIndex < urlsToUpload.count - 1) {
            progressView.frame = CGRectMake(progressView.frame.origin.x, progressView.frame.origin.y, 0, progressView.frame.size.height);
            
            currentUploadIndex ++;
            
            for(UIView *subView in [imagesScroll subviews]) {
                if([subView isKindOfClass:[UIImageView class]]) {
                    UIImageView *imgSubView = (UIImageView *) subView;
                    if(subView.tag == currentUploadIndex) {
                        previewView.image = imgSubView.image;
                    }
                }
            }
            
            [self startUpload];
        } else {
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
        }
    });
}

- (void) extensionUploadHasFinished {
    dispatch_async(dispatch_get_main_queue(), ^{
        if(currentUploadIndex < urlsToUpload.count - 1) {
            progressView.frame = CGRectMake(progressView.frame.origin.x, progressView.frame.origin.y, 0, progressView.frame.size.height);
            
            currentUploadIndex ++;
            
            for(UIView *subView in [imagesScroll subviews]) {
                if([subView isKindOfClass:[UIImageView class]]) {
                    UIImageView *imgSubView = (UIImageView *) subView;
                    if(subView.tag == currentUploadIndex) {
                        previewView.image = imgSubView.image;
                    }
                }
            }
            
            [self startUpload];
        } else {
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
        }
    });
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
                dispatch_async(dispatch_get_main_queue(), ^(){
                    [self startUpload];
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

@end
