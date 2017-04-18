//
//  RevisitedRawPhotoCollCell.m
//  Depo
//
//  Created by Mahir Tarlan on 10/01/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

#import "RevisitedRawPhotoCollCell.h"

@interface RevisitedRawPhotoCollCell() {
    UIImageView *maskView;
    UIImageView *imgView;
    UIImageView *playIconView;
    UIImageView *notSyncedImgView;
    SquareImageView *sqImageView;
    NSString *groupKey;
    BOOL isSelectible;
}
@end

@implementation RevisitedRawPhotoCollCell

@synthesize delegate;
@synthesize rawData;

- (void) loadContent:(RawTypeFile *) content isSelectible:(BOOL) selectFlag withImageWidth:(float) imageWidth withGroupKey:(NSString *) _groupKey isSelected:(BOOL) selectedFlag {
    self.rawData = content;

    isSelectible = selectFlag;
    groupKey = _groupKey;
    
    if(content.rawType == RawFileTypeDepo) {
        if(notSyncedImgView) {
            [notSyncedImgView removeFromSuperview];
            notSyncedImgView = nil;
        }
        if(!sqImageView) {
            sqImageView = [[SquareImageView alloc] initCachedFinalWithFrame:CGRectMake(0, 0, imageWidth, imageWidth) withFile:content.fileRef withSelectibleStatus:isSelectible];
            sqImageView.delegate = self;
            [self addSubview:sqImageView];
        } else {
            [sqImageView refreshContent:content.fileRef];
        }
    } else {
        if(!sqImageView) {
            sqImageView = [[SquareImageView alloc] initLocalWithFrame:CGRectMake(0, 0, imageWidth, imageWidth) withAsset:content.assetRef withSelectibleStatus:isSelectible];
            sqImageView.delegate = self;
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                CGImageRef thumbnailImageRef = [content.assetRef aspectRatioThumbnail];
                __block UIImage *thumbnailImage = [UIImage imageWithCGImage:thumbnailImageRef];
                dispatch_async(dispatch_get_main_queue(), ^{
                    sqImageView.imgView.image = thumbnailImage;
                });
            });            
            [self addSubview:sqImageView];
        } else {
            [sqImageView refreshLocalContent:content.assetRef];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                CGImageRef thumbnailImageRef = [content.assetRef aspectRatioThumbnail];
                __block UIImage *thumbnailImage = [UIImage imageWithCGImage:thumbnailImageRef];
               dispatch_async(dispatch_get_main_queue(), ^{
                   sqImageView.imgView.image = thumbnailImage;
               });
            });
        }

        /*
        if(!playIconView) {
            if ([[content.assetRef valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypeVideo]) {
                playIconView = [[UIImageView alloc] initWithFrame:CGRectMake(4, self.frame.size.height - 22, 18, 18)];
                playIconView.image = [UIImage imageNamed:@"mini_play_icon.png"];
                [self addSubview:playIconView];
            }
        } else {
            if (![[content.assetRef valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypeVideo]) {
                [playIconView removeFromSuperview];
                playIconView = nil;
            }
        }
         */
        
        if(!notSyncedImgView) {
            notSyncedImgView = [[UIImageView alloc] initWithFrame:CGRectMake(self.frame.size.width - 20, self.frame.size.height - 20, 16, 16)];
            notSyncedImgView.image = [UIImage imageNamed:@"icon_notsync"];
            [self addSubview:notSyncedImgView];
        }

        if(!maskView) {
            maskView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
            maskView.image = [UIImage imageNamed:@"selected_mask.png"];
            [self addSubview:maskView];
        }
        
        maskView.hidden = !self.isSelected;
    }
    [sqImageView setNewStatus:selectFlag];
    
    if(selectFlag && selectedFlag) {
        [sqImageView manuallySelect];
    } else {
        [sqImageView manuallyDeselect];
    }
}

- (void) squareImageWasSelectedForFile:(MetaFile *) fileSelected {
    [delegate rawPhotoCollCellImageWasSelectedForFile:fileSelected forGroupWithKey:groupKey];
}

- (void) squareImageWasMarkedForFile:(MetaFile *) fileSelected {
    [delegate rawPhotoCollCellImageWasMarkedForFile:fileSelected];
}

- (void) squareImageWasUnmarkedForFile:(MetaFile *) fileSelected {
    [delegate rawPhotoCollCellImageWasUnmarkedForFile:fileSelected];
}

- (void) squareImageUploadFinishedForFile:(NSString *) fileSelectedUuid {
    [delegate rawPhotoCollCellImageUploadFinishedForFile:fileSelectedUuid];
}

- (void) squareImageWasLongPressedForFile:(MetaFile *) fileSelected {
    [sqImageView setNewStatus:YES];
    [delegate rawPhotoCollCellImageWasLongPressedForFile:fileSelected];
}

- (void) squareImageUploadQuotaError:(MetaFile *) fileSelected {
    [delegate rawPhotoCollCellImageUploadQuotaError:fileSelected];
}

- (void) squareImageUploadLoginError:(MetaFile *) fileSelected {
    [delegate rawPhotoCollCellImageUploadLoginError:fileSelected];
}

- (void) squareImageWasSelectedForView:(SquareImageView *) ref {
    [delegate rawPhotoCollCellImageWasSelectedForView:ref];
}

- (void) squareLocalImageWasSelectedForAsset:(ALAsset *) fileSelected {
    [delegate rawPhotoCollCellImageWasSelectedForAsset:fileSelected];
}

- (void) squareLocalImageWasMarkedForAsset:(ALAsset *) fileSelected {
    [delegate rawPhotoCollCellImageWasMarkedForAsset:fileSelected];
}

- (void) squareLocalImageWasUnmarkedForAsset:(ALAsset *) fileSelected {
    [delegate rawPhotoCollCellImageWasUnmarkedForAsset:fileSelected];
}

- (void) squareLocalImageUploadFinishedForAsset:(ALAsset *) fileSelected {
    [delegate rawPhotoCollCellImageUploadFinishedForAsset:fileSelected];
}

- (void) squareLocalImageWasLongPressedForAsset:(ALAsset *) fileSelected {
    [sqImageView setNewStatus:YES];
    [delegate rawPhotoCollCellImageWasLongPressedForAsset:fileSelected];
}

- (void) squareLocalImageUploadQuotaError:(ALAsset *) fileSelected {
    [delegate rawPhotoCollCellImageUploadQuotaErrorForAsset:fileSelected];
}

- (void) squareLocalImageUploadLoginError:(ALAsset *) fileSelected {
    [delegate rawPhotoCollCellImageUploadLoginErrorForAsset:fileSelected];
}

- (void) squareLocalImageWasSelectedForView:(SquareImageView *) ref {
}

@end
