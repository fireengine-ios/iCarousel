//
//  RevisitedPhotoCollCell.m
//  Depo
//
//  Created by Mahir Tarlan on 13/11/16.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import "RevisitedPhotoCollCell.h"
#import "UploadRef.h"
#import "SquareImageView.h"
#import "MetaFile.h"

@implementation RevisitedPhotoCollCell

@synthesize delegate;
@synthesize sqImageView;
@synthesize isSelectible;
@synthesize groupKey;

- (void) loadContent:(MetaFile *) content isSelectible:(BOOL) selectFlag withImageWidth:(float) imageWidth withGroupKey:(NSString *) _groupKey isSelected:(BOOL) selectedFlag {
    self.isSelectible = selectFlag;
    self.groupKey = _groupKey;
    
    if(!sqImageView) {
        sqImageView = [[SquareImageView alloc] initCachedFinalWithFrame:CGRectMake(0, 0, imageWidth, imageWidth) withFile:content withSelectibleStatus:isSelectible];
        sqImageView.delegate = self;
        [self addSubview:sqImageView];
    } else {
        [sqImageView refreshContent:content];
    }
    [sqImageView setNewStatus:selectFlag];
    
    if(selectedFlag) {
        [sqImageView manuallySelect];
    } else {
        [sqImageView manuallyDeselect];
    }
}

- (void) loadArbitraryContent:(id) content isSelectible:(BOOL) selectFlag withImageWidth:(float) imageWidth withGroupKey:(NSString *) _groupKey isSelected:(BOOL) selectedFlag {
    self.isSelectible = selectFlag;
    self.groupKey = _groupKey;
    
    if([content isKindOfClass:[MetaFile class]]) {
        MetaFile *castedContent = (MetaFile *) content;
        if(!sqImageView) {
            sqImageView = [[SquareImageView alloc] initFinalWithFrame:CGRectMake(0, 0, imageWidth, imageWidth) withFile:castedContent withSelectibleStatus:isSelectible];
            sqImageView.delegate = self;
            [self addSubview:sqImageView];
        } else {
            if(![sqImageView.file.detail.thumbMediumUrl isEqualToString:castedContent.detail.thumbMediumUrl]) {
                [sqImageView refreshContent:content];
            }
        }
        [sqImageView setNewStatus:selectFlag];
    } else {
        if(sqImageView) {
            sqImageView.delegate = nil;
            [sqImageView removeFromSuperview];
        }
        sqImageView = [[SquareImageView alloc] initWithFrame:CGRectMake(0, 0, imageWidth, imageWidth) withUploadRef:content];
        sqImageView.delegate = self;
        [self addSubview:sqImageView];
        [sqImageView recheckAndDrawProgress];
    }
    
    if(selectedFlag) {
        [sqImageView manuallySelect];
    } else {
        [sqImageView manuallyDeselect];
    }
}

- (void) prepareForReuse {
    [super prepareForReuse];
//    NSLog(@"At prepareForReuse");
    /*
    if(sqImageView) {
        if(sqImageView.delegate == self) {
            sqImageView.delegate = nil;
        }
        [sqImageView removeFromSuperview];
        sqImageView = nil;
    }
     */
}

- (void) squareImageWasSelectedForFile:(MetaFile *) fileSelected {
    [delegate revisitedPhotoCollCellImageWasSelectedForFile:fileSelected forGroupWithKey:self.groupKey];
}

- (void) squareImageWasMarkedForFile:(MetaFile *) fileSelected {
    [delegate revisitedPhotoCollCellImageWasMarkedForFile:fileSelected];
}

- (void) squareImageWasUnmarkedForFile:(MetaFile *) fileSelected {
    [delegate revisitedPhotoCollCellImageWasUnmarkedForFile:fileSelected];
}

- (void) squareImageUploadFinishedForFile:(NSString *) fileSelectedUuid {
    [delegate revisitedPhotoCollCellImageUploadFinishedForFile:fileSelectedUuid];
}

- (void) squareImageWasLongPressedForFile:(MetaFile *) fileSelected {
    [sqImageView setNewStatus:YES];
    [delegate revisitedPhotoCollCellImageWasLongPressedForFile:fileSelected];
}

- (void) squareImageUploadQuotaError:(MetaFile *) fileSelected {
    [delegate revisitedPhotoCollCellImageUploadQuotaError:fileSelected];
}

- (void) squareImageUploadLoginError:(MetaFile *) fileSelected {
    [delegate revisitedPhotoCollCellImageUploadLoginError:fileSelected];
}

- (void) squareImageWasSelectedForView:(SquareImageView *) ref {
    [delegate revisitedPhotoCollCellImageWasSelectedForView:ref];
}

@end
