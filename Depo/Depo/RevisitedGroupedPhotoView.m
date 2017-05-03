//
//  RevisitedGroupedPhotoView.m
//  Depo
//
//  Created by Mahir Tarlan on 09/08/16.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import "RevisitedGroupedPhotoView.h"
#import "Util.h"
#import "AppDelegate.h"
#import "AppSession.h"
#import "GroupedPhotosCell.h"
#import "CacheUtil.h"
#import "BaseViewController.h"
#import "ReachabilityManager.h"
#import "Reachability.h"
#import "GroupPhotoSectionView.h"
#import "UploadQueue.h"
#import <CommonCrypto/CommonDigest.h>
#import "ALAssetRepresentation+MD5.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "SyncUtil.h"
#import "UIImageView+WebCache.h"
#import "SDWebImagePrefetcher.h"
#import "CustomAlertView.h"

#define GROUP_PACKAGE_SIZE (IS_IPAD ? 60 : IS_IPHONE_6P_OR_HIGHER ? 60 : 48)
#define GROUP_IMG_COUNT_PER_ROW (IS_IPAD ? 6 : IS_IPHONE_6P_OR_HIGHER ? 6 : 4)

#define GROUP_INPROGRESS_KEY @"in_progress"
#define IMAGE_SCROLL_THRESHOLD 2000

@interface RevisitedGroupedPhotoView() {
    int tableUpdateCounter;
    int listOffset;
    int packageSize;
    BOOL isLoading;
    BOOL endOfFiles;
    int photoCount;
    int groupSequence;
    NSDateFormatter *dateCompareFormat;
    BOOL anyOngoingPresent;
    BOOL initialLoadDone;
    
    BOOL cleanedFlag;
    float lastCheckYIndex;
    
    float yIndex;
    float imageWidth;
    
    NSArray *localAssets;
    NSDate *lastCheckedDate;
    
    PhotosHeaderSyncView *syncView;
    NextProcessType postUploadProcessType;
    
    float collViewOriginalHeight;
}
@end

@implementation RevisitedGroupedPhotoView

@synthesize delegate;
@synthesize files;
@synthesize selectedFileList;
@synthesize selectedMetaFiles;
@synthesize selectedAssets;
@synthesize refreshControl;
@synthesize readDao;
@synthesize bulkReadDao;
@synthesize deleteDao;
@synthesize albumAddPhotosDao;
@synthesize imgFooterActionMenu;
@synthesize isSelectible;
@synthesize progress;
@synthesize searchField;
@synthesize noItemView;
@synthesize verticalIndicator;
@synthesize sectionIndicator;
@synthesize selectedSectionNames;

@synthesize groups;
@synthesize collView;

@synthesize syncInfoHeaderView;
@synthesize lockMaskView;

@synthesize detailDao;
@synthesize uploadingUuids;

- (id) initWithFrame:(CGRect)frame {
    if(self = [super initWithFrame:frame]) {
        self.backgroundColor = [Util UIColorForHexColor:@"FFFFFF"];
        
        selectedSectionNames = [[NSMutableArray alloc] init];
        
        readDao = [[ElasticSearchDao alloc] init];
        readDao.delegate = self;
        readDao.successMethod = @selector(readSuccessCallback:);
        readDao.failMethod = @selector(readFailCallback:);
        
        deleteDao = [[DeleteDao alloc] init];
        deleteDao.delegate = self;
        deleteDao.successMethod = @selector(deleteSuccessCallback);
        deleteDao.failMethod = @selector(deleteFailCallback:);
        
        albumAddPhotosDao = [[AlbumAddPhotosDao alloc] init];
        albumAddPhotosDao.delegate = self;
        albumAddPhotosDao.successMethod = @selector(photosAddedSuccessCallback);
        albumAddPhotosDao.failMethod = @selector(photosAddedFailCallback:);
        
        detailDao = [[FileDetailsDao alloc] init];
        detailDao.delegate = self;
        detailDao.successMethod = @selector(detailSuccessCallback:);
        detailDao.failMethod = @selector(detailFailCallback:);
        
        bulkReadDao = [[ElasticSearchDao alloc] init];
        bulkReadDao.delegate = self;
        bulkReadDao.successMethod = @selector(bulkReadSuccessCallback:);
        bulkReadDao.failMethod = @selector(bulkReadFailCallback:);
        
        tableUpdateCounter = 0;
        listOffset = 0;
        photoCount = 0;
        groupSequence = 0;
        
        if(IS_IPAD) {
            imageWidth = (self.frame.size.width - 14)/6;
        } else {
            imageWidth = (self.frame.size.width - 10)/4;
        }
        
        dateCompareFormat = [[NSDateFormatter alloc] init];
        [dateCompareFormat setDateFormat:@"MMM yyyy"];
        
        groups = [[NSMutableArray alloc] init];
        files = [[NSMutableArray alloc] init];
        self.fileHashList = @[];
        for (NSString *hash in [SyncUtil readLocallySavedFiles]) {
            [self addObjectToFileHashList:hash];
        }
        selectedFileList = [[NSMutableArray alloc] init];
        selectedMetaFiles = [[NSMutableArray alloc] init];
        selectedAssets = [[NSMutableArray alloc] init];
        uploadingUuids = [[NSMutableArray alloc] init];
        
        [SyncManager sharedInstance].infoDelegate = self;

        BOOL isSyncHeaderVisible = NO;
        BOOL isSyncProgressVisible = NO;
        BOOL waitingForWifi = NO;
        if(!APPDELEGATE.session.photosSyncHeaderShownFlag) {
            EnableOption photoSyncFlag = (EnableOption)[CacheUtil readCachedSettingSyncPhotosVideos];
            if(photoSyncFlag == EnableOptionAuto || photoSyncFlag == EnableOptionOn) {
                ConnectionOption connectionOption = (ConnectionOption)[CacheUtil readCachedSettingSyncingConnectionType];
                if([ReachabilityManager isReachableViaWWAN]) {
                    if(connectionOption == ConnectionOptionWifi) {
                        isSyncHeaderVisible = YES;
                        waitingForWifi = YES;
                    }
                }
            } else {
                isSyncHeaderVisible = YES;
            }
        }
        
        yIndex = 0;
        
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        
        collView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, isSyncHeaderVisible || isSyncProgressVisible ? 50 : 0, self.frame.size.width, self.frame.size.height - (isSyncHeaderVisible || isSyncProgressVisible ? 50 : 0)) collectionViewLayout:layout];
        collView.dataSource = self;
        collView.delegate = self;
        collView.showsVerticalScrollIndicator = NO;
        collView.backgroundColor = [UIColor whiteColor];
        [collView registerClass:[RevisitedRawPhotoCollCell class] forCellWithReuseIdentifier:@"COLL_PHOTO_CELL"];
        [collView registerClass:[RevisitedRawPhotoCollCell class] forCellWithReuseIdentifier:@"COLL_PHOTO_CELL_DEPO"];
        [collView registerClass:[RevisitedRawPhotoCollCell class] forCellWithReuseIdentifier:@"COLL_PHOTO_CELL_CLIENT"];
        [collView registerClass:[RevisitedUploadingPhotoCollCell class] forCellWithReuseIdentifier:@"COLL_UPLOADING_PHOTO_CELL"];
        [collView registerClass:[GroupPhotoSectionView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"group_photo_header"];
        [collView setContentInset:UIEdgeInsetsMake(60, 0, 0, 0)];
        collView.alwaysBounceVertical = YES;
        collView.isAccessibilityElement = YES;
        collView.accessibilityIdentifier = @"collViewRevGroupedPhoto";
        collViewOriginalHeight = collView.frame.size.height;
        [self addSubview:collView];
        
        UIView *searchContainer = [[UIView alloc] initWithFrame:CGRectMake(0, -60, collView.frame.size.width, 60)];
        searchField = [[MainSearchTextfield alloc] initWithFrame:CGRectMake(20, 10, searchContainer.frame.size.width - 40, 40)];
        searchField.delegate = self;
        searchField.returnKeyType = UIReturnKeySearch;
        searchField.userInteractionEnabled = NO;
        searchField.isAccessibilityElement = YES;
        searchField.accessibilityIdentifier = @"searchFieldRevGroupedPhoto";
        [searchContainer addSubview:searchField];
        [collView addSubview:searchContainer];
        
        yIndex = 60;
        
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(searchTapped)];
        tapGestureRecognizer.numberOfTapsRequired = 1;
        tapGestureRecognizer.enabled = YES;
        [searchContainer addGestureRecognizer:tapGestureRecognizer];
        
        //        refreshControl = [[UIRefreshControl alloc] init];
        //        [refreshControl addTarget:self action:@selector(pullData) forControlEvents:UIControlEventValueChanged];
        //        [collView addSubview:refreshControl];
        [self createRefreshControl];
        
        progress = [[MBProgressHUD alloc] initWithFrame:self.frame];
        progress.opacity = 0.4f;
        [self addSubview:progress];
        
        verticalIndicator = [[UIView alloc] initWithFrame:CGRectMake(self.frame.size.width - 15, 10, 12, self.frame.size.height - 60)];
        UIImageView *verticalPole = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 12, verticalIndicator.frame.size.height)];
        verticalPole.image = [UIImage imageNamed:@"scroll_path.png"];
        [verticalIndicator addSubview:verticalPole];
        
        UIImageView *sectionIndicatorBg = [[UIImageView alloc] initWithFrame:CGRectMake(-90, 60, 100, 36)];
        sectionIndicatorBg.image = [UIImage imageNamed:@"bg_label.png"];
        [verticalIndicator addSubview:sectionIndicatorBg];
        
        sectionIndicator = [[CustomLabel alloc] initWithFrame:CGRectMake(-90, 68, 100, 20) withFont:[UIFont fontWithName:@"HelveticaNeue" size:12] withColor:[UIColor whiteColor] withText:@"" withAlignment:NSTextAlignmentCenter];
        [verticalIndicator addSubview:sectionIndicator];
        
        verticalIndicator.hidden = YES;
        verticalIndicator.alpha = 0.0f;
        [self addSubview:verticalIndicator];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(autoIterationFinished) name:AUTO_ITERATION_FINISHED_NOT_KEY object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(autoQueueFinished) name:AUTO_SYNC_QUEUE_FINISHED_NOTIFICATION object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(autoQueueChanged) name:AUTO_SYNC_QUEUE_CHANGED_NOTIFICATION object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkCollectionViewData) name:UIApplicationDidBecomeActiveNotification object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityDidChange) name:kReachabilityChangedNotification object:nil];
        
        
    }
    return self;
}

