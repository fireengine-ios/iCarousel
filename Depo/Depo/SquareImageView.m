//
//  SquareImageView.m
//  Depo
//
//  Created by Mahir on 10/8/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "SquareImageView.h"
#import "UIImageView+WebCache.h"
#import "CustomLabel.h"
#import "AppDelegate.h"
#import "AppSession.h"
#import "Util.h"

#define Long_Press_Duration 0.5f

@interface SquareImageView() {
    UIImageView *playIconView;
    CustomLabel *durationLabel;
}
@end

@implementation SquareImageView

@synthesize delegate;
@synthesize file;
@synthesize asset;
@synthesize uploadRef;
@synthesize longPressGesture;
@synthesize tapGesture;

- (id)initWithFrame:(CGRect)frame withFile:(MetaFile *) _file {
    return [self initWithFrame:frame withFile:_file withSelectibleStatus:NO shouldCache:NO];
}

- (id)initWithFrame:(CGRect)frame withFile:(MetaFile *) _file withSelectibleStatus:(BOOL) selectibleStatus {
    return [self initWithFrame:frame withFile:_file withSelectibleStatus:selectibleStatus shouldCache:NO];
}

- (id)initWithFrame:(CGRect)frame withFile:(MetaFile *) _file withSelectibleStatus:(BOOL) selectibleStatus shouldCache:(BOOL) cacheFlag {
    return [self initWithFrame:frame withFile:_file withSelectibleStatus:selectibleStatus shouldCache:cacheFlag manualQuality:NO];
}

- (id)initWithFrame:(CGRect)frame withFile:(MetaFile *) _file withSelectibleStatus:(BOOL) selectibleStatus shouldCache:(BOOL) cacheFlag manualQuality:(BOOL) manualQuality {
    self = [super initWithFrame:frame];
    if (self) {
        self.file = _file;
        self.backgroundColor = [Util UIColorForHexColor:@"E3E3E3"];
        isSelectible = selectibleStatus;

        self.imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        self.imgView.contentMode = UIViewContentModeScaleAspectFill;
        self.imgView.clipsToBounds = YES;
        if(cacheFlag) {
            [self.imgView sd_setImageWithURL:[NSURL URLWithString:[self.file.detail.thumbMediumUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] placeholderImage:nil];
        } else {
            if(manualQuality) {
                [self.imgView sd_setImageWithURL:[NSURL URLWithString:[self.file.detail.thumbMediumUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] placeholderImage:nil];
            } else {
                [self.imgView sd_setImageWithURL:[NSURL URLWithString:[self.file.detail.thumbMediumUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] placeholderImage:nil];
            }
        }
        [self addSubview:self.imgView];
        
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

        longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressed:)];
        longPressGesture.minimumPressDuration = Long_Press_Duration;
        longPressGesture.allowableMovement = 10.0f;
        longPressGesture.delegate = self;
        [self addGestureRecognizer:longPressGesture];
        
        tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageTapped)];
        tapGesture.numberOfTapsRequired = 1;
        tapGesture.delegate = self;
        [tapGesture requireGestureRecognizerToFail:longPressGesture];
        [self addGestureRecognizer:tapGesture];
    }
    return self;
}

