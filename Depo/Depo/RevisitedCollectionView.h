//
//  RevisitedCollectionView.h
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
#import "CollCell.h"
#import "MBProgressHUD.h"
#import "DeleteDao.h"

@protocol RevisitedCollectionDelegate <NSObject>
- (void) revisitedCollectionDidSelectFile:(MetaFile *) fileSelected withList:(NSArray *) containingList;
- (void) revisitedCollectionDidFinishLoading;
- (void) revisitedCollectionDidFinishDeleting;
- (void) revisitedCollectionShouldConfirmForDeleting;
- (void) revisitedCollectionDidChangeToSelectState;
- (void) revisitedCollectionDidFailRetrievingList:(NSString *) errorMessage;
- (void) revisitedCollectionDidFailDeletingWithError:(NSString *) errorMessage;
- (void) revisitedCollectionChangeTitleTo:(NSString *) pageTitle;
@end

@interface RevisitedCollectionView : UIView <UITableViewDelegate, UITableViewDataSource, CollCellDelegate, FooterActionsDelegate>

@property (nonatomic, weak) id<RevisitedCollectionDelegate> delegate;
@property (nonatomic, strong) NSMutableArray *collections;
@property (nonatomic, strong) NSMutableArray *selectedFileList;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, strong) UITableView *collTable;

@property (nonatomic, strong) SearchByGroupDao *collDao;
@property (nonatomic, strong) DeleteDao *deleteDao;

@property (nonatomic, strong) FooterActionsMenuView *imgFooterActionMenu;
@property (nonatomic, strong) NSString *collDate;
@property (nonatomic) ImageGroupLevel level;
@property (nonatomic) BOOL isSelectible;

@property (nonatomic, strong) MBProgressHUD *progress;

- (void) pullData;
- (void) setToSelectible;
- (void) setToUnselectible;
- (void) shouldContinueDelete;

@end
