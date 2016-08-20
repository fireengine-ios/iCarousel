//
//  GroupedCell.h
//  Depo
//
//  Created by Mahir Tarlan on 20/08/16.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppConstants.h"
#import "SquareImageView.h"
#import "FileInfoGroup.h"

@protocol GroupedCellDelegate <NSObject>
- (void) groupedCellImageWasSelectedForFile:(MetaFile *) fileSelected forGroupWithKey:(NSString *) groupKey;
- (void) groupedCellImageWasMarkedForFile:(MetaFile *) fileSelected;
- (void) groupedCellImageWasUnmarkedForFile:(MetaFile *) fileSelected;
- (void) groupedCellImageUploadFinishedForFile:(NSString *) fileSelectedUuid;
- (void) groupedCellImageWasLongPressedForFile:(MetaFile *) fileSelected;
- (void) groupedCellImageUploadQuotaError:(MetaFile *) fileSelected;
- (void) groupedCellImageUploadLoginError:(MetaFile *) fileSelected;
- (void) groupedCellImageWasSelectedForView:(SquareImageView *) ref;
@end

@interface GroupedCell : UITableViewCell <SquareImageDelegate>

@property (nonatomic, weak) id<GroupedCellDelegate> delegate;
@property (nonatomic, strong) FileInfoGroup *group;
@property (nonatomic) BOOL isSelectible;

- (id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withGroup:(FileInfoGroup *) _group isSelectible:(BOOL) selectFlag withImageWidth:(float) imageWidth withImageCountPerRow:(int) imageCountPerRow;

@end