- (id) initFinalWithFrame:(CGRect)frame withFile:(MetaFile *) _file withSelectibleStatus:(BOOL) selectibleStatus {
    self = [super initWithFrame:frame];
    if (self) {
        self.file = _file;
        self.backgroundColor = [Util UIColorForHexColor:@"E3E3E3"];
        isSelectible = selectibleStatus;
        
        float imgMaxWidth = 400;
        if(IS_IPAD) {
            imgMaxWidth = 600;
        }
        self.imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        self.imgView.contentMode = UIViewContentModeScaleAspectFill;
        self.imgView.clipsToBounds = YES;
        [self.imgView sd_setImageWithURL:[NSURL URLWithString:[self.file.detail.thumbMediumUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] placeholderImage:nil];
        [self addSubview:self.imgView];
        
        if(self.file.contentType == ContentTypeVideo) {
            playIconView = [[UIImageView alloc] initWithFrame:CGRectMake(4, self.frame.size.height - 22, 18, 18)];
            playIconView.image = [UIImage imageNamed:@"mini_play_icon.png"];
            [self addSubview:playIconView];
            
            durationLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(22, self.frame.size.height - 22, self.frame.size.width - 26, 18) withFont:[UIFont fontWithName:@"TurkcellSaturaDem" size:15] withColor:[UIColor whiteColor] withText:self.file.contentLengthDisplay];
            durationLabel.textAlignment = NSTextAlignmentRight;
            [self addSubview:durationLabel];
        }
        
        longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressed:)];
        longPressGesture.minimumPressDuration = Long_Press_Duration;
        longPressGesture.allowableMovement = 10.0f;
        longPressGesture.delegate = self;
        [self addGestureRecognizer:longPressGesture];
        
        tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageTapped)];
        tapGesture.numberOfTapsRequired = 1;
        tapGesture.delegate = self;
        [tapGesture requireGestureRecognizerToFail:longPressGesture];
        [self addGestureRecognizer:tapGesture];
    }
    return self;
}

- (id) initCachedFinalWithFrame:(CGRect)frame withFile:(MetaFile *) _file withSelectibleStatus:(BOOL) selectibleStatus {
    self = [super initWithFrame:frame];
    if (self) {
        self.file = _file;
        self.backgroundColor = [Util UIColorForHexColor:@"E3E3E3"];
        isSelectible = selectibleStatus;
        
        float imgMaxWidth = 400;
        if(IS_IPAD) {
            imgMaxWidth = 600;
        }
        
        self.imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        self.imgView.contentMode = UIViewContentModeScaleAspectFill;
        self.imgView.clipsToBounds = YES;
        [self.imgView sd_setImageWithURL:[NSURL URLWithString:[self.file.detail.thumbMediumUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] placeholderImage:nil options:SDWebImageHighPriority];
        [self addSubview:self.imgView];
        
        if(self.file.contentType == ContentTypeVideo) {
            playIconView = [[UIImageView alloc] initWithFrame:CGRectMake(4, self.frame.size.height - 22, 18, 18)];
            playIconView.image = [UIImage imageNamed:@"mini_play_icon.png"];
            [self addSubview:playIconView];
            
            durationLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(22, self.frame.size.height - 22, self.frame.size.width - 26, 18) withFont:[UIFont fontWithName:@"TurkcellSaturaDem" size:15] withColor:[UIColor whiteColor] withText:self.file.contentLengthDisplay];
            durationLabel.textAlignment = NSTextAlignmentRight;
            [self addSubview:durationLabel];
        }
        
        longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressed:)];
        longPressGesture.minimumPressDuration = Long_Press_Duration;
        longPressGesture.allowableMovement = 10.0f;
        longPressGesture.delegate = self;
        [self addGestureRecognizer:longPressGesture];
        
        tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageTapped)];
        tapGesture.numberOfTapsRequired = 1;
        tapGesture.delegate = self;
        [tapGesture requireGestureRecognizerToFail:longPressGesture];
        [self addGestureRecognizer:tapGesture];
    }
    return self;
}

- (void) refreshContent:(MetaFile *) fileToRefresh {
    self.file = fileToRefresh;
    [self.imgView setImage:nil];

    if(self.progressSeparator) {
        self.progressSeparator.hidden = YES;
    }
    
    float imgMaxWidth = 400;
    if(IS_IPAD) {
        imgMaxWidth = 600;
    }
    
    [self.imgView sd_setImageWithURL:[NSURL URLWithString:[self.file.detail.thumbMediumUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] placeholderImage:nil];

    if(self.file.contentType == ContentTypeVideo) {
        if(!playIconView) {
            playIconView = [[UIImageView alloc] initWithFrame:CGRectMake(4, self.frame.size.height - 22, 18, 18)];
            playIconView.image = [UIImage imageNamed:@"mini_play_icon.png"];
            [self addSubview:playIconView];

            durationLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(22, self.frame.size.height - 22, self.frame.size.width - 26, 18) withFont:[UIFont fontWithName:@"TurkcellSaturaDem" size:15] withColor:[UIColor whiteColor] withText:self.file.contentLengthDisplay];
            durationLabel.textAlignment = NSTextAlignmentRight;
            [self addSubview:durationLabel];
        } else {
            playIconView.hidden = NO;
            durationLabel.hidden = NO;
            durationLabel.text = self.file.contentLengthDisplay;
        }
    } else {
        if(playIconView){
            playIconView.hidden = YES;
            durationLabel.hidden = YES;
        }
    }
}

