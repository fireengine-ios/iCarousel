//
//  RevisitedRawPhotoCollCell.m
//  Depo
//
//  Created by Mahir Tarlan on 10/01/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

#import "RevisitedRawPhotoCollCell.h"

@interface RevisitedRawPhotoCollCell()
@property (nonatomic, strong) UIImageView *maskView;
@property (nonatomic, strong) UIImageView *imgView;
@property (nonatomic, strong) UIImageView *playIconView;
@property (nonatomic, strong) UIImageView *notSyncedImgView;
@property (nonatomic, strong) NSString *groupKey;
@property (nonatomic, assign) BOOL isSelectible;
@property (nonatomic, strong) SquareImageView *sqImageView;
@end

@implementation RevisitedRawPhotoCollCell


- (void) loadContent:(RawTypeFile *) content isSelectible:(BOOL) selectFlag withImageWidth:(float) imageWidth withGroupKey:(NSString *) groupKey isSelected:(BOOL) selectedFlag {
    self.rawData = content;

    self.isSelectible = selectFlag;
    self.groupKey = groupKey;
    
    if(content.rawType == RawFileTypeDepo) {
        if(self.notSyncedImgView) {
            [self.notSyncedImgView removeFromSuperview];
            self.notSyncedImgView = nil;
        }
        if(!self.sqImageView) {
            self.sqImageView = [[SquareImageView alloc] initCachedFinalWithFrame:CGRectMake(0, 0, imageWidth, imageWidth) withFile:content.fileRef withSelectibleStatus:self.isSelectible];
            self.sqImageView.delegate = self;
            [self addSubview:self.sqImageView];
        } else {
            [self.sqImageView refreshContent:content.fileRef];
        }
    } else {
        if(!self.sqImageView) {
            self.sqImageView = [[SquareImageView alloc] initLocalWithFrame:CGRectMake(0, 0, imageWidth, imageWidth) withAsset:content.assetRef withSelectibleStatus:self.isSelectible];
            self.sqImageView.delegate = self;
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                CGImageRef thumbnailImageRef = [content.assetRef aspectRatioThumbnail];
                __block UIImage *thumbnailImage = [UIImage imageWithCGImage:thumbnailImageRef];
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.sqImageView.imgView.image = thumbnailImage;
                });
            });            
            [self addSubview:self.sqImageView];
        } else {
            [self.sqImageView refreshLocalContent:content.assetRef];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                CGImageRef thumbnailImageRef = [content.assetRef aspectRatioThumbnail];
                __block UIImage *thumbnailImage = [UIImage imageWithCGImage:thumbnailImageRef];
               dispatch_async(dispatch_get_main_queue(), ^{
                   self.sqImageView.imgView.image = thumbnailImage;
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
        
        if(!self.notSyncedImgView) {
            self.notSyncedImgView = [[UIImageView alloc] initWithFrame:CGRectMake(self.frame.size.width - 20, self.frame.size.height - 20, 16, 16)];
            self.notSyncedImgView.image = [UIImage imageNamed:@"icon_notsync"];
            [self addSubview:self.notSyncedImgView];
        }

        if(!self.maskView) {
            self.maskView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
            self.maskView.image = [UIImage imageNamed:@"selected_mask.png"];
            [self addSubview:self.maskView];
        }
        
        self.maskView.hidden = !self.isSelected;
    }
    [self.sqImageView setNewStatus:selectFlag];
    
    if(selectFlag && selectedFlag) {
        [self.sqImageView manuallySelect];
    } else {
        [self.sqImageView manuallyDeselect];
    }
}

- (void) squareImageWasSelectedForFile:(MetaFile *) fileSelected {
    [self.delegate rawPhotoCollCellImageWasSelectedForFile:fileSelected forGroupWithKey:self.groupKey];
}

- (void) squareImageWasMarkedForFile:(MetaFile *) fileSelected {
    [self.delegate rawPhotoCollCellImageWasMarkedForFile:fileSelected];
}

- (void) squareImageWasUnmarkedForFile:(MetaFile *) fileSelected {
    [self.delegate rawPhotoCollCellImageWasUnmarkedForFile:fileSelected];
}

- (void) squareImageUploadFinishedForFile:(NSString *) fileSelectedUuid {
    [self.delegate rawPhotoCollCellImageUploadFinishedForFile:fileSelectedUuid];
}

- (void) squareImageWasLongPressedForFile:(MetaFile *) fileSelected {
    [self.sqImageView setNewStatus:YES];
    [self.delegate rawPhotoCollCellImageWasLongPressedForFile:fileSelected];
}

- (void) squareImageUploadQuotaError:(MetaFile *) fileSelected {
    [self.delegate rawPhotoCollCellImageUploadQuotaError:fileSelected];
}

- (void) squareImageUploadLoginError:(MetaFile *) fileSelected {
    [self.delegate rawPhotoCollCellImageUploadLoginError:fileSelected];
}

- (void) squareImageWasSelectedForView:(SquareImageView *) ref {
    [self.delegate rawPhotoCollCellImageWasSelectedForView:ref];
}

- (void) squareLocalImageWasSelectedForAsset:(ALAsset *) fileSelected {
    [self.delegate rawPhotoCollCellImageWasSelectedForAsset:fileSelected];
}

- (void) squareLocalImageWasMarkedForAsset:(ALAsset *) fileSelected {
    [self.delegate rawPhotoCollCellImageWasMarkedForAsset:fileSelected];
}

- (void) squareLocalImageWasUnmarkedForAsset:(ALAsset *) fileSelected {
    [self.delegate rawPhotoCollCellImageWasUnmarkedForAsset:fileSelected];
}

- (void) squareLocalImageUploadFinishedForAsset:(ALAsset *) fileSelected {
    [self.delegate rawPhotoCollCellImageUploadFinishedForAsset:fileSelected];
}

- (void) squareLocalImageWasLongPressedForAsset:(ALAsset *) fileSelected {
    [self.sqImageView setNewStatus:YES];
    [self.delegate rawPhotoCollCellImageWasLongPressedForAsset:fileSelected];
}

- (void) squareLocalImageUploadQuotaError:(ALAsset *) fileSelected {
    [self.delegate rawPhotoCollCellImageUploadQuotaErrorForAsset:fileSelected];
}

- (void) squareLocalImageUploadLoginError:(ALAsset *) fileSelected {
    [self.delegate rawPhotoCollCellImageUploadLoginErrorForAsset:fileSelected];
}

- (void) squareLocalImageWasSelectedForView:(SquareImageView *) ref {
}

@end