- (void) showSyncHeaderIfNeeded {
    BOOL isSyncHeaderVisible = NO;
    BOOL isSyncProgressVisible = NO;
    BOOL waitingForWifi = NO;
    if(!APPDELEGATE.session.photosSyncHeaderShownFlag) {
        EnableOption photoSyncFlag = (EnableOption)[CacheUtil readCachedSettingSyncPhotosVideos];
        if(photoSyncFlag == EnableOptionAuto || photoSyncFlag == EnableOptionOn) {
            ConnectionOption connectionOption = (ConnectionOption)[CacheUtil readCachedSettingSyncingConnectionType];
            if([ReachabilityManager isReachableViaWWAN]) {
                if(connectionOption == ConnectionOptionWifi) {
                    isSyncHeaderVisible = YES;
                    waitingForWifi = YES;
                }
            }
        } else {
            isSyncHeaderVisible = YES;
        }
    }
    
    if(isSyncHeaderVisible) {
        if (syncInfoHeaderView) {
            [syncInfoHeaderView removeFromSuperview];
        }
        syncInfoHeaderView = [[AutoSyncOffHeaderView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 50) withWifiFlag:waitingForWifi];
        syncInfoHeaderView.delegate = self;
        [self addSubview:syncInfoHeaderView];
        
        // collection view'i asagi kaydir
        self.collView.frame = CGRectMake(0, isSyncHeaderVisible || isSyncProgressVisible ? 50 : 0, self.frame.size.width, self.frame.size.height - (isSyncHeaderVisible || isSyncProgressVisible ? 50 : 0));
    } else {
        // info headeri sakla, collection view'i yukari kaydir, ama bayragi no'ya cek. cunku bu kullanici kapama butonuna basmadi
        [self autoSyncOffHeaderViewCloseClicked];
        APPDELEGATE.session.photosSyncHeaderShownFlag = NO;
        
        UploadManager *activeManRef = [[UploadQueue sharedInstance] activeManager];
        if(activeManRef != nil) {
            if (syncView) {
                [syncView removeFromSuperview];
                syncView = nil;
            }
            syncView = [[PhotosHeaderSyncView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 50)];
            activeManRef.headerDelegate = syncView;
            syncView.delegate = self;
            if(activeManRef.uploadRef.taskType == UploadTaskTypeAsset) {
                [syncView loadAsset:activeManRef.uploadRef.assetUrl];
            } else if(activeManRef.uploadRef.taskType == UploadTaskTypeFile) {
                [syncView loadLocalFileForCamUpload:activeManRef.uploadRef.tempUrl];
            }
            [self addSubview:syncView];
            
            isSyncProgressVisible = YES;
        }
    }
}

- (void)reachabilityDidChange {
    [self showSyncHeaderIfNeeded];
}

- (void) checkCollectionViewData {
    if ([self.groups count] < 1 || [self.files count] < 1) {
        [self pullData];
    }
}

-(void)createRefreshControl {
    if (!refreshControl) {
        refreshControl = [[UIRefreshControl alloc] init];
        [refreshControl addTarget:self action:@selector(pullData) forControlEvents:UIControlEventValueChanged];
        [collView addSubview:refreshControl];
    }
}

-(void)removeRefreshControl {
    [refreshControl removeFromSuperview];
    refreshControl = nil;
}

- (void)reloadContent:(BOOL)forDelete {
    [self reloadContent:forDelete forMetaFile:nil];
}

- (void)reloadContent:(BOOL)forDelete forMetaFile:(MetaFile *)metaFile {
    if (metaFile != nil) {
        for (FileInfoGroup *fileInfoGroup in self.groups) {
            NSMutableArray *discardedItems = [@[] mutableCopy];
            for (RawTypeFile *object in fileInfoGroup.fileInfo) {
                if ([metaFile isEqual:object.fileRef]) {
                    [discardedItems addObject:object];
                    [SyncUtil removeLocalHash:object.fileRef.metaHash];
                }
            }
            [fileInfoGroup.fileInfo removeObjectsInArray:discardedItems];
        }
    } else {
        if (forDelete) {
            for (MetaFile *selectedFile in selectedMetaFiles) {
                for (FileInfoGroup *fileInfoGroup in self.groups) {
                    NSMutableArray *discardedItems = [@[] mutableCopy];
                    for (RawTypeFile *object in fileInfoGroup.fileInfo) {
                        if ([selectedFile isEqual:object.fileRef]) {
                            [discardedItems addObject:object];
                            [SyncUtil removeLocalHash:object.fileRef.metaHash];
                        }
                    }
                    [fileInfoGroup.fileInfo removeObjectsInArray:discardedItems];
                }
            }
        }
    }
    [self setToUnselectiblePriorToRefresh];
    [self.collView performBatchUpdates:^{
        [self.collView reloadSections:
         [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, self.collView.numberOfSections)]];
    } completion:nil];
}

- (void) pullData {
    
    if([delegate checkInternet]) {
        listOffset = 0;
        groupSequence = 0;
        lastCheckedDate = nil;

        [self.groups removeAllObjects];
        [self.files removeAllObjects];
        self.fileHashList = @[];
        for (NSString *hash in [SyncUtil readLocallySavedFiles]) {
            [self addObjectToFileHashList:hash];
        }
        [[SDWebImagePrefetcher sharedImagePrefetcher] cancelPrefetching];
        [[SDWebImageManager sharedManager].imageCache clearMemory];
        localAssets = nil;
        
        [self.collView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
        
        yIndex = 60;
        
        //        [self addOngoingGroup];
        
        packageSize = GROUP_PACKAGE_SIZE;
        if([[Util deviceType] isEqualToString:@"iPhone 6 Plus"] || [[Util deviceType] isEqualToString:@"iPhone 6S Plus"]) {
            packageSize = 100;
        }
        [readDao requestPhotosAndVideosForPage:listOffset andSize:packageSize andSortType:SortTypeDateDesc];
        isLoading = YES;
        
        [self bringSubviewToFront:progress];
        [progress show:YES];
    } else {
        [refreshControl endRefreshing];
    }
    IGLog(@"At end of RevisitedGroupedPhotoView pullData");
}

- (void) addOngoingGroup {
    NSArray *uploadingImageRefArray = [[UploadQueue sharedInstance] uploadImageRefs];
    if([uploadingImageRefArray count] > 0) {
        FileInfoGroup *inProgressGroup = [[FileInfoGroup alloc] init];
        inProgressGroup.refDate = [NSDate date];
        inProgressGroup.customTitle = NSLocalizedString(@"ImageGroupTypeInProgress", @"");
        inProgressGroup.fileInfo = uploadingImageRefArray;
        inProgressGroup.groupType = ImageGroupTypeInProgress;
        inProgressGroup.sequence = groupSequence;
        inProgressGroup.groupKey = GROUP_INPROGRESS_KEY;
        
        [self addOrUpdateGroup:inProgressGroup];
        anyOngoingPresent = YES;
    } else {
        anyOngoingPresent = NO;
    }
}

- (FileInfoGroup *) groupByKey:(NSString *) groupKey {
    FileInfoGroup *initialRow = nil;
    for(FileInfoGroup *row in self.groups) {
        if([row.groupKey isEqualToString:groupKey]) {
            initialRow = row;
            break;
        }
    }
    return initialRow;
}

- (void) addOrUpdateGroup:(FileInfoGroup *) group {
    if (noItemView != nil)
        [noItemView removeFromSuperview];
    
    FileInfoGroup *initialRow = nil;
    int counter = 0;
    for(FileInfoGroup *row in self.groups) {
        if([row.groupKey isEqualToString:group.groupKey]) {
            initialRow = row;
            break;
        }
        counter ++;
    }
    if(initialRow != nil) {
        [initialRow.fileInfo addObjectsFromArray:group.fileInfo];
        initialRow.fileInfo = [self sortRawArrayByDateDesc:initialRow.fileInfo];
        [self.groups replaceObjectAtIndex:counter withObject:initialRow];
    } else {
        group.fileInfo = [self sortRawArrayByDateDesc:group.fileInfo];
        [self.groups addObject:group];
    }
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"refDate" ascending:NO];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    self.groups = [[self.groups sortedArrayUsingDescriptors:sortDescriptors] mutableCopy];
    dispatch_async(dispatch_get_main_queue(), ^{
       [self neutralizeSearchBar]; 
    });
}

- (void) deleteSuccessCallback {
    IGLog(@"RevisitedGroupedPhotoView deleteSuccessCallback");
    [progress hide:YES];
    [delegate revisitedGroupedPhotoDidFinishDeletingOrMoving:YES];
    //    [self proceedSuccessForProgressViewWithAddButtonKey:@"PhotoTab"];
}

- (void) deleteFailCallback:(NSString *) errorMessage {
    NSString *logMessage = [NSString stringWithFormat:@"RevisitedGroupedPhotoView deleteFailCallback with error: %@", errorMessage];
    IGLog(logMessage);
    [progress hide:YES];
    //    [self proceedFailureForProgressViewWithAddButtonKey:@"PhotoTab"];
    [delegate revisitedGroupedPhotoDidFailDeletingWithError:errorMessage];
}

- (void) setToSelectible {
    if(!isSelectible) {
        isSelectible = YES;
        [self removeRefreshControl];
        [selectedFileList removeAllObjects];
        [selectedMetaFiles removeAllObjects];
        [selectedAssets removeAllObjects];
        [selectedSectionNames removeAllObjects];
        
        [collView reloadData];
    }
}