- (id) initLocalWithFrame:(CGRect)frame withAsset:(ALAsset *)_asset withSelectibleStatus:(BOOL)selectibleStatus {
    self = [super initWithFrame:frame];
    if (self) {
        self.file = nil;
        self.asset = _asset;
        self.backgroundColor = [Util UIColorForHexColor:@"E3E3E3"];
        isSelectible = selectibleStatus;
        
        self.imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        self.imgView.contentMode = UIViewContentModeScaleAspectFill;
        self.imgView.clipsToBounds = YES;
        [self addSubview:self.imgView];
        
        self.progressSeparator = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height-6, 1, 6)];
        self.progressSeparator.backgroundColor = [Util UIColorForHexColor:@"3fb0e8"];
        self.progressSeparator.alpha = 0.75f;
        [self addSubview:self.progressSeparator];

        longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressed:)];
        longPressGesture.minimumPressDuration = Long_Press_Duration;
        longPressGesture.allowableMovement = 10.0f;
        longPressGesture.delegate = self;
        [self addGestureRecognizer:longPressGesture];
        
        tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageTapped)];
        tapGesture.numberOfTapsRequired = 1;
        tapGesture.delegate = self;
        [tapGesture requireGestureRecognizerToFail:longPressGesture];
        [self addGestureRecognizer:tapGesture];

        [self refreshManagerDelegateByAsset];
    }
    return self;
}

- (void) refreshLocalContent:(ALAsset *) newAsset {
    self.file = nil;
    self.asset = newAsset;
    [self.imgView setImage:nil];
    if(playIconView){
        playIconView.hidden = YES;
        durationLabel.hidden = YES;
    }
    BOOL isDelegateSet = [self refreshManagerDelegateByAsset];
    if(!isDelegateSet) {
        if(self.progressSeparator) {
            self.progressSeparator.hidden = YES;
        }
    } else {
        if(self.progressSeparator) {
            self.progressSeparator.hidden = NO;
        }
    }
}

- (BOOL) refreshManagerDelegateByAsset {
    if(self.asset != nil) {
        NSMutableArray *managersArray = [[UploadQueue sharedInstance].uploadManagers copy];
        for(UploadManager *manager in managersArray) {
            if(!manager.uploadRef.hasFinished && [[manager uniqueUrl] isEqualToString:[self.asset.defaultRepresentation.url absoluteString]]) {
                manager.delegate = self;
                return YES;
            }
        }
    }
    return NO;
}

- (id)initWithFrame:(CGRect)frame withUploadRef:(UploadRef *)ref {
    self = [super initWithFrame:frame];
    if (self) {
        self.uploadRef = ref;
        self.backgroundColor = [Util UIColorForHexColor:@"E3E3E3"];
        
        self.imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        self.imgView.contentMode = UIViewContentModeScaleAspectFill;
        self.imgView.clipsToBounds = YES;
        self.imgView.alpha = 0.5f;
//        imgView.image = [UIImage imageNamed:@"square_placeholder.png"];
        [self addSubview:self.imgView];

        [self loadUploadRef];
        
        self.progressSeparator = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height-6, 1, 6)];
        self.progressSeparator.backgroundColor = [Util UIColorForHexColor:@"3fb0e8"];
        self.progressSeparator.alpha = 0.75f;
        [self addSubview:self.progressSeparator];

        maskView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        maskView.image = [UIImage imageNamed:@"selected_mask.png"];
        maskView.hidden = YES;
        [self addSubview:maskView];
        
        tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageTapped)];
        tapGesture.numberOfTapsRequired = 1;
        [self addGestureRecognizer:tapGesture];

