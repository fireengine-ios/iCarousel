//
//  SquareImageView.m
//  Depo
//
//  Created by Mahir on 10/8/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "SquareImageView.h"
#import "UIImageView+AFNetworking.h"
#import "CustomLabel.h"
#import "AppDelegate.h"
#import "AppSession.h"
#import "Util.h"

@implementation SquareImageView

@synthesize delegate;
@synthesize file;
@synthesize uploadRef;
@synthesize longPressGesture;
@synthesize tapGesture;

- (id)initWithFrame:(CGRect)frame withFile:(MetaFile *) _file {
    return [self initWithFrame:frame withFile:_file withSelectibleStatus:NO];
}

- (id)initWithFrame:(CGRect)frame withFile:(MetaFile *) _file withSelectibleStatus:(BOOL) selectibleStatus {
    self = [super initWithFrame:frame];
    if (self) {
        self.file = _file;
        isSelectible = selectibleStatus;

        imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        [imgView setImageWithURL:[NSURL URLWithString:[self.file.detail.thumbMediumUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
        [self addSubview:imgView];
        
        if(self.file.contentType == ContentTypeVideo) {
            UIImageView *playIconView = [[UIImageView alloc] initWithFrame:CGRectMake(4, self.frame.size.height - 22, 18, 18)];
            playIconView.image = [UIImage imageNamed:@"mini_play_icon.png"];
            [self addSubview:playIconView];
        
            CustomLabel *durationLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(22, self.frame.size.height - 22, self.frame.size.width - 26, 18) withFont:[UIFont fontWithName:@"TurkcellSaturaDem" size:15] withColor:[UIColor whiteColor] withText:self.file.contentLengthDisplay];
            durationLabel.textAlignment = NSTextAlignmentRight;
            [self addSubview:durationLabel];
        }

        maskView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        maskView.image = [UIImage imageNamed:@"selected_mask.png"];
        maskView.hidden = YES;
        [self addSubview:maskView];

        longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressed)];
        longPressGesture.minimumPressDuration = 1.0f;
        longPressGesture.allowableMovement = 10.0f;
        [self addGestureRecognizer:longPressGesture];
        
        tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageTapped)];
        tapGesture.numberOfTapsRequired = 1;
        [self addGestureRecognizer:tapGesture];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame withUploadRef:(UploadRef *)ref {
    self = [super initWithFrame:frame];
    if (self) {
        self.uploadRef = ref;
        
        imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        imgView.alpha = 0.5f;
        [self addSubview:imgView];

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul), ^(void) {
            @autoreleasepool {
                UIImage *image = [[UIImage alloc] initWithContentsOfFile:self.uploadRef.tempThumbnailUrl];
                dispatch_async(dispatch_get_main_queue(), ^{
                    imgView.image = image;
                });
            }
        });

        for(UploadManager *manager in APPDELEGATE.uploadQueue.uploadManagers) {
            if(!manager.uploadRef.hasFinished && [manager.uploadRef.fileUuid isEqualToString:self.uploadRef.fileUuid]) {
                manager.delegate = self;
            }
        }
        
        progressSeparator = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height-6, 1, 6)];
        progressSeparator.backgroundColor = [Util UIColorForHexColor:@"3fb0e8"];
        progressSeparator.alpha = 0.75f;
        [self addSubview:progressSeparator];

        maskView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        maskView.image = [UIImage imageNamed:@"selected_mask.png"];
        maskView.hidden = YES;
        [self addSubview:maskView];
        
        tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageTapped)];
        tapGesture.numberOfTapsRequired = 1;
        [self addGestureRecognizer:tapGesture];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(managerNotifyReceived:) name:TEMP_IMG_UPLOAD_NOTIFICATION object:nil];
        
    }
    return self;
}