- (void) setToUnselectiblePriorToRefresh {
    isSelectible = NO;
    [self createRefreshControl];
    //    [selectedFileList removeAllObjects];
    //    [selectedSectionNames removeAllObjects];
    //    [selectedMetaFiles removeAllObjects];
    //    [selectedAssets removeAllObjects];
    
    if(imgFooterActionMenu) {
        [imgFooterActionMenu removeFromSuperview];
        imgFooterActionMenu = nil;
        [self resizeCollViewHeightForFooterMenu];
    }
}

- (void) setToUnselectible {
    [self setToUnselectiblePriorToRefresh];
    [collView reloadData];
}

- (void) readSuccessCallback:(NSArray *) fileList {
    [progress hide:YES];
    IGLog(@"RevisitedGroupedPhotoView readSuccessCallback called");
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        if([fileList count] > 0) {
            if([fileList count] < packageSize) {
                endOfFiles = YES;
            } else {
                endOfFiles = NO;
            }
            [files addObjectsFromArray:fileList];
            
            NSMutableDictionary *tempDict = [[NSMutableDictionary alloc] init];
            for(MetaFile *row in fileList) {
                if(row.detail.fileDate) {
                    NSString *dateStr = [dateCompareFormat stringFromDate:row.detail.fileDate];
                    if([[tempDict allKeys] count] == 0) {
                        FileInfoGroup *newGroup = [[FileInfoGroup alloc] init];
                        newGroup.customTitle = dateStr;
                        newGroup.locationInfo = @"";
                        newGroup.refDate = row.detail.fileDate;
                        newGroup.fileInfo = [[NSMutableArray alloc] init];
                        RawTypeFile *rawFile = [self rawFileForFile:row];
                        [newGroup.fileInfo addObject:rawFile];
                        if(rawFile.hashRef) {
                            [self addObjectToFileHashList:rawFile.hashRef];
                        }
                        newGroup.sequence = groupSequence;
                        newGroup.groupKey = dateStr;
                        [tempDict setObject:newGroup forKey:dateStr];
                        
                        groupSequence ++;
                    } else {
                        FileInfoGroup *currentGroup = [tempDict objectForKey:dateStr];
                        if(currentGroup != nil) {
                            RawTypeFile *rawFile = [self rawFileForFile:row];
                            [currentGroup.fileInfo addObject:rawFile];
                            if(rawFile.hashRef) {
                                [self addObjectToFileHashList:rawFile.hashRef];
                            }
                        } else {
                            FileInfoGroup *newGroup = [[FileInfoGroup alloc] init];
                            newGroup.customTitle = dateStr;
                            newGroup.locationInfo = @"";
                            newGroup.refDate = row.detail.fileDate;
                            newGroup.fileInfo = [[NSMutableArray alloc] init];
                            RawTypeFile *rawFile = [self rawFileForFile:row];
                            [newGroup.fileInfo addObject:rawFile];
                            if(rawFile.hashRef) {
                                [self addObjectToFileHashList:rawFile.hashRef];
                            }
                            newGroup.sequence = groupSequence;
                            newGroup.groupKey = dateStr;
                            [tempDict setObject:newGroup forKey:dateStr];
                            groupSequence ++;
                        }
                    }
                    if(isSelectible && [selectedSectionNames containsObject:dateStr]) {
                        if(![selectedFileList containsObject:row.uuid]) {
                            [selectedFileList addObject:row.uuid];
                            [selectedMetaFiles addObject:row];
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [delegate revisitedGroupedPhotoChangeTitleTo:[NSString stringWithFormat:NSLocalizedString(@"FilesSelectedTitle", @""), [selectedFileList count]]];
                            });
                            
                        }
                    }
                }
            }
            
            NSArray *tempGroups = [tempDict allValues];
            NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"refDate" ascending:NO];
            NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
            tempGroups = [tempGroups sortedArrayUsingDescriptors:sortDescriptors];
            
            for(FileInfoGroup *row in tempGroups) {
                [self addOrUpdateGroup:row];
            }
        } else {
            endOfFiles = YES;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
           [refreshControl endRefreshing];
        });
        NSMutableArray *urlsToPrefetch = [@[] mutableCopy];
        for (FileInfoGroup *fileInfoGroup in self.groups) {
            for (RawTypeFile *fileType in fileInfoGroup.fileInfo) {
                if ([fileType isKindOfClass:[RawTypeFile class]]) {
                    NSURL *thumbnailURL = [NSURL URLWithString:fileType.fileRef.detail.thumbMediumUrl];
                    if (thumbnailURL != nil) {
                        [urlsToPrefetch addObject:thumbnailURL];
                    }
                }
            }
        }
        [[SDWebImagePrefetcher sharedImagePrefetcher] setMaxConcurrentDownloads:10];
        [[SDWebImagePrefetcher sharedImagePrefetcher].manager.imageCache.config setShouldDecompressImages:NO];
        [[SDWebImagePrefetcher sharedImagePrefetcher] prefetchURLs:urlsToPrefetch];
        /*
         if ([files count] == 0 && !anyOngoingPresent) {
         if (noItemView == nil) {
         noItemView = [[NoItemView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, collView.frame.size.height) imageName:@"no_photo_icon" titleText:NSLocalizedString(@"EmptyPhotosVideosTitle", @"") descriptionText:NSLocalizedString(@"EmptyPhotosVideosDescription", @"")];
         [self addSubview:noItemView];
         }
         } else if (noItemView != nil) {
         [noItemView removeFromSuperview];
         }
         */
        dispatch_async(dispatch_get_main_queue(), ^{
            //TODO yukaridaki comment'li logic'i oturttuktan sonra bu if'i silebilirsin
            if (noItemView != nil) {
                [noItemView removeFromSuperview];
            }
        });
        if(!initialLoadDone) {
            initialLoadDone = YES;
        }
        IGLog(@"RevisitedGroupedPhotoView readSuccessCallback calling SyncManager listOfUnsyncedImages");
        if(localAssets == nil || [localAssets count] == 0) {
            [[SyncManager sharedInstance] listOfUnsyncedImages];
        } else {
            [self addUnsyncedFiles];
        }
    });
}

- (void) readFailCallback:(NSString *) errorMessage {
    [progress hide:YES];
    isLoading = NO;
    [refreshControl endRefreshing];
    [delegate revisitedGroupedPhotoShowErrorMessage:errorMessage];
}

- (void)addObjectToFileHashList:(NSString *)hash {
    NSMutableArray *mutableHashList = [self.fileHashList mutableCopy];
    [mutableHashList addObject:hash];
    
    self.fileHashList = [mutableHashList copy];
}

- (void)removeObjectFromHashList:(NSString *)hash {
    NSMutableArray *mutableHashList = [self.fileHashList mutableCopy];
    [mutableHashList removeObject:hash];
    
    self.fileHashList = [mutableHashList copy];
}

#pragma mark - UIScrollViewDelegate Methods

- (void) scrollViewDidScroll:(UIScrollView *)scrollView {
    if([ReachabilityManager isReachable]) {
        if(!isLoading && !endOfFiles) {
            CGFloat currentOffset = collView.contentOffset.y;
            CGFloat maximumOffset = collView.contentSize.height - collView.frame.size.height;
            
            if (maximumOffset > 0.0f && currentOffset - maximumOffset >= 0.0f) {
                IGLog(@"RevisitedGroupedPhotoView scrollViewDidScroll triggering dynamicallyLoadNextPage");
                isLoading = YES;
                [self dynamicallyLoadNextPage];
            }
            if(cleanedFlag) {
                IGLog(@"RevisitedGroupedPhotoView scrollViewDidScroll cleanedFlag is true");
                if(fabs(currentOffset - lastCheckYIndex) <= IMAGE_SCROLL_THRESHOLD/2) {
                    NSNumber *startOffset = [NSNumber numberWithFloat:self.collView.contentOffset.y];
                    NSDictionary* userInfo = @{@"startOffset": startOffset};
                    IGLog(@"RevisitedGroupedPhotoView scrollViewDidScroll posting notification IMAGE_SCROLL_RELOAD_DATA_AFTER_WARNING");
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"IMAGE_SCROLL_RELOAD_DATA_AFTER_WARNING" object:self userInfo:userInfo];
                }
            }
            // Bu bölümde 'indexPathForItemAtPoint' fonksiyonu zaman zaman 'index out of bound' hatası verebiliyor. Bu hata iOS 8 cihazlarda olmaktadır.
            @try {
                NSIndexPath *visibleIndexPath = [collView indexPathForItemAtPoint:CGPointMake(30, currentOffset)];
                if(visibleIndexPath && (self.groups.count > visibleIndexPath.section)) {
                    FileInfoGroup *visibleGroup = [self.groups objectAtIndex:visibleIndexPath.section];
                    if([visibleGroup.customTitle isEqualToString:NSLocalizedString(@"ImageGroupTypeInProgress", @"")]) {
                        sectionIndicator.text = @"";
                        [self hideVerticalIndicator];
                    } else {
                        [self showVerticalIndicator];
                        sectionIndicator.text = visibleGroup.customTitle;
                    }
                }
            } @catch (NSException *exception) {
                NSString *log = [NSString stringWithFormat:@"Error when generating section indicator: Info: Groups count=%lu, exception=%@", (unsigned long)self.groups.count, exception];
                IGLog(log);
            }
        }
        
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    NSIndexPath *visibleIndexPath = [collView indexPathForItemAtPoint:CGPointMake(30, collView.contentOffset.y)];
    if(visibleIndexPath) {
        FileInfoGroup *visibleGroup = [self.groups objectAtIndex:visibleIndexPath.section];
        if(![visibleGroup.customTitle isEqualToString:NSLocalizedString(@"ImageGroupTypeInProgress", @"")]) {
            [self showVerticalIndicator];
        }
    }
}

- (void) scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if(!decelerate) {
        [self performSelector:@selector(hideVerticalIndicator) withObject:nil afterDelay:1.8f];
    }
}

