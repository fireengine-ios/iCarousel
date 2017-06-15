//
//  RevisitedPhotoCollCell.h
//  Depo
//
//  Created by Mahir Tarlan on 13/11/16.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SquareImageView.h"

@protocol RevisitedPhotoCollCellDelegate <NSObject>
- (void) revisitedPhotoCollCellImageWasSelectedForFile:(MetaFile *) fileSelected forGroupWithKey:(NSString *) groupKey;
- (void) revisitedPhotoCollCellImageWasMarkedForFile:(MetaFile *) fileSelected;
- (void) revisitedPhotoCollCellImageWasUnmarkedForFile:(MetaFile *) fileSelected;
- (void) revisitedPhotoCollCellImageUploadFinishedForFile:(NSString *) fileSelectedUuid;
- (void) revisitedPhotoCollCellImageWasLongPressedForFile:(MetaFile *) fileSelected;
- (void) revisitedPhotoCollCellImageUploadQuotaError:(MetaFile *) fileSelected;
- (void) revisitedPhotoCollCellImageUploadLoginError:(MetaFile *) fileSelected;
- (void) revisitedPhotoCollCellImageWasSelectedForView:(SquareImageView *) ref;
@end

@interface RevisitedPhotoCollCell : UICollectionViewCell <SquareImageDelegate>

@property (nonatomic, weak) id<RevisitedPhotoCollCellDelegate> delegate;
@property (nonatomic, strong) SquareImageView *sqImageView;
@property (nonatomic, strong) NSString *groupKey;
@property (nonatomic) BOOL isSelectible;

- (void) loadContent:(MetaFile *) content isSelectible:(BOOL) selectFlag withImageWidth:(float) imageWidth withGroupKey:(NSString *) _groupKey isSelected:(BOOL) selectedFlag;

- (void) loadArbitraryContent:(id) content isSelectible:(BOOL) selectFlag withImageWidth:(float) imageWidth withGroupKey:(NSString *) _groupKey isSelected:(BOOL) selectedFlag;

@end