//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(managerNotifyReceived:) name:TEMP_IMG_UPLOAD_NOTIFICATION object:nil];
        
    }
    return self;
}

- (void) refresh:(UploadRef *)ref {
    self.uploadRef = ref;
    [self loadUploadRef];
}

- (void) loadUploadRef {
    @autoreleasepool {
        /*
         UIImage *image = [[UIImage alloc] initWithContentsOfFile:self.uploadRef.tempThumbnailUrl];
         dispatch_async(dispatch_get_main_queue(), ^{
         imgView.image = image;
         });
         */
        
        //ALAssetsLibrary'den alir hale getirildi mahir-26.02.15
        if(self.uploadRef.taskType == UploadTaskTypeAsset) {
            if(self.uploadRef.assetUrl) {
                NSURL *assetUrl = [NSURL URLWithString:self.uploadRef.assetUrl];
                ALAssetsLibrary *assetsLibraryForSingle = [[ALAssetsLibrary alloc] init];
                [assetsLibraryForSingle assetForURL:assetUrl resultBlock:^(ALAsset *myAsset) {
                    if(myAsset) {
                        CGImageRef thumbnailRef = [myAsset thumbnail];
                        if (thumbnailRef) {
                            self.imgView.image = [UIImage imageWithCGImage:thumbnailRef];
                        }
                    } else {
                        [assetsLibraryForSingle enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
                            [group enumerateAssetsWithOptions:NSEnumerationReverse usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                                if([[result.defaultRepresentation.url absoluteString] isEqualToString:self.uploadRef.assetUrl]) {
                                    CGImageRef thumbnailRef = [result thumbnail];
                                    if (thumbnailRef) {
                                        self.imgView.image = [UIImage imageWithCGImage:thumbnailRef];
                                    }
                                }
                            }];
                        } failureBlock:nil];
                    }
                } failureBlock:nil];
            }
        } else if(self.uploadRef.taskType == UploadTaskTypeFile) {
            UIImage *thumbImageFromCam = [UIImage imageWithContentsOfFile:self.uploadRef.tempUrl];
            self.imgView.image = [Util imageWithImage:thumbImageFromCam scaledToFillSize:CGSizeMake(40, 40)];
        }
    }
    NSMutableArray *managersArray = [[UploadQueue sharedInstance].uploadManagers copy];
    for(UploadManager *manager in managersArray) {
        if(!manager.uploadRef.hasFinished && [manager.uploadRef.fileUuid isEqualToString:self.uploadRef.fileUuid]) {
            manager.delegate = self;
        }
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return YES;
}

- (void) managerNotifyReceived:(NSNotification *) notification {
    NSDictionary *userInfo = notification.userInfo;
    NSString *fileUuid = [userInfo objectForKey:TEMP_IMG_UPLOAD_NOTIFICATION_UUID_PARAM];
    NSString *tempThumbnailPath = [userInfo objectForKey:TEMP_IMG_UPLOAD_NOTIFICATION_URL_PARAM];
    if(fileUuid && self.uploadRef) {
        if([self.uploadRef.fileUuid isEqualToString:fileUuid]) {
            self.uploadRef.tempThumbnailUrl = tempThumbnailPath;
            /*
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul), ^(void) {
                @autoreleasepool {
                    UIImage *image = [[UIImage alloc] initWithContentsOfFile:self.uploadRef.tempThumbnailUrl];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        imgView.image = image;
                    });
                }
            });
             */
            
            UIImage *image = [[UIImage alloc] initWithContentsOfFile:self.uploadRef.tempThumbnailUrl];
            self.imgView.image = image;
        }
    }
}

- (void) setNewStatus:(BOOL) newStatus {
    isSelectible = newStatus;
    isMarked = NO;
    if(maskView) {
        maskView.hidden = YES;
    }
}

- (void) manuallyDeselect {
    isMarked = NO;
    if(maskView) {
        maskView.hidden = YES;
    }
}

