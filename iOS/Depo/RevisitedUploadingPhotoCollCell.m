//
//  RevisitedUploadingPhotoCollCell.m
//  Depo
//
//  Created by Mahir Tarlan on 17/11/16.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import "RevisitedUploadingPhotoCollCell.h"

@implementation RevisitedUploadingPhotoCollCell

@synthesize delegate;
@synthesize sqImageView;
@synthesize isSelectible;
@synthesize groupKey;

- (void) loadContent:(UploadRef *) content isSelectible:(BOOL) selectFlag withImageWidth:(float) imageWidth withGroupKey:(NSString *) _groupKey isSelected:(BOOL) selectedFlag {
    self.isSelectible = selectFlag;
    self.groupKey = _groupKey;
    
    if(sqImageView) {
        sqImageView.delegate = nil;
        [sqImageView removeFromSuperview];
    }
    sqImageView = [[SquareImageView alloc] initWithFrame:CGRectMake(0, 0, imageWidth, imageWidth) withUploadRef:content];
    sqImageView.delegate = self;
    [self addSubview:sqImageView];
    [sqImageView recheckAndDrawProgress];
    /*
     if(!sqImageView) {
     sqImageView = [[SquareImageView alloc] initWithFrame:CGRectMake(0, 0, imageWidth, imageWidth) withUploadRef:castedRow];
     sqImageView.delegate = self;
     [self addSubview:sqImageView];
     } else {
     [sqImageView refresh:castedRow];
     }
     */
    //        [sqImageView setNewStatus:selectFlag];

    
}

- (void) squareImageWasSelectedForFile:(MetaFile *) fileSelected {
    [delegate revisitedUploadingPhotoCollCellImageWasSelectedForFile:fileSelected forGroupWithKey:self.groupKey];
}

- (void) squareImageWasMarkedForFile:(MetaFile *) fileSelected {
    [delegate revisitedUploadingPhotoCollCellImageWasMarkedForFile:fileSelected];
}

- (void) squareImageWasUnmarkedForFile:(MetaFile *) fileSelected {
    [delegate revisitedUploadingPhotoCollCellImageWasUnmarkedForFile:fileSelected];
}

- (void) squareImageUploadFinishedForFile:(NSString *) fileSelectedUuid {
    [delegate revisitedUploadingPhotoCollCellImageUploadFinishedForFile:fileSelectedUuid];
}

- (void) squareImageWasLongPressedForFile:(MetaFile *) fileSelected {
    [sqImageView setNewStatus:YES];
    [delegate revisitedUploadingPhotoCollCellImageWasLongPressedForFile:fileSelected];
}

- (void) squareImageUploadQuotaError:(MetaFile *) fileSelected {
    [delegate revisitedUploadingPhotoCollCellImageUploadQuotaError:fileSelected];
}

- (void) squareImageUploadLoginError:(MetaFile *) fileSelected {
    [delegate revisitedUploadingPhotoCollCellImageUploadLoginError:fileSelected];
}

- (void) squareImageWasSelectedForView:(SquareImageView *) ref {
    [delegate revisitedUploadingPhotoCollCellImageWasSelectedForView:ref];
}

@end
