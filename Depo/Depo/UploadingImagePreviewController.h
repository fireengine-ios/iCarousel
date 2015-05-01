//
//  UploadingImagePreviewController.h
//  Depo
//
//  Created by Mahir on 31/03/15.
//  Copyright (c) 2015 com.igones. All rights reserved.
//

#import "MyViewController.h"
#import "UploadRef.h"
#import "UploadManager.h"
#import "CustomLabel.h"

@interface UploadingImagePreviewController : MyViewController <UploadManagerDelegate>

@property (nonatomic, strong) UploadRef *uploadRef;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIView *progressView;
@property (nonatomic, strong) CustomLabel *uploadingPhotoLabel;
@property (nonatomic, strong) CustomLabel *progressLabel;
@property (nonatomic, strong) UIActivityIndicatorView *indicator;
@property (nonatomic, strong) id oldDelegateRef;

- (id) initWithUploadReference:(UploadRef *) ref withImage:(UIImage *) imgRef;

@end