- (void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self performSelector:@selector(hideVerticalIndicator) withObject:nil afterDelay:1.8f];
}

#pragma mark -

- (void) dynamicallyLoadNextPage {
    listOffset ++;
    [readDao requestPhotosAndVideosForPage:listOffset andSize:packageSize andSortType:SortTypeDateDesc];
}

- (void) revisitedPhotoCollCellImageWasSelectedForFile:(MetaFile *) fileSelected forGroupWithKey:(NSString *) groupKey {
    NSArray *listToPass = @[fileSelected];
    
    for(FileInfoGroup *row in self.groups) {
        if([row.groupKey isEqualToString:groupKey]) {
            listToPass = row.fileInfo;
        }
    }
    [delegate revisitedGroupedPhotoDidSelectFile:fileSelected withList:listToPass withListOffset:listOffset withPackageSize:packageSize];
}

- (void) revisitedUploadingPhotoCollCellImageWasSelectedForFile:(MetaFile *) fileSelected forGroupWithKey:(NSString *) groupKey {
}

- (void) revisitedPhotoCollCellImageWasMarkedForFile:(MetaFile *) fileSelected {
    if(fileSelected.uuid) {
        if(![selectedFileList containsObject:fileSelected.uuid]) {
            [selectedFileList addObject:fileSelected.uuid];
            [selectedMetaFiles addObject:fileSelected];
        }
    }
    if([selectedFileList count] > 0) {
        [self showImgFooterMenu];
        [delegate revisitedGroupedPhotoChangeTitleTo:[NSString stringWithFormat:NSLocalizedString(@"FilesSelectedTitle", @""), [selectedFileList count]]];
    } else {
        [self hideImgFooterMenu];
        [delegate revisitedGroupedPhotoChangeTitleTo:NSLocalizedString(@"SelectFilesTitle", @"")];
    }
    
    if (fileSelected.contentType == ContentTypeVideo) {
        if (photoCount == 0) {
            [imgFooterActionMenu hidePrintIcon];
        } else{
            [imgFooterActionMenu showPrintIcon];
        }
    } else {
        photoCount++;
        [imgFooterActionMenu showPrintIcon];
    }
}

- (void) revisitedUploadingPhotoCollCellImageWasMarkedForFile:(MetaFile *) fileSelected {
}

- (void) revisitedPhotoCollCellImageWasUnmarkedForFile:(MetaFile *) fileSelected {
    if([selectedFileList containsObject:fileSelected.uuid]) {
        [selectedFileList removeObject:fileSelected.uuid];
        [selectedMetaFiles removeObject:fileSelected];
    }
    if([selectedFileList count] > 0) {
        [self showImgFooterMenu];
        [delegate revisitedGroupedPhotoChangeTitleTo:[NSString stringWithFormat:NSLocalizedString(@"FilesSelectedTitle", @""), [selectedFileList count]]];
    } else {
        [self hideImgFooterMenu];
        [delegate revisitedGroupedPhotoChangeTitleTo:NSLocalizedString(@"SelectFilesTitle", @"")];
    }
    if (fileSelected.contentType == ContentTypePhoto) {
        photoCount--;
    }
    if (photoCount == 0) {
        [imgFooterActionMenu hidePrintIcon];
    }
}

- (void) revisitedUploadingPhotoCollCellImageWasUnmarkedForFile:(MetaFile *) fileSelected {
}

- (void) showImgFooterMenu {
    if(imgFooterActionMenu) {
        imgFooterActionMenu.hidden = NO;
    } else {
        imgFooterActionMenu = [[FooterActionsMenuView alloc] initForPhotosTabWithFrame:CGRectMake(0, self.frame.size.height - 70, self.frame.size.width, 60) shouldShowShare:YES shouldShowMove:YES shouldShowDownload:YES shouldShowDelete:YES shouldShowPrint:YES shouldShowSync:YES isMoveAlbum:YES];
        /* imgFooterActionMenu = [[FooterActionsMenuView alloc] initForPhotosTabWithFrame:frame
         shouldShowShare:YES
         shouldShowMove:YES
         shouldShowDownload:YES
         shouldShowDelete:YES
         shouldShowPrint:YES];
         imgFooterActionMenu = [[FooterActionsMenuView alloc] initForPhotosTabWithFrame:frame
         shouldShowShare:YES
         shouldShowMove:YES
         shouldShowDownload:YES
         shouldShowDelete:YES
         shouldShowPrint:YES
         isMoveAlbum:NO];*/
        imgFooterActionMenu.delegate = self;
        [self addSubview:imgFooterActionMenu];
    }
    
    [self resizeCollViewHeightForFooterMenu];
}

- (void) hideImgFooterMenu {
    imgFooterActionMenu.hidden = YES;
    [self resizeCollViewHeightForFooterMenu];
}

- (void) revisitedPhotoCollCellImageUploadFinishedForFile:(NSString *) fileSelectedUuid {
}

- (void) revisitedPhotoCollCellImageWasLongPressedForFile:(MetaFile *) fileSelected {
    [self setToSelectible];
    [delegate revisitedGroupedPhotoDidChangeToSelectState];
}

- (void) revisitedPhotoCollCellImageUploadQuotaError:(MetaFile *) fileSelected {
}

- (void) revisitedPhotoCollCellImageUploadLoginError:(MetaFile *) fileSelected {
}

- (void) revisitedPhotoCollCellImageWasSelectedForView:(SquareImageView *) ref {
}

- (void) revisitedUploadingPhotoCollCellImageUploadFinishedForFile:(NSString *) fileSelectedUuid {
}

- (void) revisitedUploadingPhotoCollCellImageWasLongPressedForFile:(MetaFile *) fileSelected {
    [self setToSelectible];
    [delegate revisitedGroupedPhotoDidChangeToSelectState];
}

- (void) revisitedUploadingPhotoCollCellImageUploadQuotaError:(MetaFile *) fileSelected {
}

- (void) revisitedUploadingPhotoCollCellImageUploadLoginError:(MetaFile *) fileSelected {
}

- (void) revisitedUploadingPhotoCollCellImageWasSelectedForView:(SquareImageView *) ref {
}

- (void) shouldContinueDelete {
    IGLog(@"RevisitedGroupedPhotoView shouldContinueDelete called");
    BOOL anyInAlbum = NO;
    for(id row in self.files) {
        if([row isKindOfClass:[MetaFile class]]) {
            MetaFile *castedRow = (MetaFile *) row;
            if([selectedFileList containsObject:castedRow.uuid]) {
                if(castedRow.addedAlbumUuids != nil && [castedRow.addedAlbumUuids count] > 0) {
                    anyInAlbum = YES;
                }
            }
        }
    }
    
    if(anyInAlbum) {
        CustomConfirmView *confirm = [[CustomConfirmView alloc] initWithFrame:CGRectMake(0, 0, APPDELEGATE.window.frame.size.width, APPDELEGATE.window.frame.size.height) withTitle:NSLocalizedString(@"Info", @"") withCancelTitle:NSLocalizedString(@"ButtonCancel", @"") withApproveTitle:NSLocalizedString(@"OK", @"") withMessage:NSLocalizedString(@"DeleteFileInAlbumAlert", @"") withModalType:ModalTypeApprove];
        confirm.delegate = self;
        [APPDELEGATE showCustomConfirm:confirm];
    } else {
        IGLog(@"RevisitedGroupedPhotoView shouldContinueDelete deleteDao requestDeleteFiles called");
        [deleteDao requestDeleteFiles:[self uuidsOfOnlyDepoFiles]];
        [self bringSubviewToFront:progress];
        [progress show:YES];
    }
}

- (void) footerActionMenuDidSelectMore:(FooterActionsMenuView *)menu {
    [self resizeCollViewHeightForFooterMenu];
}

- (void) footerActionMenuDidSelectDownload:(FooterActionsMenuView *) menu {
    if([selectedMetaFiles count] == 0)
        return;
    
    [delegate revisitedGroupedPhoto:self downloadSelectedFiles:selectedMetaFiles];
}

- (void) footerActionMenuDidSelectDelete:(FooterActionsMenuView *) menu {
    if([selectedMetaFiles count] == 0)
        return;
    
    IGLog(@"RevisitedGroupedPhotoView footerActionMenuDidSelectDelete called");
    if([CacheUtil showConfirmDeletePageFlag]) {
        IGLog(@"RevisitedGroupedPhotoView footerActionMenuDidSelectDelete CacheUtil showConfirmDeletePageFlag returns YES");
        BOOL anyInAlbum = NO;
        for(id row in self.files) {
            if([row isKindOfClass:[MetaFile class]]) {
                MetaFile *castedRow = (MetaFile *) row;
                if([selectedFileList containsObject:castedRow.uuid]) {
                    if(castedRow.addedAlbumUuids != nil && [castedRow.addedAlbumUuids count] > 0) {
                        anyInAlbum = YES;
                    }
                }
            }
        }
        
        if(anyInAlbum) {
            CustomConfirmView *confirm = [[CustomConfirmView alloc] initWithFrame:CGRectMake(0, 0, APPDELEGATE.window.frame.size.width, APPDELEGATE.window.frame.size.height) withTitle:NSLocalizedString(@"Info", @"") withCancelTitle:NSLocalizedString(@"ButtonCancel", @"") withApproveTitle:NSLocalizedString(@"OK", @"") withMessage:NSLocalizedString(@"DeleteFileInAlbumAlert", @"") withModalType:ModalTypeApprove];
            confirm.delegate = self;
            [APPDELEGATE showCustomConfirm:confirm];
        } else {
            IGLog(@"RevisitedGroupedPhotoView footerActionMenuDidSelectDelete deleteDao requestDeleteFiles called");
            [deleteDao requestDeleteFiles:[self uuidsOfOnlyDepoFiles]];
            [self bringSubviewToFront:progress];
            [progress show:YES];
        }
        
        //        [self pushProgressViewWithProcessMessage:NSLocalizedString(@"DeleteProgressMessage", @"") andSuccessMessage:NSLocalizedString(@"DeleteSuccessMessage", @"") andFailMessage:NSLocalizedString(@"DeleteFailMessage", @"")];
    } else {
        [delegate revisitedGroupedPhotoShouldConfirmForDeleting];
    }
}

