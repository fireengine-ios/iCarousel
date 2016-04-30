//
//  GroupedPhotosCell.h
//  Depo
//
//  Created by Mahir Tarlan on 26/04/16.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FileInfoGroup.h"
#import "AppConstants.h"
#import "SquareImageView.h"

@protocol GroupedPhotosCellDelegate <NSObject>
- (void) groupedPhotoCellImageWasSelectedForFile:(MetaFile *) fileSelected forGroupWithKey:(NSString *) groupKey;
- (void) groupedPhotoCellImageWasMarkedForFile:(MetaFile *) fileSelected;
- (void) groupedPhotoCellImageWasUnmarkedForFile:(MetaFile *) fileSelected;
- (void) groupedPhotoCellImageUploadFinishedForFile:(NSString *) fileSelectedUuid;
- (void) groupedPhotoCellImageWasLongPressedForFile:(MetaFile *) fileSelected;
- (void) groupedPhotoCellImageUploadQuotaError:(MetaFile *) fileSelected;
- (void) groupedPhotoCellImageUploadLoginError:(MetaFile *) fileSelected;
- (void) groupedPhotoCellImageWasSelectedForView:(SquareImageView *) ref;
@end

@interface GroupedPhotosCell : UITableViewCell <SquareImageDelegate>

@property (nonatomic, weak) id<GroupedPhotosCellDelegate> delegate;
@property (nonatomic, strong) FileInfoGroup *group;

- (id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withGroup:(FileInfoGroup *) _group withLevel:(ImageGroupLevel) level isSelectible:(BOOL) selectFlag;

@end
