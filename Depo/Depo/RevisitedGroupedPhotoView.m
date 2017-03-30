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

#define GROUP_PACKAGE_SIZE (IS_IPAD ? 60 : IS_IPHONE_6P_OR_HIGHER ? 60 : 48)
#define GROUP_IMG_COUNT_PER_ROW (IS_IPAD ? 6 : IS_IPHONE_6P_OR_HIGHER ? 6 : 4)

#define GROUP_INPROGRESS_KEY @"in_progress"
#define IMAGE_SCROLL_THRESHOLD 2000

@interface RevisitedGroupedPhotoView() {
    int tableUpdateCounter;
    int listOffset;
    BOOL isLoading;
    int photoCount;
    int groupSequence;
    NSDateFormatter *dateCompareFormat;
    BOOL anyOngoingPresent;
    BOOL initialLoadDone;
    
    BOOL cleanedFlag;
    float lastCheckYIndex;
    
    float yIndex;
    float imageWidth;
    
    float collViewOriginalHeight;
}
@end

@implementation RevisitedGroupedPhotoView

@synthesize delegate;
@synthesize files;
@synthesize selectedFileList;
@synthesize selectedMetaFiles;
@synthesize refreshControl;
@synthesize readDao;
@synthesize deleteDao;
@synthesize albumAddPhotosDao;
@synthesize imgFooterActionMenu;
@synthesize isSelectible;
@synthesize progress;
@synthesize searchField;
@synthesize noItemView;
@synthesize verticalIndicator;
@synthesize sectionIndicator;

@synthesize groups;
@synthesize collView;

- (id) initWithFrame:(CGRect)frame {
    if(self = [super initWithFrame:frame]) {
        self.backgroundColor = [Util UIColorForHexColor:@"FFFFFF"];
        
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
        selectedFileList = [[NSMutableArray alloc] init];
        selectedMetaFiles = [[NSMutableArray alloc] init];
        
        yIndex = 0;
        
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        
        collView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height) collectionViewLayout:layout];
        collView.dataSource = self;
        collView.delegate = self;
        collView.showsVerticalScrollIndicator = NO;
        collView.backgroundColor = [UIColor whiteColor];
        [collView registerClass:[RevisitedPhotoCollCell class] forCellWithReuseIdentifier:@"COLL_PHOTO_CELL"];
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
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkCollectionViewData) name:UIApplicationDidBecomeActiveNotification object:nil];
    }
    return self;
}

- (void) checkCollectionViewData {
    if ([CacheUtil readRememberMeToken] != nil) {
        if ([self.groups count] < 1 || [self.files count] < 1) {
            [self pullData];
        }
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

- (void) pullData {
    
    if([delegate checkInternet]) {
        listOffset = 0;
        groupSequence = 0;
        
        [groups removeAllObjects];
        [files removeAllObjects];
        
        [self.collView performSelectorOnMainThread:@selector(reloadData)
                                        withObject:nil
                                     waitUntilDone:NO];
        
        yIndex = 60;
        
        [self addOngoingGroup];
        
        int packageSize = GROUP_PACKAGE_SIZE;
        if([[Util deviceType] isEqualToString:@"iPhone 6 Plus"] || [[Util deviceType] isEqualToString:@"iPhone 6S Plus"]) {
            packageSize = 60;
        }
        [readDao requestPhotosAndVideosForPage:listOffset andSize:packageSize andSortType:SortTypeDateDesc];
        isLoading = YES;
        
        [self bringSubviewToFront:progress];
        [progress show:YES];
    }
    else {
        [refreshControl endRefreshing];
    }
    
    
}

- (void) addOngoingGroup {
    NSArray *uploadingImageRefArray = [[UploadQueue sharedInstance] uploadImageRefs];
    if([uploadingImageRefArray count] > 0) {
        FileInfoGroup *inProgressGroup = [[FileInfoGroup alloc] init];
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
        [self.groups replaceObjectAtIndex:counter withObject:initialRow];
    } else {
        [self.groups addObject:group];
    }
    
    [self neutralizeSearchBar];
}

- (void) deleteSuccessCallback {
    IGLog(@"RevisitedGroupedPhotoView deleteSuccessCallback");
    [progress hide:YES];
    [delegate revisitedGroupedPhotoDidFinishDeletingOrMoving];
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
        
        [collView reloadData];
    }
}

- (void) setToUnselectiblePriorToRefresh {
    isSelectible = NO;
    [self createRefreshControl];
    [selectedFileList removeAllObjects];
    [selectedMetaFiles removeAllObjects];
    
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
    initialLoadDone = YES;
    
    if([fileList count] > 0) {
        [files addObjectsFromArray:fileList];
        
        NSMutableDictionary *tempDict = [[NSMutableDictionary alloc] init];
        for(MetaFile *row in fileList) {
            if(row.detail.fileDate) {
                NSString *dateStr = [dateCompareFormat stringFromDate:row.detail.fileDate];
                if([[tempDict allKeys] count] == 0) {
                    FileInfoGroup *newGroup = [[FileInfoGroup alloc] init];
                    newGroup.customTitle = dateStr;
                    newGroup.locationInfo = @"";
                    newGroup.fileInfo = [[NSMutableArray alloc] init];
                    [newGroup.fileInfo addObject:row];
                    newGroup.sequence = groupSequence;
                    newGroup.groupKey = dateStr;
                    [tempDict setObject:newGroup forKey:dateStr];
                    
                    groupSequence ++;
                } else {
                    FileInfoGroup *currentGroup = [tempDict objectForKey:dateStr];
                    if(currentGroup != nil) {
                        [currentGroup.fileInfo addObject:row];
                    } else {
                        FileInfoGroup *newGroup = [[FileInfoGroup alloc] init];
                        newGroup.customTitle = dateStr;
                        newGroup.locationInfo = @"";
                        newGroup.fileInfo = [[NSMutableArray alloc] init];
                        [newGroup.fileInfo addObject:row];
                        newGroup.sequence = groupSequence;
                        newGroup.groupKey = dateStr;
                        [tempDict setObject:newGroup forKey:dateStr];
                        groupSequence ++;
                    }
                }
            }
        }
        
        NSArray *tempGroups = [tempDict allValues];
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"sequence" ascending:YES];
        NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
        tempGroups = [tempGroups sortedArrayUsingDescriptors:sortDescriptors];
        
        for(FileInfoGroup *row in tempGroups) {
            [self addOrUpdateGroup:row];
        }
    }
    
    isLoading = NO;
    [refreshControl endRefreshing];
    
    if ([files count] == 0 && !anyOngoingPresent) {
        if (noItemView == nil) {
            noItemView = [[NoItemView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, collView.frame.size.height) imageName:@"no_photo_icon" titleText:NSLocalizedString(@"EmptyPhotosVideosTitle", @"") descriptionText:NSLocalizedString(@"EmptyPhotosVideosDescription", @"")];
            [self addSubview:noItemView];
        }
    } else if (noItemView != nil) {
        [noItemView removeFromSuperview];
    }
    [collView reloadData];
}