- (void) startUploadForSelectedAssets {
    for(ALAsset *row in selectedAssets) {
        NSString *mimeType = (__bridge_transfer NSString*)UTTypeCopyPreferredTagWithClass
        ((__bridge CFStringRef)[row.defaultRepresentation UTI], kUTTagClassMIMEType);
        
        MetaFileSummary *summary = [[MetaFileSummary alloc] init];
        summary.fileName = [row.defaultRepresentation filename];
        summary.bytes = [row.defaultRepresentation size];
        
        UploadRef *ref = [[UploadRef alloc] init];
        ref.fileName = row.defaultRepresentation.filename;
        ref.filePath = [row.defaultRepresentation.url absoluteString];
        ref.localHash = [SyncUtil md5StringOfString:[row.defaultRepresentation.url absoluteString]];
        ref.mimeType = mimeType;
        ref.summary = summary;
        if ([[row valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypeVideo]) {
            ref.contentType = ContentTypeVideo;
        } else {
            ref.contentType = ContentTypePhoto;
        }
        NSDictionary *metadataDict = [row.defaultRepresentation metadata];
        if(metadataDict) {
            NSDictionary *tiffDict = [metadataDict objectForKey:@"{TIFF}"];
            if(tiffDict) {
                NSString *softwareVal = [tiffDict objectForKey:@"Software"];
                if(softwareVal) {
                    if([SPECIAL_LOCAL_ALBUM_NAMES containsObject:softwareVal]) {
                        ref.referenceFolderName = softwareVal;
                    }
                }
            }
        }
        ref.ownerPage = UploadStarterPagePhotos;
        ref.folderUuid = APPDELEGATE.session.user.mobileUploadFolderUuid;
        ref.autoSyncFlag = YES; //TODO
        
        UploadManager *manager = [[UploadManager alloc] initWithUploadInfo:ref];
        [manager configureUploadAsset:ref.filePath atFolder:nil];
        [uploadingUuids addObject:manager.uploadRef.fileUuid];
        [[UploadQueue sharedInstance] addNewUploadTask:manager];
    }
}

- (void) footerActionMenuDidSelectSync:(FooterActionsMenuView *) menu {
    if([selectedAssets count] > 0) {
        [self startUploadForSelectedAssets];
        postUploadProcessType = NextProcessTypeRefresh;
        
        [imgFooterActionMenu disableSyncButton];

        if(syncView == nil) {
            UploadManager *activeManRef = [[UploadQueue sharedInstance] activeManager];
            if(activeManRef != nil) {
                syncView = [[PhotosHeaderSyncView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 50)];
                activeManRef.headerDelegate = syncView;
                syncView.delegate = self;
                [syncView loadAsset:activeManRef.uploadRef.assetUrl];
                [self addSubview:syncView];
                
                if(collView.frame.origin.y == 0) {
                    [UIView animateWithDuration:0.4 animations:^{
                        collView.frame = CGRectMake(collView.frame.origin.x, collView.frame.origin.y + 50, collView.frame.size.width, collView.frame.size.height - 50);
                    }];
                }
            }
        }
        //TODO check
        [collView reloadData];
//        [delegate revisitedGroupedPhotoDidFinishUpdate];
    }
}

- (void) addLockMask {
    if(!lockMaskView) {
        lockMaskView = [[SyncMaskView alloc] initWithFrame:CGRectMake(0, 0, APPDELEGATE.window.frame.size.width, APPDELEGATE.window.frame.size.height)];
        lockMaskView.delegate = self;
        [APPDELEGATE.window addSubview:lockMaskView];
    }
}

- (void) removeLockMask {
    if(lockMaskView) {
        [lockMaskView removeFromSuperview];
        lockMaskView = nil;
    }
}

- (void) syncMaskViewShouldClose {
    [self removeLockMask];
    [[UploadQueue sharedInstance] cancelAllUploads];
    //TODO check if pullData needed...
}

- (void) footerActionMenuDidSelectMove:(FooterActionsMenuView *) menu {
    if([selectedAssets count] > 0) {
        [self addLockMask];
        postUploadProcessType = NextProcessTypeMove;
        [self startUploadForSelectedAssets];
    } else {
        [delegate revisitedGroupedPhotoShowPhotoAlbums:self];
        //[APPDELEGATE.base showPhotoAlbums];
    }
}

- (void) footerActionMenuDidSelectShare:(FooterActionsMenuView *) menu {
    if([selectedAssets count] > 0) {
        [self addLockMask];
        postUploadProcessType = NextProcessTypeShare;
        [self startUploadForSelectedAssets];
    } else {
        if ([delegate respondsToSelector:@selector(revisitedGroupedPhoto:triggerShareForFiles:withUUID:)]) {
            [delegate revisitedGroupedPhoto:self triggerShareForFiles:selectedMetaFiles withUUID:selectedFileList];
            return;
        }
        [delegate revisitedGroupedPhoto:self triggerShareForFiles:selectedMetaFiles];
        // [APPDELEGATE.base triggerShareForFiles:selectedFileList];
    }
}

- (void) footerActionMenuDidSelectPrint:(FooterActionsMenuView *)menu {
    if([selectedAssets count] > 0) {
        CustomAlertView *alert = [[CustomAlertView alloc] initWithFrame:CGRectMake(0, 0, APPDELEGATE.window.frame.size.width, APPDELEGATE.window.frame.size.height) withTitle:NSLocalizedString(@"Error", @"") withMessage:NSLocalizedString(@"UnsyncPrintError", @"") withModalType:ModalTypeError];
        [APPDELEGATE showCustomAlert:alert];
        [self setToUnselectiblePriorToRefresh];
        [delegate revisitedGroupedPhotoShouldPrintWithFileList:nil];
    } else {
        [delegate revisitedGroupedPhotoShouldPrintWithFileList:selectedMetaFiles];
    }
}

- (void) destinationAlbumChosenWithUuid:(NSString *) chosenAlbumUuid {
    [albumAddPhotosDao requestAddPhotos:selectedFileList toAlbum:chosenAlbumUuid];
    [self bringSubviewToFront:progress];
    [progress show:YES];
    //TODO    [self pushProgressViewWithProcessMessage:NSLocalizedString(@"AlbumMovePhotoProgressMessage", @"") andSuccessMessage:NSLocalizedString(@"MoveSuccessMessageNew", @"") andFailMessage:NSLocalizedString(@"AlbumMovePhotoFailMessage", @"")];
}

- (void) photosAddedSuccessCallback {
    [progress hide:YES];
    [delegate revisitedGroupedPhotoDidFinishDeletingOrMoving:NO];
}

- (void) photosAddedFailCallback:(NSString *) errorMessage {
    [progress hide:YES];
    [delegate revisitedGroupedPhotoDidFailMovingWithError:errorMessage];
}

#pragma mark - UITextFieldDelegate

- (void) textFieldDidEndEditing:(UITextField *) _textField {
    [searchField resignFirstResponder];
}

- (BOOL) textFieldShouldReturn:(UITextField *) _textField {
    [searchField resignFirstResponder];
    return YES;
}

#pragma mark -

- (void) searchTapped {
    [APPDELEGATE.base triggerInnerSearch];
}

#pragma mark - CustomConfirmDelegate Methods

- (void) didRejectCustomAlert:(CustomConfirmView *) alertView {
}

- (void) didApproveCustomAlert:(CustomConfirmView *) alertView {
    IGLog(@"RevisitedGroupedPhotoView didApproveCustomAlert deleteDao requestDeleteFiles called");
    [deleteDao requestDeleteFiles:[self uuidsOfOnlyDepoFiles]];
    [self bringSubviewToFront:progress];
    [progress show:YES];
}

#pragma mark -

- (NSMutableArray *) uuidsOfOnlyDepoFiles {
    NSMutableArray *result = [[NSMutableArray alloc] init];
    for(MetaFile *row in selectedMetaFiles) {
        [result addObject:row.uuid];
    }
    return result;
}

- (void) cancelRequests {
    //    [readDao cancelRequest];
    //    readDao = nil;
    //
    //    [deleteDao cancelRequest];
    //    deleteDao = nil;
    //
    //    [albumAddPhotosDao cancelRequest];
    //    albumAddPhotosDao = nil;
}

- (void) neutralizeSearchBar {
    if(collView.contentOffset.y < 0) {
        collView.contentOffset = CGPointMake(0, 0);
    }
}

- (void) autoIterationFinished {
    IGLog(@"At RevisitedGroupedPhotoView autoIterationFinished");
    if([[UploadQueue sharedInstance] remainingCount] > 0) {
        IGLog(@"At RevisitedGroupedPhotoView autoIterationFinished pullData will be called");
        [self pullData];
    }
}

- (void) autoQueueFinished {
    IGLog(@"At RevisitedGroupedPhotoView autoQueueFinished");
    if([[UploadQueue sharedInstance] remainingCount] == 0) {
        IGLog(@"At RevisitedGroupedPhotoView autoQueueFinished pullData will be called");
        
        [[UploadQueue sharedInstance] cleanAlreadyFinishedManagersNoReferenceToAutoSync];

        //refresh is postponed for 2 secs for the server to generate thumbnails.. will revisit here
        [self performSelector:@selector(postQueueEmpty) withObject:nil afterDelay:2.0f];
    }
}

- (void) postQueueEmpty {
    if(syncView) {
        [syncView removeFromSuperview];
    }
    if(collView.frame.origin.y > 0 && !syncInfoHeaderView) {
        [UIView animateWithDuration:0.4 animations:^{
            collView.frame = CGRectMake(collView.frame.origin.x, collView.frame.origin.y - 50, collView.frame.size.width, collView.frame.size.height + 50);
        }];
    }
    if([uploadingUuids count] > 0) {
        [detailDao requestFileDetails:uploadingUuids];
        [delegate revisitedGroupedPhotoWantsToShowLoading];
    } else {
        [delegate revisitedGroupedPhotoDidFinishUpdate];
    }
}

- (void) didReceiveMemoryWarning {
    IGLog(@"RevisitedGroupedPhotoView didReceiveMemoryWarning");
    NSLog(@"RevisitedGroupedPhotoView didReceiveMemoryWarning");
    /* TODO gerek var mı artık kontrol et
     NSNumber *startOffset = [NSNumber numberWithFloat:self.fileScroll.contentOffset.y];
     NSDictionary* userInfo = @{@"startOffset": startOffset};
     [[NSNotificationCenter defaultCenter] postNotificationName:@"IMAGE_SCROLL_RECEIVED_MEMORY_WARNING" object:self userInfo:userInfo];
     cleanedFlag = YES;
     lastCheckYIndex = self.fileScroll.contentOffset.y;
     */
}

#pragma mark - UICollectionViewDataSource Methods

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    FileInfoGroup *sectionGroup = [self.groups objectAtIndex:section];
    return [sectionGroup.fileInfo count];
}

- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView {
    return [self.groups count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    //    UICollectionViewCell * c = [cv dequeueReusableCellWithReuseIdentifier:@"COLL_PHOTO_CELL" forIndexPath:indexPath];
    if(self.groups.count > indexPath.section) {
        FileInfoGroup *sectionGroup = [self.groups objectAtIndex:indexPath.section];
        if(sectionGroup.fileInfo.count > indexPath.row) {
            id rowItem = [sectionGroup.fileInfo objectAtIndex:indexPath.row];
            if([rowItem isKindOfClass:[RawTypeFile class]]) {
                RawTypeFile *castedRow = (RawTypeFile *) rowItem;
                RevisitedRawPhotoCollCell *cell;
                if (castedRow.rawType == RawFileTypeDepo) {
                    cell = [cv dequeueReusableCellWithReuseIdentifier:@"COLL_PHOTO_CELL_DEPO" forIndexPath:indexPath];
                } else if(castedRow.rawType == RawFileTypeClient) {
                    cell = [cv dequeueReusableCellWithReuseIdentifier:@"COLL_PHOTO_CELL_CLIENT" forIndexPath:indexPath];
                }
                cell.delegate = self;
                [cell loadContent:castedRow
                     isSelectible:self.isSelectible
                   withImageWidth:imageWidth
                     withGroupKey:sectionGroup.groupKey
                       isSelected:(castedRow.rawType == RawFileTypeDepo ? [selectedFileList containsObject:castedRow.fileRef.uuid] : [selectedFileList containsObject:[castedRow.assetRef.defaultRepresentation.url absoluteString]])];
                return cell;
            } else {
                UploadRef *castedRow = (UploadRef *) rowItem;
                RevisitedUploadingPhotoCollCell *cell = [cv dequeueReusableCellWithReuseIdentifier:@"COLL_UPLOADING_PHOTO_CELL" forIndexPath:indexPath];
                cell.delegate = self;
                [cell loadContent:castedRow isSelectible:self.isSelectible withImageWidth:imageWidth withGroupKey:sectionGroup.groupKey isSelected:NO];
                return cell;
            }
        }
    }
    
    return [cv dequeueReusableCellWithReuseIdentifier:@"COLL_PHOTO_CELL" forIndexPath:indexPath];
}

# pragma mark - UICollectionViewDelegate Methods

- (void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    //    RevisitedPhotoCollCell *cell = (RevisitedPhotoCollCell *) [collectionView cellForItemAtIndexPath:indexPath];
}

#pragma mark - UICollectionViewDelegateFlowLayout Methods

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(imageWidth, imageWidth);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(2, 2, 20, 2);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionView *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 2;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionView *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 2;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    if(!initialLoadDone) {
        return CGSizeZero;
    } else {
        FileInfoGroup *sectionGroup = [self.groups objectAtIndex:section];
        if([sectionGroup.fileInfo count] > 0) {
            return CGSizeMake(self.frame.size.width, 40);
        } else {
            return CGSizeZero;
        }
    }
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)theCollectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)theIndexPath {
    GroupPhotoSectionView *collFooterView = [theCollectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                                                                                  withReuseIdentifier:@"group_photo_header"
                                                                                         forIndexPath:theIndexPath];
    if(kind == UICollectionElementKindSectionHeader && initialLoadDone) {
        if(self.groups.count > theIndexPath.section) {
            FileInfoGroup *sectionGroup = [self.groups objectAtIndex:theIndexPath.section];
            collFooterView.checkDelegate = self;
            [collFooterView loadSectionWithTitle:sectionGroup.customTitle isSelectible:isSelectible isSelected:[selectedSectionNames containsObject:sectionGroup.customTitle]];
            return collFooterView;
        }
        collFooterView.frame = CGRectZero;
        return collFooterView;
    }
    collFooterView.frame = CGRectZero;
    return collFooterView;
}

#pragma mark -

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - View Operations

- (void) showVerticalIndicator {
    if(verticalIndicator.isHidden) {
        verticalIndicator.hidden = NO;
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideVerticalIndicator) object:nil];
        [UIView animateWithDuration:0.2f delay:0.0f options:0 animations:^{
            verticalIndicator.alpha = 1.0f;
        } completion:^(BOOL finished) {
        }];
    }
}

- (void) hideVerticalIndicator {
    [UIView animateWithDuration:0.2f delay:0.0f options:0 animations:^{
        verticalIndicator.alpha = 0.0f;
    } completion:^(BOOL finished) {
        verticalIndicator.hidden = YES;
    }];
}

#pragma mark - AutoSyncOffHeaderDelegate Methods

- (void) autoSyncOffHeaderViewCloseClicked {
    if(self.syncInfoHeaderView) {
        [self.syncInfoHeaderView removeFromSuperview];
        self.syncInfoHeaderView = nil;
        [UIView animateWithDuration:0.4 animations:^{
            self.collView.frame = CGRectMake(self.collView.frame.origin.x, self.collView.frame.origin.y - 50, self.collView.frame.size.width, self.collView.frame.size.height + 50);
        }];
        collViewOriginalHeight = collViewOriginalHeight + 50;
    }
    APPDELEGATE.session.photosSyncHeaderShownFlag = YES;
}

- (void) autoSyncOffHeaderViewSettingsClicked {
//    [APPDELEGATE triggerSyncSettings];
    [delegate triggerSyncSettings];
}

#pragma mark - SyncManagerInfoDelegate Methods

- (void) syncManagerUnsyncedImageList:(NSArray *)unsyncedAssets {
    //    [delegate revisitedGroupedPhotoWantsToHideLoading];
    IGLog(@"RevisitedGroupedPhotoView syncManagerUnsyncedImageList called");
    localAssets = [unsyncedAssets sortedArrayUsingComparator:^NSComparisonResult(ALAsset *first, ALAsset *second) {
        NSDate * date1 = [first valueForProperty:ALAssetPropertyDate];
        NSDate * date2 = [second valueForProperty:ALAssetPropertyDate];
        return [date2 compare:date1];
    }];
    [self addUnsyncedFiles];
}

- (void) syncManagerNumberOfImagesWaitingForUpload:(int) imgCount {
    if(syncInfoHeaderView) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [syncInfoHeaderView updateBottomLabelWithCount:imgCount];
        });
    }
}

- (void) addUnsyncedFiles {
    IGLog(@"RevisitedGroupedPhotoView addUnsyncedFiles called");
    NSLog(@"RevisitedGroupedPhotoView addUnsyncedFiles called");
    MetaFile *lastFile = nil;
    BOOL noFilesFlag = YES;
    if([files count] > 0) {
        lastFile = files.lastObject;
        noFilesFlag = NO;
        
        if(lastCheckedDate != nil) {
            if([lastCheckedDate compare:lastFile.detail.imageDate] == NSOrderedSame) {
                isLoading = NO;
                [collView reloadData];
                return;
            }
        }
    }
    NSMutableDictionary *tempDict = [[NSMutableDictionary alloc] init];
//    NSArray *currentUploadingRefHashes = [[UploadQueue sharedInstance] uploadRefHashes];
    for(ALAsset *row in localAssets) {
        NSDate *assetDate = [row valueForProperty:ALAssetPropertyDate];
        
        BOOL shouldShow = YES;
        if(lastFile != nil) {
            if([assetDate compare:lastFile.detail.imageDate] == NSOrderedAscending) {
                shouldShow = NO;
            }
        }
        if(shouldShow && lastCheckedDate != nil) {
            if([assetDate compare:lastCheckedDate] == NSOrderedDescending) {
                shouldShow = NO;
            }
        }

        NSString *rowLocalHash = [SyncUtil md5StringOfString:[row.defaultRepresentation.url absoluteString]];

//        if(shouldShow) {
//            if([currentUploadingRefHashes containsObject:rowLocalHash]) {
//                shouldShow = NO;
//            }
//        }
        
        if(noFilesFlag || shouldShow || endOfFiles) {
            NSString *dateStr = [dateCompareFormat stringFromDate:assetDate];
            if([[tempDict allKeys] count] == 0) {
                FileInfoGroup *newGroup = [[FileInfoGroup alloc] init];
                newGroup.customTitle = dateStr;
                newGroup.refDate = assetDate;
                newGroup.locationInfo = @"";
                newGroup.fileInfo = [[NSMutableArray alloc] init];
                if(![self.fileHashList containsObject:rowLocalHash]) {
                    RawTypeFile *rawFile = [self rawFileForAsset:row];
                    [newGroup.fileInfo addObject:rawFile];
                    if(rawFile.hashRef) {
                        [self addObjectToFileHashList:rawFile.hashRef];
                    }
                }
                newGroup.sequence = groupSequence;
                newGroup.groupKey = dateStr;
                [tempDict setObject:newGroup forKey:dateStr];
                
                groupSequence ++;
            } else {
                FileInfoGroup *currentGroup = [tempDict objectForKey:dateStr];
                if(currentGroup != nil) {
                    if(![self.fileHashList containsObject:rowLocalHash]) {
                        RawTypeFile *rawFile = [self rawFileForAsset:row];
                        [currentGroup.fileInfo addObject:rawFile];
                        if(rawFile.hashRef) {
                            [self addObjectToFileHashList:rawFile.hashRef];
                        }
                    }
                } else {
                    FileInfoGroup *newGroup = [[FileInfoGroup alloc] init];
                    newGroup.customTitle = dateStr;
                    newGroup.refDate = assetDate;
                    newGroup.locationInfo = @"";
                    newGroup.fileInfo = [[NSMutableArray alloc] init];
                    if(![self.fileHashList containsObject:rowLocalHash]) {
                        RawTypeFile *rawFile = [self rawFileForAsset:row];
                        [newGroup.fileInfo addObject:rawFile];
                        if(rawFile.hashRef) {
                            [self addObjectToFileHashList:rawFile.hashRef];
                        }
                    }
                    newGroup.sequence = groupSequence;
                    newGroup.groupKey = dateStr;
                    [tempDict setObject:newGroup forKey:dateStr];
                    groupSequence ++;
                }
            }
        }
    }
    
    if(lastFile != nil) {
        lastCheckedDate = lastFile.detail.imageDate;
    }
    
    NSArray *tempGroups = [tempDict allValues];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"sequence" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    tempGroups = [tempGroups sortedArrayUsingDescriptors:sortDescriptors];
    
    for(FileInfoGroup *row in tempGroups) {
        [self addOrUpdateGroup:row];
    }
    
    if([[SyncUtil readSyncHashRemotely] count] > 0) {
        [[SyncManager sharedInstance] numberOfUnsyncedImages];
    } else {
        [bulkReadDao requestPhotosAndVideosForPage:0 andSize:300000 andSortType:SortTypeAlphaAsc isMinimal:YES];
    }
    
    isLoading = NO;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        IGLog(@"RevisitedGroupedPhotoView addUnsyncedFiles ended");
        [collView reloadData];
    });
}

