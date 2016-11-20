//
//  RevisitedUploadingPhotoCollCell.h
//  Depo
//
//  Created by Mahir Tarlan on 17/11/16.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SquareImageView.h"

@protocol RevisitedUploadingPhotoCollCellDelegate <NSObject>
- (void) revisitedUploadingPhotoCollCellImageWasSelectedForFile:(MetaFile *) fileSelected forGroupWithKey:(NSString *) groupKey;
- (void) revisitedUploadingPhotoCollCellImageWasMarkedForFile:(MetaFile *) fileSelected;
- (void) revisitedUploadingPhotoCollCellImageWasUnmarkedForFile:(MetaFile *) fileSelected;
- (void) revisitedUploadingPhotoCollCellImageUploadFinishedForFile:(NSString *) fileSelectedUuid;
- (void) revisitedUploadingPhotoCollCellImageWasLongPressedForFile:(MetaFile *) fileSelected;
- (void) revisitedUploadingPhotoCollCellImageUploadQuotaError:(MetaFile *) fileSelected;
- (void) revisitedUploadingPhotoCollCellImageUploadLoginError:(MetaFile *) fileSelected;
- (void) revisitedUploadingPhotoCollCellImageWasSelectedForView:(SquareImageView *) ref;
@end

@interface RevisitedUploadingPhotoCollCell : UICollectionViewCell <SquareImageDelegate>

@property (nonatomic, weak) id<RevisitedUploadingPhotoCollCellDelegate> delegate;
@property (nonatomic, strong) SquareImageView *sqImageView;
@property (nonatomic, strong) NSString *groupKey;
@property (nonatomic) BOOL isSelectible;

- (void) loadContent:(UploadRef *) content isSelectible:(BOOL) selectFlag withImageWidth:(float) imageWidth withGroupKey:(NSString *) _groupKey isSelected:(BOOL) selectedFlag;

@end
