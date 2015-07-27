//
//  ShareViewController.h
//  DepoShareExtension
//
//  Created by Mahir on 16/07/15.
//  Copyright (c) 2015 com.igones. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Social/Social.h>
#import "CustomAlertView.h"
#import "ExtensionUploadManager.h"

@interface ShareViewController : UIViewController <ExtensionUploadManagerDelegate, CustomAlertDelegate>

@property (nonatomic, weak) IBOutlet UIButton *cancelButton;
@property (nonatomic, weak) IBOutlet UIImageView *previewView;
@property (nonatomic, weak) IBOutlet UIButton *uploadButton;
@property (nonatomic, weak) IBOutlet UIView *loadingView;
@property (nonatomic, weak) IBOutlet UIView *progressView;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *imageLoadingIndicator;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *uploadIndicator;
@property (nonatomic, weak) IBOutlet UILabel *uploadingLabel;
@property (nonatomic, weak) IBOutlet UIScrollView *imagesScroll;
@property (nonatomic, strong) CustomAlertView *alertView;
@property (nonatomic, strong) NSURLSession *httpSession;
@property (nonatomic, strong) NSMutableArray *urlsToUpload;
@property (nonatomic) int currentUploadIndex;

@end