- (NSMutableArray *) sortRawArrayByDateDesc:(NSArray *) rawArray {
    NSArray *sortedArray = [rawArray sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        NSDate *first = [(RawTypeFile *) a refDate];
        NSDate *second = [(RawTypeFile *)b refDate];
        return [second compare:first];
    }];
    return [sortedArray mutableCopy];
}

- (RawTypeFile *) rawFileForAsset:(ALAsset *) assetRef {
    RawTypeFile *result = [[RawTypeFile alloc] init];
    result.assetRef = assetRef;
    result.rawType = RawFileTypeClient;
    result.refDate = [assetRef valueForProperty:ALAssetPropertyDate];
    result.hashRef = [SyncUtil md5StringOfString:[assetRef.defaultRepresentation.url absoluteString]];
    return result;
}

- (RawTypeFile *) rawFileForFile:(MetaFile *) fileRef {
    RawTypeFile *result = [[RawTypeFile alloc] init];
    result.fileRef = fileRef;
    result.rawType = RawFileTypeDepo;
    result.refDate = fileRef.detail.imageDate;
    result.hashRef = fileRef.metaHash;
    return result;
}

#pragma mark - RawPhotoCollCellDelegate Methods

- (void) rawPhotoCollCellImageWasSelectedForFile:(MetaFile *) fileSelected forGroupWithKey:(NSString *) groupKey {
    //    NSMutableArray *listToPass = [[NSMutableArray alloc] init];
    //    [listToPass addObject:fileSelected];
    //
    //    for(FileInfoGroup *row in self.groups) {
    //        if([row.groupKey isEqualToString:groupKey]) {
    //            for(id obj in row.fileInfo) {
    //                if([obj isKindOfClass:[RawTypeFile class]]) {
    //                    RawTypeFile *castedObj = (RawTypeFile *) obj;
    //                    [listToPass addObject:castedObj.fileRef];
    //                }
    //            }
    //        }
    //    }
    //    [delegate revisitedGroupedPhotoDidSelectFile:fileSelected withList:listToPass];
    // send with all files, listoffset and package size
    [delegate revisitedGroupedPhotoDidSelectFile:fileSelected withList:self.files withListOffset:listOffset withPackageSize:packageSize];
}

- (void) rawPhotoCollCellImageWasMarkedForFile:(MetaFile *) fileSelected {
    if(fileSelected.uuid) {
        if(![selectedFileList containsObject:fileSelected.uuid]) {
            [selectedFileList addObject:fileSelected.uuid];
            [selectedMetaFiles addObject:fileSelected];
        }
    }
    if([selectedFileList count] > 0) {
        [self showImgFooterMenu];
        [delegate revisitedGroupedPhotoChangeTitleTo:[NSString stringWithFormat:NSLocalizedString(@"FilesSelectedTitle", @""), [selectedFileList count]]];
    } else {
        [self hideImgFooterMenu];
        [delegate revisitedGroupedPhotoChangeTitleTo:NSLocalizedString(@"SelectFilesTitle", @"")];
    }
    
    if (fileSelected.contentType == ContentTypeVideo) {
        if (photoCount == 0) {
            [imgFooterActionMenu hidePrintIcon];
        } else{
            [imgFooterActionMenu showPrintIcon];
        }
    } else {
        photoCount++;
        [imgFooterActionMenu showPrintIcon];
    }
    
    [self toggleFooterRemoteButtons];
}

- (void) rawPhotoCollCellImageWasUnmarkedForFile:(MetaFile *) fileSelected {
    if([selectedFileList containsObject:fileSelected.uuid]) {
        [selectedFileList removeObject:fileSelected.uuid];
        [selectedMetaFiles removeObject:fileSelected];
    }
    if([selectedFileList count] > 0) {
        [self showImgFooterMenu];
        [delegate revisitedGroupedPhotoChangeTitleTo:[NSString stringWithFormat:NSLocalizedString(@"FilesSelectedTitle", @""), [selectedFileList count]]];
    } else {
        [self hideImgFooterMenu];
        [delegate revisitedGroupedPhotoChangeTitleTo:NSLocalizedString(@"SelectFilesTitle", @"")];
    }
    if (fileSelected.contentType == ContentTypePhoto) {
        photoCount--;
    }
    if (photoCount == 0) {
        [imgFooterActionMenu hidePrintIcon];
    }
    
    [self toggleFooterRemoteButtons];
}

- (void) rawPhotoCollCellImageUploadFinishedForFile:(NSString *) fileSelectedUuid {
}

- (void) rawPhotoCollCellImageWasLongPressedForFile:(MetaFile *) fileSelected {
    [self setToSelectible];
    [delegate revisitedGroupedPhotoDidChangeToSelectState];
}

- (void) rawPhotoCollCellImageUploadQuotaError:(MetaFile *) fileSelected {
}

- (void) rawPhotoCollCellImageUploadLoginError:(MetaFile *) fileSelected {
}

- (void) rawPhotoCollCellImageWasSelectedForView:(SquareImageView *) ref {
}

- (void) rawPhotoCollCellAssetDidBecomeSelected:(ALAsset *) selectedAsset {
}

- (void) rawPhotoCollCellAssetDidBecomeDeselected:(ALAsset *) deselectedAsset {
}

- (void) rawPhotoCollCellImageWasSelectedForAsset:(ALAsset *) fileSelected {
    [delegate revisitedGroupedPhotoDidSelectAsset:fileSelected];
}

- (void) rawPhotoCollCellImageWasMarkedForAsset:(ALAsset *) fileSelected {
    if(fileSelected != nil) {
        NSString *assetUrl = [fileSelected.defaultRepresentation.url absoluteString];
        if(![selectedFileList containsObject:assetUrl]) {
            [selectedFileList addObject:assetUrl];
            [selectedAssets addObject:fileSelected];
        }
    }
    
    if([selectedFileList count] > 0) {
        [self showImgFooterMenu];
        [delegate revisitedGroupedPhotoChangeTitleTo:[NSString stringWithFormat:NSLocalizedString(@"FilesSelectedTitle", @""), [selectedFileList count]]];
    } else {
        [self hideImgFooterMenu];
        [delegate revisitedGroupedPhotoChangeTitleTo:NSLocalizedString(@"SelectFilesTitle", @"")];
    }
    
    photoCount++;
    [imgFooterActionMenu showPrintIcon];
    
    [self toggleFooterSyncButton];
    [self toggleFooterRemoteButtons];
}

- (void) toggleFooterSyncButton {
    if([selectedAssets count] > 0) {
        [imgFooterActionMenu enableSyncButton];
    } else {
        [imgFooterActionMenu disableSyncButton];
    }
}

- (void) toggleFooterRemoteButtons {
    if([selectedMetaFiles count] > 0) {
        [imgFooterActionMenu enableDeleteButton];
        [imgFooterActionMenu enableMoveButton];
//        [imgFooterActionMenu enablePrintButton];
        [imgFooterActionMenu enableDownloadButton];
    } else {
        [imgFooterActionMenu disableDeleteButton];
//        [imgFooterActionMenu disableMoveButton];
//        [imgFooterActionMenu disablePrintButton];
        [imgFooterActionMenu disableDownloadButton];
    }
}

- (void) rawPhotoCollCellImageWasUnmarkedForAsset:(ALAsset *) fileSelected {
    if(fileSelected != nil) {
        NSString *assetUrl = [fileSelected.defaultRepresentation.url absoluteString];
        if([selectedFileList containsObject:assetUrl]) {
            [selectedFileList removeObject:assetUrl];
            [selectedAssets removeObject:fileSelected];
        }
    }
    if([selectedFileList count] > 0) {
        [self showImgFooterMenu];
        [delegate revisitedGroupedPhotoChangeTitleTo:[NSString stringWithFormat:NSLocalizedString(@"FilesSelectedTitle", @""), [selectedFileList count]]];
    } else {
        [self hideImgFooterMenu];
        [delegate revisitedGroupedPhotoChangeTitleTo:NSLocalizedString(@"SelectFilesTitle", @"")];
    }
    
    photoCount--;
    
    if (photoCount == 0) {
        [imgFooterActionMenu hidePrintIcon];
    }
    
    [self toggleFooterSyncButton];
    [self toggleFooterRemoteButtons];
}

