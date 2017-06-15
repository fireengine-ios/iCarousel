//
//  CollCell.h
//  Depo
//
//  Created by Mahir Tarlan on 19/08/16.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FileInfoGroup.h"
#import "AppConstants.h"
#import "SquareImageView.h"

@protocol CollCellDelegate <NSObject>
- (void) collCellImageWasSelectedForFile:(MetaFile *) fileSelected forGroupWithKey:(NSString *) groupKey;
- (void) collCellImageWasMarkedForFile:(MetaFile *) fileSelected;
- (void) collCellImageWasUnmarkedForFile:(MetaFile *) fileSelected;
- (void) collCellImageUploadFinishedForFile:(NSString *) fileSelectedUuid;
- (void) collCellImageWasLongPressedForFile:(MetaFile *) fileSelected;
- (void) collCellImageUploadQuotaError:(MetaFile *) fileSelected;
- (void) collCellImageUploadLoginError:(MetaFile *) fileSelected;
- (void) collCellImageWasSelectedForView:(SquareImageView *) ref;
- (void) collCellMoreSelectedForDate:(NSString *) rangeStart;
@end

@interface CollCell : UITableViewCell <SquareImageDelegate>

@property (nonatomic, weak) id<CollCellDelegate> delegate;
@property (nonatomic, strong) FileInfoGroup *group;
@property (nonatomic) BOOL isSelectible;

- (id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withGroup:(FileInfoGroup *) _group withLevel:(ImageGroupLevel) level isSelectible:(BOOL) selectFlag withImageWidth:(float) imageWidth withImageCountPerRow:(int) imageCountPerRow;

@end