- (void) readFailCallback:(NSString *) errorMessage {
    [progress hide:YES];
    isLoading = NO;
    [refreshControl endRefreshing];
    [delegate revisitedGroupedPhotoShowErrorMessage:errorMessage];
}

- (void) scrollViewDidScroll:(UIScrollView *)scrollView {
    if([ReachabilityManager isReachable]) {
        if(!isLoading) {
            CGFloat currentOffset = collView.contentOffset.y;
            CGFloat maximumOffset = collView.contentSize.height - collView.frame.size.height;
            
            if (maximumOffset > 0.0f && currentOffset - maximumOffset >= 0.0f) {
                isLoading = YES;
                [self dynamicallyLoadNextPage];
            }
            if(cleanedFlag) {
                if(fabs(currentOffset - lastCheckYIndex) <= IMAGE_SCROLL_THRESHOLD/2) {
                    NSNumber *startOffset = [NSNumber numberWithFloat:self.collView.contentOffset.y];
                    NSDictionary* userInfo = @{@"startOffset": startOffset};
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

- (void) dynamicallyLoadNextPage {
    listOffset ++;
    int packageSize = GROUP_PACKAGE_SIZE;
    if([[Util deviceType] isEqualToString:@"iPhone 6 Plus"] || [[Util deviceType] isEqualToString:@"iPhone 6S Plus"]) {
        packageSize = 60;
    }
    [readDao requestPhotosAndVideosForPage:listOffset andSize:packageSize andSortType:SortTypeDateDesc];
}

- (void) revisitedPhotoCollCellImageWasSelectedForFile:(MetaFile *) fileSelected forGroupWithKey:(NSString *) groupKey {
    NSArray *listToPass = @[fileSelected];
    
    for(FileInfoGroup *row in self.groups) {
        if([row.groupKey isEqualToString:groupKey]) {
            listToPass = row.fileInfo;
        }
    }
    [delegate revisitedGroupedPhotoDidSelectFile:fileSelected withList:listToPass];
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
        imgFooterActionMenu = [[FooterActionsMenuView alloc] initWithFrame:CGRectMake(0, self.frame.size.height - 70, self.frame.size.width, 60) shouldShowShare:YES shouldShowMove:YES shouldShowDelete:YES shouldShowDownload:YES shouldShowPrint:YES];
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
        [deleteDao requestDeleteFiles:selectedFileList];
        [self bringSubviewToFront:progress];
        [progress show:YES];
    }
}

- (void) footerActionMenuDidSelectDownload:(FooterActionsMenuView *) menu {
    [delegate revisitedGroupedPhoto:self downloadSelectedFiles:selectedMetaFiles];
}

- (void) footerActionMenuDidSelectDelete:(FooterActionsMenuView *) menu {
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
            [deleteDao requestDeleteFiles:selectedFileList];
            [self bringSubviewToFront:progress];
            [progress show:YES];
        }
        
        //        [self pushProgressViewWithProcessMessage:NSLocalizedString(@"DeleteProgressMessage", @"") andSuccessMessage:NSLocalizedString(@"DeleteSuccessMessage", @"") andFailMessage:NSLocalizedString(@"DeleteFailMessage", @"")];
    } else {
        [delegate revisitedGroupedPhotoShouldConfirmForDeleting];
    }
}

- (void) footerActionMenuDidSelectMove:(FooterActionsMenuView *) menu {
    [delegate revisitedGroupedPhotoShowPhotoAlbums:self];
    //[APPDELEGATE.base showPhotoAlbums];
}

- (void) footerActionMenuDidSelectShare:(FooterActionsMenuView *) menu {
    [delegate revisitedGroupedPhoto:self triggerShareForFiles:selectedFileList];
    // [APPDELEGATE.base triggerShareForFiles:selectedFileList];
}

- (void) footerActionMenuDidSelectPrint:(FooterActionsMenuView *)menu {
    [delegate revisitedGroupedPhotoShouldPrintWithFileList:selectedMetaFiles];
}

- (void) destinationAlbumChosenWithUuid:(NSString *) chosenAlbumUuid {
    [albumAddPhotosDao requestAddPhotos:selectedFileList toAlbum:chosenAlbumUuid];
    [self bringSubviewToFront:progress];
    [progress show:YES];
    //TODO    [self pushProgressViewWithProcessMessage:NSLocalizedString(@"AlbumMovePhotoProgressMessage", @"") andSuccessMessage:NSLocalizedString(@"MoveSuccessMessageNew", @"") andFailMessage:NSLocalizedString(@"AlbumMovePhotoFailMessage", @"")];
}

- (void) photosAddedSuccessCallback {
    [progress hide:YES];
    [delegate revisitedGroupedPhotoDidFinishDeletingOrMoving];
}

- (void) photosAddedFailCallback:(NSString *) errorMessage {
    [progress hide:YES];
    [delegate revisitedGroupedPhotoDidFailMovingWithError:errorMessage];
}

- (void) textFieldDidEndEditing:(UITextField *) _textField {
    [searchField resignFirstResponder];
}

- (BOOL) textFieldShouldReturn:(UITextField *) _textField {
    [searchField resignFirstResponder];
    return YES;
}

- (void) searchTapped {
    [APPDELEGATE.base triggerInnerSearch];
}

- (void) didRejectCustomAlert:(CustomConfirmView *) alertView {
}

- (void) didApproveCustomAlert:(CustomConfirmView *) alertView {
    IGLog(@"RevisitedGroupedPhotoView didApproveCustomAlert deleteDao requestDeleteFiles called");
    [deleteDao requestDeleteFiles:selectedFileList];
    [self bringSubviewToFront:progress];
    [progress show:YES];
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
        [self pullData];
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
            if([rowItem isKindOfClass:[MetaFile class]]) {
                MetaFile *castedRow = (MetaFile *) rowItem;
                RevisitedPhotoCollCell *cell = [cv dequeueReusableCellWithReuseIdentifier:@"COLL_PHOTO_CELL" forIndexPath:indexPath];
                cell.delegate = self;
                [cell loadContent:castedRow isSelectible:self.isSelectible withImageWidth:imageWidth withGroupKey:sectionGroup.groupKey isSelected:[selectedFileList containsObject:castedRow.uuid]];
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

- (void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    //    RevisitedPhotoCollCell *cell = (RevisitedPhotoCollCell *) [collectionView cellForItemAtIndexPath:indexPath];
}

#pragma mark – UICollectionViewDelegateFlowLayout

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
        return CGSizeMake(self.frame.size.width, 40);
    }
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)theCollectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)theIndexPath {
    GroupPhotoSectionView *collFooterView = [theCollectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                                                                                  withReuseIdentifier:@"group_photo_header"
                                                                                         forIndexPath:theIndexPath];
    if(kind == UICollectionElementKindSectionHeader && initialLoadDone) {
        if(self.groups.count > theIndexPath.section) {
            FileInfoGroup *sectionGroup = [self.groups objectAtIndex:theIndexPath.section];
            
            [collFooterView loadSectionWithTitle:sectionGroup.customTitle];
            return collFooterView;
        }
        collFooterView.frame = CGRectZero;
        return collFooterView;
    }
    collFooterView.frame = CGRectZero;
    return collFooterView;
}

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

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

- (void) resizeCollViewHeightForFooterMenu {
    
    if (!imgFooterActionMenu.isHidden) {
        CGRect frame = collView.frame;
        frame.size = CGSizeMake(frame.size.width, collViewOriginalHeight - imgFooterActionMenu.frame.size.height);
        collView.frame = frame;
    }
    else if (imgFooterActionMenu.isHidden || imgFooterActionMenu == nil) {
        CGRect frame = collView.frame;
        frame.size = CGSizeMake(frame.size.width, collViewOriginalHeight);
        collView.frame = frame;
    }
}

@end