- (void) manuallySelect {
    isMarked = YES;
    if(maskView) {
        maskView.hidden = NO;
    } else {
        maskView = [[UIImageView alloc] initWithFrame:CGRectMake(-1, -1, self.frame.size.width+2, self.frame.size.height+2)];
        maskView.image = [UIImage imageNamed:@"selected_mask.png"];
        [self addSubview:maskView];
    }
}

- (void) showProgressMask {
    if(maskView) {
        maskView.hidden = YES;
    }
    self.imgView.alpha = 0.25f;
}

- (void) old_touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if(self.uploadRef != nil) {
        return;
    }
    
    if(isSelectible) {
        isMarked = !isMarked;
        if(isMarked) {
            if(maskView) {
                maskView.hidden = NO;
            } else {
                maskView = [[UIImageView alloc] initWithFrame:CGRectMake(-1, -1, self.frame.size.width+2, self.frame.size.height+2)];
                maskView.image = [UIImage imageNamed:@"selected_mask.png"];
                [self addSubview:maskView];
            }
            [delegate squareImageWasMarkedForFile:self.file];
        } else {
            if(maskView) {
                maskView.hidden = YES;
            }
            [delegate squareImageWasUnmarkedForFile:self.file];
        }
    } else {
        [delegate squareImageWasSelectedForFile:self.file];
    }
}

- (void) longPressed:(UILongPressGestureRecognizer*)sender {
    if (sender.state == UIGestureRecognizerStateBegan) {
        if(isSelectible) {
            [self imageTapped];
        } else {
            if(self.file != nil) {
                [delegate squareImageWasLongPressedForFile:self.file];
            } else if(self.asset != nil) {
                [delegate squareLocalImageWasLongPressedForAsset:self.asset];
            }
            //TODO bunu check et. 0.0'ı arttırdığımızda başka resim check'leniyor!
            //EDIT: 0.0 durumunda da yanlis fotograf secebiliyodu. Direk cagirmak recognizerstate degisikligi ile sorunu cozmus gorunuyor.
//            [self performSelector:@selector(imageTapped) withObject:nil afterDelay:0.0f];
            [self imageTapped];
        }
    }
}

- (void) imageTapped {
    if(self.uploadRef != nil) {
        if(self.file == nil) {
            if(uploadErrorType == UploadErrorTypeQuota) {
                if(self.file != nil) {
                    [delegate squareImageUploadQuotaError:self.file];
                } else if(self.asset != nil) {
                    [delegate squareLocalImageUploadQuotaError:self.asset];
                }
                return;
            } else if(uploadErrorType == UploadErrorTypeLogin) {
                if(self.file != nil) {
                    [delegate squareImageUploadLoginError:self.file];
                } else if(self.asset != nil) {
                    [delegate squareLocalImageUploadLoginError:self.asset];
                }
                return;
            }
        }
        if(self.file != nil) {
            [delegate squareImageWasSelectedForView:self];
        } else if(self.asset != nil) {
            [delegate squareLocalImageWasSelectedForView:self];
        }
    } else {
        if(isSelectible) {
            isMarked = !isMarked;
            if(isMarked) {
                if(maskView) {
                    maskView.hidden = NO;
                } else {
                    maskView = [[UIImageView alloc] initWithFrame:CGRectMake(-1, -1, self.frame.size.width+2, self.frame.size.height+2)];
                    maskView.image = [UIImage imageNamed:@"selected_mask.png"];
                    [self addSubview:maskView];
                }
                if(self.file != nil) {
                    [delegate squareImageWasMarkedForFile:self.file];
                } else if(self.asset != nil) {
                    [delegate squareLocalImageWasMarkedForAsset:self.asset];
                }
            } else {
                if(maskView) {
                    maskView.hidden = YES;
                }
                if(self.file != nil) {
                    [delegate squareImageWasUnmarkedForFile:self.file];
                } else if(self.asset != nil) {
                    [delegate squareLocalImageWasUnmarkedForAsset:self.asset];
                }
            }
        } else {
            if(self.file != nil) {
                [delegate squareImageWasSelectedForFile:self.file];
            } else if(self.asset != nil) {
                [delegate squareLocalImageWasSelectedForAsset:self.asset];
            }
        }
    }
}

