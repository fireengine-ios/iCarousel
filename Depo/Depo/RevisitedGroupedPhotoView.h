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
#import "ElasticSearchDao.h"
#import "MBProgressHUD.h"
#import "GroupedCell.h"
#import "DeleteDao.h"
#import "AlbumAddPhotosDao.h"
#import "MainSearchTextfield.h"

@protocol RevisitedGroupedPhotoDelegate <NSObject>
- (void) revisitedGroupedPhotoDidSelectFile:(MetaFile *) fileSelected withList:(NSArray *) containingList;
- (void) revisitedGroupedPhotoDidFinishLoading;
- (void) revisitedGroupedPhotoDidFinishDeleting;
- (void) revisitedGroupedPhotoDidFinishMoving;
- (void) revisitedGroupedPhotoShouldConfirmForDeleting;
- (void) revisitedGroupedPhotoDidChangeToSelectState;
- (void) revisitedGroupedPhotoShouldPrintWithFileList:(NSArray *) fileListToPrint;
- (void) revisitedGroupedPhotoDidFailRetrievingList:(NSString *) errorMessage;
- (void) revisitedGroupedPhotoDidFailDeletingWithError:(NSString *) errorMessage;
- (void) revisitedGroupedPhotoDidFailMovingWithError:(NSString *) errorMessage;
- (void) revisitedGroupedPhotoChangeTitleTo:(NSString *) pageTitle;
@end

@interface RevisitedGroupedPhotoView : UIView <UITableViewDelegate, UITableViewDataSource, GroupedCellDelegate, FooterActionsDelegate, UITextFieldDelegate>

@property (nonatomic, weak) id<RevisitedGroupedPhotoDelegate> delegate;
@property (nonatomic, strong) NSMutableArray *files;
@property (nonatomic, strong) NSMutableArray *groups;
@property (nonatomic, strong) NSMutableDictionary *groupDict;
@property (nonatomic, strong) NSMutableArray *selectedFileList;

@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, strong) UITableView *fileTable;

@property (nonatomic, strong) ElasticSearchDao *readDao;
@property (nonatomic, strong) DeleteDao *deleteDao;
@property (nonatomic, strong) AlbumAddPhotosDao *albumAddPhotosDao;

@property (nonatomic, strong) FooterActionsMenuView *imgFooterActionMenu;
@property (nonatomic) BOOL isSelectible;

@property (nonatomic, strong) MBProgressHUD *progress;

@property (nonatomic, strong) MainSearchTextfield *searchField;

- (void) pullData;
- (void) setToSelectible;
- (void) setToUnselectible;
- (void) shouldContinueDelete;
- (void) destinationAlbumChosenWithUuid:(NSString *) chosenAlbumUuid;

@end