- (void) managerNotifyReceived:(NSNotification *) notification {
    NSDictionary *userInfo = notification.userInfo;
    NSString *fileUuid = [userInfo objectForKey:TEMP_IMG_UPLOAD_NOTIFICATION_UUID_PARAM];
    NSString *tempThumbnailPath = [userInfo objectForKey:TEMP_IMG_UPLOAD_NOTIFICATION_URL_PARAM];
    if(fileUuid && self.uploadRef) {
        if([self.uploadRef.fileUuid isEqualToString:fileUuid]) {
            self.uploadRef.tempThumbnailUrl = tempThumbnailPath;
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul), ^(void) {
                @autoreleasepool {
                    UIImage *image = [[UIImage alloc] initWithContentsOfFile:self.uploadRef.tempThumbnailUrl];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        imgView.image = image;
                    });
                }
            });
        }
    }
}

- (void) setNewStatus:(BOOL) newStatus {
    isSelectible = newStatus;
    isMarked = NO;
    maskView.hidden = YES;
}

- (void) showProgressMask {
    maskView.hidden = YES;
    imgView.alpha = 0.25f;
}

- (void) old_touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if(self.uploadRef != nil) {
        return;
    }
    
    if(isSelectible) {
        isMarked = !isMarked;
        if(isMarked) {
            maskView.hidden = NO;
            [delegate squareImageWasMarkedForFile:self.file];
        } else {
            maskView.hidden = YES;
            [delegate squareImageWasUnmarkedForFile:self.file];
        }
    } else {
        [delegate squareImageWasSelectedForFile:self.file];
    }
}

- (void) longPressed {
    if(isSelectible) {
        [self imageTapped];
    } else {
        [delegate squareImageWasLongPressedForFile:self.file];
    }
}

- (void) imageTapped {
    if(self.uploadRef != nil && self.file == nil) {
        if(uploadErrorType == UploadErrorTypeQuota) {
            [delegate squareImageUploadQuotaError:self.file];
        } else if(uploadErrorType == UploadErrorTypeLogin) {
            [delegate squareImageUploadLoginError:self.file];
        }
        return;
    }
    
    if(isSelectible) {
        isMarked = !isMarked;
        if(isMarked) {
            maskView.hidden = NO;
            [delegate squareImageWasMarkedForFile:self.file];
        } else {
            maskView.hidden = YES;
            [delegate squareImageWasUnmarkedForFile:self.file];
        }
    } else {
        [delegate squareImageWasSelectedForFile:self.file];
    }
}

- (void) uploadManagerDidSendData:(long)sentBytes inTotal:(long)totalBytes {
    int progressWidth = sentBytes*self.frame.size.width/totalBytes;
    [self performSelectorOnMainThread:@selector(updateProgressByWidth:) withObject:[NSNumber numberWithInt:progressWidth] waitUntilDone:NO];
}

- (void) updateProgressByWidth:(NSNumber *) newWidth {
    progressSeparator.frame = CGRectMake(0, self.frame.size.height-6, [newWidth intValue], 6);
}

- (void) uploadManagerDidFailUploadingForAsset:(NSString *) assetToUpload {
    progressSeparator.backgroundColor = [Util UIColorForHexColor:@"ad3110"];
}

- (void) uploadManagerQuotaExceedForAsset:(NSString *) assetToUpload {
    uploadErrorType = UploadErrorTypeQuota;

    [self updateProgressByWidth:[NSNumber numberWithLong:self.frame.size.width]];
    progressSeparator.backgroundColor = [Util UIColorForHexColor:@"ad3110"];
}

- (void) uploadManagerLoginRequiredForAsset:(NSString *) assetToUpload {
    uploadErrorType = UploadErrorTypeLogin;

    [self updateProgressByWidth:[NSNumber numberWithLong:self.frame.size.width]];
    progressSeparator.backgroundColor = [Util UIColorForHexColor:@"ad3110"];
}

- (void) uploadManagerDidFinishUploadingForAsset:(NSString *)assetToUpload withFinalFile:(MetaFile *) finalFile {
    self.file = finalFile;
    [self updateProgressByWidth:[NSNumber numberWithLong:self.frame.size.width]];
    progressSeparator.backgroundColor = [Util UIColorForHexColor:@"67d74b"];
    imgView.alpha = 1.0f;
    if([delegate respondsToSelector:@selector(squareImageUploadFinishedForFile:)]) {
        [delegate squareImageUploadFinishedForFile:self.uploadRef.fileUuid];
    }
}

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:TEMP_IMG_UPLOAD_NOTIFICATION object:nil];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
