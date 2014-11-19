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

@protocol SquareImageDelegate <NSObject>
- (void) squareImageWasSelectedForFile:(MetaFile *) fileSelected;
- (void) squareImageWasMarkedForFile:(MetaFile *) fileSelected;
- (void) squareImageWasUnmarkedForFile:(MetaFile *) fileSelected;
- (void) squareImageUploadFinishedForFile:(NSString *) fileSelectedUuid;
@end

@interface SquareImageView : UIView <UploadManagerDelegate> {
    UIView *progressSeparator;
    UIImageView *imgView;
    UIImageView *maskView;
    BOOL isSelectible;
    BOOL isMarked;
}

@property (nonatomic, strong) id<SquareImageDelegate> delegate;
@property (nonatomic, strong) MetaFile *file;
@property (nonatomic, strong) UploadRef *uploadRef;

- (id)initWithFrame:(CGRect)frame withFile:(MetaFile *) _file;
- (id)initWithFrame:(CGRect)frame withUploadRef:(UploadRef *) ref;
- (void) setNewStatus:(BOOL) newStatus;
- (void) showProgressMask;

@end
