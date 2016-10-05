//
//  SquareImageView.h
//  Depo
//
//  Created by Mahir on 10/8/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MetaFile.h"
#import "UploadManager.h"
#import "UploadRef.h"

@class SquareImageView;

@protocol SquareImageDelegate <NSObject>
- (void) squareImageWasSelectedForFile:(MetaFile *) fileSelected;
- (void) squareImageWasMarkedForFile:(MetaFile *) fileSelected;
- (void) squareImageWasUnmarkedForFile:(MetaFile *) fileSelected;
- (void) squareImageUploadFinishedForFile:(NSString *) fileSelectedUuid;
- (void) squareImageWasLongPressedForFile:(MetaFile *) fileSelected;
- (void) squareImageUploadQuotaError:(MetaFile *) fileSelected;
- (void) squareImageUploadLoginError:(MetaFile *) fileSelected;
- (void) squareImageWasSelectedForView:(SquareImageView *) ref;
@end

@interface SquareImageView : UIView <UploadManagerDelegate, UIGestureRecognizerDelegate> {
    UIView *progressSeparator;
    UIImageView *maskView;
    BOOL isSelectible;
    BOOL isMarked;
    UploadErrorType uploadErrorType;
}

@property (nonatomic, weak) id<SquareImageDelegate> delegate;
@property (nonatomic, strong) MetaFile *file;
@property (nonatomic, strong) UploadRef *uploadRef;
@property (nonatomic, strong) UILongPressGestureRecognizer *longPressGesture;
@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;
@property (nonatomic, strong) UIImageView *imgView;

- (id)initWithFrame:(CGRect)frame withFile:(MetaFile *) _file;
- (id)initWithFrame:(CGRect)frame withUploadRef:(UploadRef *) ref;
- (id)initWithFrame:(CGRect)frame withFile:(MetaFile *) _file withSelectibleStatus:(BOOL) selectibleStatus;
- (id)initWithFrame:(CGRect)frame withFile:(MetaFile *) _file withSelectibleStatus:(BOOL) selectibleStatus shouldCache:(BOOL) cacheFlag;
- (id)initWithFrame:(CGRect)frame withFile:(MetaFile *) _file withSelectibleStatus:(BOOL) selectibleStatus shouldCache:(BOOL) cacheFlag manualQuality:(BOOL) manualQuality;
- (id) initFinalWithFrame:(CGRect)frame withFile:(MetaFile *) _file withSelectibleStatus:(BOOL) selectibleStatus;
- (void) setNewStatus:(BOOL) newStatus;
- (void) showProgressMask;
- (void) manuallyDeselect;

@end
