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
#import "GroupedView.h"
#import "DeleteDao.h"
#import "ShareLinkDao.h"
#import "AlbumAddPhotosDao.h"
#import "MainSearchTextfield.h"
#import "CustomConfirmView.h"
#import "NoItemView.h"
#import "RevisitedPhotoCollCell.h"
#import "RevisitedUploadingPhotoCollCell.h"
#import "CustomLabel.h"
#import "AutoSyncOffHeaderView.h"
#import "SyncManager.h"
#import "RevisitedRawPhotoCollCell.h"
#import "RawTypeFile.h"
#import "GroupPhotoSectionView.h"
#import "PhotosHeaderSyncView.h"
#import "SyncMaskView.h"
#import "FileDetailsDao.h"

@class RevisitedGroupedPhotoView;

@protocol RevisitedGroupedPhotoDelegate <NSObject>
- (void) revisitedGroupedPhotoDidSelectFile:(MetaFile *) fileSelected withList:(NSArray *) containingList withListOffset:(int)listOffset withPackageSize:(int)packageSize;
- (void) revisitedGroupedPhotoDidFinishLoading;
//- (void) revisitedGroupedPhotoDidFinishDeleting;
- (void) revisitedGroupedPhotoDidFinishDeletingOrMoving:(BOOL)deleteOperation;
- (void) revisitedGroupedPhotoDidFinishUpdate;
//- (void) revisitedGroupedPhotoDidFinishMoving;
- (void) revisitedGroupedPhotoShouldConfirmForDeleting;
- (void) revisitedGroupedPhotoDidChangeToSelectState;
- (void) revisitedGroupedPhotoShouldPrintWithFileList:(NSArray *) fileListToPrint;
- (void) revisitedGroupedPhotoDidFailRetrievingList:(NSString *) errorMessage;
- (void) revisitedGroupedPhotoDidFailDeletingWithError:(NSString *) errorMessage;
- (void) revisitedGroupedPhotoDidFailMovingWithError:(NSString *) errorMessage;
- (void) revisitedGroupedPhotoShowErrorMessage:(NSString *)errorMessage;
- (void) revisitedGroupedPhotoChangeTitleTo:(NSString *) pageTitle;
- (void) revisitedGroupedPhotoShowPhotoAlbums:(RevisitedGroupedPhotoView *)view;
- (void) revisitedGroupedPhoto:(RevisitedGroupedPhotoView *)view triggerShareForFiles:(NSArray *) uuidList;

- (void) revisitedGroupedPhoto:(RevisitedGroupedPhotoView *)view triggerShareForFiles:(NSArray *)fileList withUUID:(NSArray *) uuidList;

-(void)revisitedGroupedPhoto:(RevisitedGroupedPhotoView *)view downloadSelectedFiles:(NSArray *)selectedFiles;
- (BOOL) checkInternet;
- (void) triggerSyncSettings;

@optional
- (void) revisitedGroupedPhotoWantsToShowLoading;
- (void) revisitedGroupedPhotoWantsToHideLoading;
- (void) revisitedGroupedPhotoDidSelectAsset:(ALAsset *) assetSelected;

@end

@interface RevisitedGroupedPhotoView : UIView <FooterActionsDelegate, UITextFieldDelegate, CustomConfirmDelegate, UIScrollViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, RevisitedPhotoCollCellDelegate, RevisitedUploadingPhotoCollCellDelegate, AutoSyncOffHeaderDelegate, SyncManagerInfoDelegate, RawPhotoCollCellDelegate, GroupPhotoSectionViewDelegate, PhotosHeaderSyncViewDelegate, SyncMaskViewDelegate> {
}

@property (nonatomic, weak) id<RevisitedGroupedPhotoDelegate> delegate;
@property (nonatomic, strong) NSMutableArray *files;
@property (nonatomic, strong) NSArray *fileHashList;
@property (nonatomic, strong) NSMutableArray *selectedFileList;
@property (nonatomic, strong) NSMutableArray *selectedMetaFiles;
@property (nonatomic, strong) NSMutableArray *selectedAssets;
@property (nonatomic, strong) UIView *verticalIndicator;
@property (nonatomic, strong) CustomLabel *sectionIndicator;

@property (nonatomic, strong) UIRefreshControl *refreshControl;

@property (nonatomic, strong) ElasticSearchDao *readDao;
@property (nonatomic, strong) DeleteDao *deleteDao;
@property (nonatomic, strong) AlbumAddPhotosDao *albumAddPhotosDao;
@property (nonatomic, strong) FileDetailsDao *detailDao;
@property (nonatomic, strong) ElasticSearchDao *bulkReadDao;

@property (nonatomic, strong) FooterActionsMenuView *imgFooterActionMenu;
@property (nonatomic) BOOL isSelectible;

@property (nonatomic, strong) MBProgressHUD *progress;

@property (nonatomic, strong) MainSearchTextfield *searchField;
@property (nonatomic, strong) NoItemView *noItemView;

@property (nonatomic, strong) NSMutableArray *groups;
@property (nonatomic, strong) NSMutableArray *selectedSectionNames;
@property (nonatomic, strong) UICollectionView *collView;

@property (nonatomic, strong) AutoSyncOffHeaderView *syncInfoHeaderView;
@property (nonatomic, strong) SyncMaskView *lockMaskView;
@property (nonatomic, strong) NSMutableArray *uploadingUuids;

- (void) pullData;
- (void)reloadContent:(BOOL)forDelete;
- (void)reloadContent:(BOOL)forDelete forMetaFile:(MetaFile *)metaFile;
- (void) setToSelectible;
- (void) setToUnselectible;
- (void) setToUnselectiblePriorToRefresh;
- (void) shouldContinueDelete;
- (void) destinationAlbumChosenWithUuid:(NSString *) chosenAlbumUuid;
- (void) cancelRequests;
- (void) neutralizeSearchBar;
- (void) didReceiveMemoryWarning;
- (void) showSyncHeaderIfNeeded;

@end