- (void) rawPhotoCollCellImageUploadFinishedForAsset:(ALAsset *) fileSelected {
}

- (void) rawPhotoCollCellImageWasLongPressedForAsset:(ALAsset *) fileSelected {
    [self setToSelectible];
    [delegate revisitedGroupedPhotoDidChangeToSelectState];
}

- (void) rawPhotoCollCellImageUploadQuotaErrorForAsset:(ALAsset *) fileSelected {
}

- (void) rawPhotoCollCellImageUploadLoginErrorForAsset:(ALAsset *) fileSelected {
}

#pragma mark - GroupPhotoSectionViewDelegate Methods

- (void) groupPhotoSectionViewCheckboxChecked:(NSString *) titleVal {
    if(![selectedSectionNames containsObject:titleVal]) {
        [selectedSectionNames addObject:titleVal];
        
        NSArray *selectedGroupList = nil;
        int index = 0;
        for(FileInfoGroup *row in self.groups) {
            if([row.customTitle isEqualToString:titleVal]) {
                selectedGroupList = row.fileInfo;
                break;
            }
            index ++;
        }
        if(selectedGroupList != nil) {
            for(id rowItem in selectedGroupList) {
                if([rowItem isKindOfClass:[RawTypeFile class]]) {
                    RawTypeFile *castedRow = (RawTypeFile *) rowItem;
                    if (castedRow.rawType == RawFileTypeDepo) {
                        if(![selectedFileList containsObject:castedRow.fileRef.uuid]) {
                            [selectedFileList addObject:castedRow.fileRef.uuid];
                            [selectedMetaFiles addObject:castedRow.fileRef];
                        }
                    } else {
                        NSString *assetUrl = [castedRow.assetRef.defaultRepresentation.url absoluteString];
                        if(![selectedFileList containsObject:assetUrl]) {
                            [selectedFileList addObject:assetUrl];
                            [selectedAssets addObject:castedRow.assetRef];
                        }
                    }
                }
            }
            if([selectedFileList count] > 0) {
                [self showImgFooterMenu];
                [delegate revisitedGroupedPhotoChangeTitleTo:[NSString stringWithFormat:NSLocalizedString(@"FilesSelectedTitle", @""), [selectedFileList count]]];
            } else {
                [self hideImgFooterMenu];
                [delegate revisitedGroupedPhotoChangeTitleTo:NSLocalizedString(@"SelectFilesTitle", @"")];
            }
        }
        [self toggleFooterSyncButton];
        [self toggleFooterRemoteButtons];

        [self.collView reloadSections:[NSIndexSet indexSetWithIndex:index]];
    }
}

- (void) groupPhotoSectionViewCheckboxUnchecked:(NSString *) titleVal {
    if([selectedSectionNames containsObject:titleVal]) {
        [selectedSectionNames removeObject:titleVal];
        
        NSArray *unselectedGroupList = nil;
        int index = 0;
        for(FileInfoGroup *row in self.groups) {
            if([row.customTitle isEqualToString:titleVal]) {
                unselectedGroupList = row.fileInfo;
                break;
            }
            index ++;
        }
        if(unselectedGroupList != nil) {
            for(id rowItem in unselectedGroupList) {
                if([rowItem isKindOfClass:[RawTypeFile class]]) {
                    RawTypeFile *castedRow = (RawTypeFile *) rowItem;
                    if (castedRow.rawType == RawFileTypeDepo) {
                        if([selectedFileList containsObject:castedRow.fileRef.uuid]) {
                            [selectedFileList removeObject:castedRow.fileRef.uuid];
                            [selectedMetaFiles removeObject:castedRow.fileRef];
                        }
                    } else {
                        NSString *assetUrl = [castedRow.assetRef.defaultRepresentation.url absoluteString];
                        if([selectedFileList containsObject:assetUrl]) {
                            [selectedFileList removeObject:assetUrl];
                            [selectedAssets removeObject:castedRow.assetRef];
                        }
                    }
                }
            }
            if([selectedFileList count] > 0) {
                [self showImgFooterMenu];
                [delegate revisitedGroupedPhotoChangeTitleTo:[NSString stringWithFormat:NSLocalizedString(@"FilesSelectedTitle", @""), [selectedFileList count]]];
            } else {
                [self hideImgFooterMenu];
                [delegate revisitedGroupedPhotoChangeTitleTo:NSLocalizedString(@"SelectFilesTitle", @"")];
            }
        }
        [self toggleFooterSyncButton];
        [self toggleFooterRemoteButtons];

        [self.collView reloadSections:[NSIndexSet indexSetWithIndex:index]];
    }
}

#pragma mark -

- (void) photosHeaderSyncFinishedForAssetUrl:(NSString *)urlVal {
    if(urlVal) {
        NSString *localHash = [SyncUtil md5StringOfString:urlVal];
        [SyncUtil cacheSyncHashLocally:localHash];
    }
}

- (void) autoQueueChanged {
    IGLog(@"RevisitedGroupedPhotoView autoQueueChanged called");
    dispatch_async(dispatch_get_main_queue(), ^{
        if(syncView) {
            [syncView removeFromSuperview];
        }
        __weak RevisitedGroupedPhotoView *weakSelf = self;
        UploadManager *activeManRef = [[UploadQueue sharedInstance] activeManager];
        if(activeManRef != nil) {
            IGLog(@"RevisitedGroupedPhotoView autoQueueChanged initializing PhotosHeaderSyncView");
            syncView = [[PhotosHeaderSyncView alloc] initWithFrame:CGRectMake(0, 0, weakSelf.frame.size.width, 50)];
            activeManRef.headerDelegate = syncView;
            syncView.delegate = weakSelf;
            
            [self addSubview:syncView];
            if(activeManRef.uploadRef.taskType == UploadTaskTypeAsset) {
                [syncView loadAsset:activeManRef.uploadRef.assetUrl];
            } else if(activeManRef.uploadRef.taskType == UploadTaskTypeFile) {
                [syncView loadLocalFileForCamUpload:activeManRef.uploadRef.tempUrl];
            }
            
        } else {
            IGLog(@"RevisitedGroupedPhotoView autoQueueChanged no need to initialize PhotosHeaderSyncView");
            if(collView.frame.origin.y > 0 && !syncInfoHeaderView) {
                [UIView animateWithDuration:0.4 animations:^{
                    collView.frame = CGRectMake(collView.frame.origin.x, collView.frame.origin.y - 50, collView.frame.size.width, collView.frame.size.height + 50);
                }];
            }
        }
    });
}

- (void) detailSuccessCallback:(NSArray *) fileList {
    NSLog(@"Resulting file list: %@", fileList);
    [self removeLockMask];
    [delegate revisitedGroupedPhotoWantsToHideLoading];
    [delegate revisitedGroupedPhotoDidFinishUpdate];
    [uploadingUuids removeAllObjects];
    if([fileList count] > 0) {
        for(MetaFile *file in fileList) {
            if(![selectedFileList containsObject:file.uuid]) {
                [selectedFileList addObject:file.uuid];
                [selectedMetaFiles addObject:file];
            }
        }
        if(postUploadProcessType == NextProcessTypeShare) {
            if ([delegate respondsToSelector:@selector(revisitedGroupedPhoto:triggerShareForFiles:withUUID:)]) {
                [delegate revisitedGroupedPhoto:self triggerShareForFiles:selectedMetaFiles withUUID:selectedFileList];
                return;
            }
            [delegate revisitedGroupedPhoto:self triggerShareForFiles:selectedMetaFiles];
            // [APPDELEGATE.base triggerShareForFiles:selectedFileList];
        } else if(postUploadProcessType == NextProcessTypeMove) {
            [delegate revisitedGroupedPhotoShowPhotoAlbums:self];
            //[APPDELEGATE.base showPhotoAlbums];
        } else if(postUploadProcessType == NextProcessTypeRefresh) {
            //TODO is pullData needed?
        }
    }
}

- (void) detailFailCallback:(NSString *) errorMessage {
    [self removeLockMask];
    [delegate revisitedGroupedPhotoWantsToHideLoading];
    [delegate revisitedGroupedPhotoDidFinishUpdate];
    [uploadingUuids removeAllObjects];
}


#pragma mark - BulkRead delegate methods for header unsync image count

- (void) bulkReadSuccessCallback:(NSArray *) bulkFiles {
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void) {
        NSMutableArray *hashArray = [[NSMutableArray alloc] init];
        for(MetaFile *row in bulkFiles) {
            if(row.metaHash != nil) {
                [hashArray addObject:row.metaHash];
            }
        }
        [SyncUtil cacheSyncHashesRemotely:hashArray];
        [[SyncManager sharedInstance] numberOfUnsyncedImages];
    });
}

- (void) bulkReadFailCallback:(NSString *) errorMessage {
}

- (void) resizeCollViewHeightForFooterMenu {
    if (!imgFooterActionMenu.isHidden) {
        CGRect frame = collView.frame;
        frame.size = CGSizeMake(frame.size.width, collViewOriginalHeight - imgFooterActionMenu.frame.size.height);

        if (collView.frame.size.height < frame.size.height) {
            collView.frame = frame;
        } else {
            // uiview animation collview ile duzgun calismiyor. Workaround cozum uygulandi.
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(Footer_Animation_Duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if([selectedFileList count] > 0) { // footer hala gorunuyorsa ata
                    collView.frame = frame;
                }
            });
        }
    }
    else if (imgFooterActionMenu.isHidden || imgFooterActionMenu == nil) {
        CGRect frame = collView.frame;
        frame.size = CGSizeMake(frame.size.width, collViewOriginalHeight);
        collView.frame = frame;
    }
}

@end
