//
//  RevisitedRawPhotoCollCell.h
//  Depo
//
//  Created by Mahir Tarlan on 10/01/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RawTypeFile.h"
#import "SquareImageView.h"
#import <AssetsLibrary/AssetsLibrary.h>

@protocol RawPhotoCollCellDelegate <NSObject>
- (void) rawPhotoCollCellImageWasSelectedForFile:(MetaFile *) fileSelected forGroupWithKey:(NSString *) groupKey;
- (void) rawPhotoCollCellImageWasMarkedForFile:(MetaFile *) fileSelected;
- (void) rawPhotoCollCellImageWasUnmarkedForFile:(MetaFile *) fileSelected;
- (void) rawPhotoCollCellImageUploadFinishedForFile:(NSString *) fileSelectedUuid;
- (void) rawPhotoCollCellImageWasLongPressedForFile:(MetaFile *) fileSelected;
- (void) rawPhotoCollCellImageUploadQuotaError:(MetaFile *) fileSelected;
- (void) rawPhotoCollCellImageUploadLoginError:(MetaFile *) fileSelected;
- (void) rawPhotoCollCellImageWasSelectedForView:(SquareImageView *) ref;
- (void) rawPhotoCollCellAssetDidBecomeSelected:(ALAsset *) selectedAsset;
- (void) rawPhotoCollCellAssetDidBecomeDeselected:(ALAsset *) deselectedAsset;
@end

@interface RevisitedRawPhotoCollCell : UICollectionViewCell <SquareImageDelegate>

@property (nonatomic, weak) id<RawPhotoCollCellDelegate> delegate;

@property (nonatomic, strong) RawTypeFile *rawData;

- (void) loadContent:(RawTypeFile *) content isSelectible:(BOOL) selectFlag withImageWidth:(float) imageWidth withGroupKey:(NSString *) _groupKey isSelected:(BOOL) selectedFlag;

@end
