//
//  RevisitedGroupedPhotoView.h
//  Depo
//
//  Created by Mahir Tarlan on 09/08/16.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MetaFile.h"
#import "SearchByGroupDao.h"
#import "FooterActionsMenuView.h"
#import "NoItemCell.h"
#import "GroupedPhotosCell.h"

@protocol RevisitedGroupedPhotoDelegate <NSObject>
- (void) RevisitedGroupedPhotoDidSelectFile:(MetaFile *) fileSelected withList:(NSArray *) containingList;
- (void) RevisitedGroupedPhotoDidFinishLoading;
- (void) RevisitedGroupedPhotoDidFailRetrievingList:(NSString *) errorMessage;
- (void) RevisitedGroupedPhotoDidFailDeletingWithError:(NSString *) errorMessage;
- (void) RevisitedGroupedPhotoShouldShowLoading;
- (void) RevisitedGroupedPhotoShouldHideLoading;
- (void) RevisitedGroupedPhotoChangeTitleTo:(NSString *) pageTitle;
@end

@interface RevisitedGroupedPhotoView : UIView

@property (nonatomic, weak) id<RevisitedGroupedPhotoDelegate> delegate;
@property (nonatomic, strong) NSMutableArray *groups;
@property (nonatomic, strong) NSMutableArray *selectedFileList;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, strong) UITableView *groupTable;
@property (nonatomic, strong) SearchByGroupDao *collDao;
@property (nonatomic, strong) FooterActionsMenuView *imgFooterActionMenu;
@property (nonatomic) BOOL isSelectible;

@end