- (void) recheckAndDrawProgress {
    if(self.uploadRef.hasFinished) {
        self.imgView.alpha = 1.0f;
        self.progressSeparator.frame = CGRectMake(0, self.frame.size.height-6, self.frame.size.width, 6);
        if(self.uploadRef.hasFinishedWithError) {
            self.progressSeparator.backgroundColor = [Util UIColorForHexColor:@"ad3110"];
        } else {
            self.progressSeparator.backgroundColor = [Util UIColorForHexColor:@"67d74b"];
        }
    }
}

- (void) uploadManagerDidSendData:(long)sentBytes inTotal:(long)totalBytes {
    int progressWidth = sentBytes*self.frame.size.width/totalBytes;
    [self performSelectorOnMainThread:@selector(updateProgressByWidth:) withObject:[NSNumber numberWithInt:progressWidth] waitUntilDone:NO];
}

- (void) updateProgressByWidth:(NSNumber *) newWidth {
    self.progressSeparator.frame = CGRectMake(0, self.frame.size.height-6, [newWidth intValue], 6);
}

- (void) uploadManagerDidFailUploadingForAsset:(NSString *) assetToUpload {
    self.progressSeparator.backgroundColor = [Util UIColorForHexColor:@"ad3110"];
}

- (void) uploadManagerQuotaExceedForAsset:(NSString *) assetToUpload {
    uploadErrorType = UploadErrorTypeQuota;

    [self updateProgressByWidth:[NSNumber numberWithLong:self.frame.size.width]];
    self.progressSeparator.backgroundColor = [Util UIColorForHexColor:@"ad3110"];
}

- (void) uploadManagerLoginRequiredForAsset:(NSString *) assetToUpload {
    uploadErrorType = UploadErrorTypeLogin;

    [self updateProgressByWidth:[NSNumber numberWithLong:self.frame.size.width]];
    self.progressSeparator.backgroundColor = [Util UIColorForHexColor:@"ad3110"];
}

- (void) uploadManagerDidFinishUploadingForAsset:(NSString *)assetToUpload withFinalFile:(MetaFile *) finalFile {
    self.file = finalFile;
    [self updateProgressByWidth:[NSNumber numberWithLong:self.frame.size.width]];
    self.progressSeparator.backgroundColor = [Util UIColorForHexColor:@"67d74b"];
    self.imgView.alpha = 1.0f;
    if([delegate respondsToSelector:@selector(squareImageUploadFinishedForFile:)]) {
        if(self.uploadRef != nil) {
            [delegate squareImageUploadFinishedForFile:self.uploadRef.fileUuid];
        } else if(self.asset != nil) {
            [delegate squareLocalImageUploadFinishedForAsset:self.asset];
        }
    }
}

- (void) uploadManagerDidFailUploadingAsData {
    [self updateProgressByWidth:[NSNumber numberWithLong:self.frame.size.width]];
    self.progressSeparator.backgroundColor = [Util UIColorForHexColor:@"ad3110"];
}

- (void) uploadManagerDidFinishUploadingAsData {
    [self updateProgressByWidth:[NSNumber numberWithLong:self.frame.size.width]];
    self.progressSeparator.backgroundColor = [Util UIColorForHexColor:@"67d74b"];
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

- (void) unloadContent {
    if(self.imgView) {
        [self.imgView removeFromSuperview];
        self.imgView = nil;
    }
    if(maskView) {
        [maskView removeFromSuperview];
        maskView = nil;
    }
    wasUnloaded = YES;
}

- (void) reloadContent {
    if(wasUnloaded) {
        wasUnloaded = NO;
        if(!self.imgView) {
            self.imgView = [[UIImageView alloc] initWithFrame:CGRectMake(-1, -1, self.frame.size.width+2, self.frame.size.height+2)];
            self.imgView.contentMode = UIViewContentModeScaleAspectFill;
            self.imgView.clipsToBounds = YES;
            [self.imgView sd_setImageWithURL:[NSURL URLWithString:[self.file.detail.thumbMediumUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] placeholderImage:nil];
            [self addSubview:self.imgView];
        }
    }
}

@end
