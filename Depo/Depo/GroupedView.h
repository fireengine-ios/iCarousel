//
//  GroupedView.h
//  Depo
//
//  Created by Mahir Tarlan on 10/09/16.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppConstants.h"
#import "SquareImageView.h"
#import "FileInfoGroup.h"

@protocol GroupedViewDelegate <NSObject>
- (void) groupedViewImageWasSelectedForFile:(MetaFile *) fileSelected forGroupWithKey:(NSString *) groupKey;
- (void) groupedViewImageWasMarkedForFile:(MetaFile *) fileSelected;
- (void) groupedViewImageWasUnmarkedForFile:(MetaFile *) fileSelected;
- (void) groupedViewImageUploadFinishedForFile:(NSString *) fileSelectedUuid;
- (void) groupedViewImageWasLongPressedForFile:(MetaFile *) fileSelected;
- (void) groupedViewImageUploadQuotaError:(MetaFile *) fileSelected;
- (void) groupedViewImageUploadLoginError:(MetaFile *) fileSelected;
- (void) groupedViewImageWasSelectedForView:(SquareImageView *) ref;
@end

@interface GroupedView : UIView <SquareImageDelegate>

@property (nonatomic, weak) id<GroupedViewDelegate> delegate;
@property (nonatomic, strong) FileInfoGroup *group;
@property (nonatomic) BOOL isSelectible;

- (id) initWithFrame:(CGRect) frame withGroup:(FileInfoGroup *) _group isSelectible:(BOOL) selectFlag withImageWidth:(float) imageWidth withImageCountPerRow:(int) imageCountPerRow;
- (void) loadMoreImages:(NSArray *) moreImages;
- (void) setToSelectible;
- (void) setToUnselectible;

@end
