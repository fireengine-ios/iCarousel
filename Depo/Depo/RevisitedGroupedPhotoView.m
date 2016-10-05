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

#define GROUP_PACKAGE_SIZE (IS_IPAD ? 60 : IS_IPHONE_6P_OR_HIGHER ? 60 : 48)
#define GROUP_IMG_COUNT_PER_ROW (IS_IPAD ? 6 : IS_IPHONE_6P_OR_HIGHER ? 6 : 4)

#define GROUP_INPROGRESS_KEY @"in_progress"

@interface RevisitedGroupedPhotoView() {
    int tableUpdateCounter;
    int listOffset;
    BOOL isLoading;
    int photoCount;
    int groupSequence;
    NSDateFormatter *dateCompareFormat;
    BOOL anyOngoingPresent;
    
    float yIndex;
}
@end

@implementation RevisitedGroupedPhotoView

@synthesize delegate;
@synthesize files;
@synthesize selectedFileList;
@synthesize refreshControl;
@synthesize fileScroll;
@synthesize readDao;
@synthesize deleteDao;
@synthesize albumAddPhotosDao;
@synthesize imgFooterActionMenu;
@synthesize isSelectible;
@synthesize progress;
@synthesize searchField;
@synthesize noItemView;

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
        
        dateCompareFormat = [[NSDateFormatter alloc] init];
        [dateCompareFormat setDateFormat:@"MMM yyyy"];
        
        files = [[NSMutableArray alloc] init];
        selectedFileList = [[NSMutableArray alloc] init];

        yIndex = 0;
        
        fileScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        fileScroll.backgroundColor = [UIColor clearColor];
        fileScroll.delegate = self;
        [self addSubview:fileScroll];
        
        UIView *tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 60)];
        searchField = [[MainSearchTextfield alloc] initWithFrame:CGRectMake(20, 10, self.frame.size.width - 40, 40)];
        searchField.delegate = self;
        searchField.returnKeyType = UIReturnKeySearch;
        searchField.userInteractionEnabled = NO;
        [tableHeaderView addSubview:searchField];
        [fileScroll addSubview:tableHeaderView];

        yIndex = 60;
        fileScroll.contentSize = CGSizeMake(fileScroll.frame.size.width, yIndex);

        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(searchTapped)];
        tapGestureRecognizer.numberOfTapsRequired = 1;
        tapGestureRecognizer.enabled = YES;
        [tableHeaderView addGestureRecognizer:tapGestureRecognizer];
        
        refreshControl = [[UIRefreshControl alloc] init];
        [refreshControl addTarget:self action:@selector(pullData) forControlEvents:UIControlEventValueChanged];
        [fileScroll addSubview:refreshControl];

        progress = [[MBProgressHUD alloc] initWithFrame:self.frame];
        progress.opacity = 0.4f;
        [self addSubview:progress];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(autoIterationFinished) name:AUTO_ITERATION_FINISHED_NOT_KEY object:nil];
    }
    return self;
}

- (void) pullData {
    listOffset = 0;
    groupSequence = 0;
    
    [files removeAllObjects];
    for(id row in [self.fileScroll subviews]) {
        if([row isKindOfClass:[GroupedView class]]) {
            [row removeFromSuperview];
        }
    }
    
    yIndex = 60;
    fileScroll.contentSize = CGSizeMake(fileScroll.frame.size.width, yIndex);

    [self addOngoingGroup];
    
    int packageSize = GROUP_PACKAGE_SIZE;
    if([[Util deviceType] isEqualToString:@"iPhone 6 Plus"] || [[Util deviceType] isEqualToString:@"iPhone 6S Plus"]) {
        packageSize = 60;
    }
    [readDao requestPhotosForPage:listOffset andSize:packageSize andSortType:SortTypeDateDesc];
    isLoading = YES;

    [self bringSubviewToFront:progress];
    [progress show:YES];
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

    GroupedView *alreadyPresentView = nil;
    for(id row in fileScroll.subviews) {
        if([row isKindOfClass:[GroupedView class]]) {
            GroupedView *castedView = (GroupedView *) row;
            if([castedView.group.groupKey isEqualToString:group.groupKey]) {
                alreadyPresentView = castedView;
                break;
            }
        }
    }
    
    int countPerRow = GROUP_IMG_COUNT_PER_ROW;
    if([[Util deviceType] isEqualToString:@"iPhone 6 Plus"] || [[Util deviceType] isEqualToString:@"iPhone 6S Plus"]) {
        countPerRow = 5;
    }
    int boxWidth = (int) fileScroll.frame.size.width/countPerRow;
    float imageContainerHeight = 60;
    
    if(alreadyPresentView) {
        float currentHeight = alreadyPresentView.frame.size.height;
        int newFileCount = (int)[alreadyPresentView.group.fileInfo count] + (int)group.fileInfo.count;
        imageContainerHeight += floorf(newFileCount/countPerRow)*boxWidth;
        if(group.fileInfo.count%countPerRow > 0) {
            imageContainerHeight += boxWidth;
        }
        [alreadyPresentView loadMoreImages:group.fileInfo];
        alreadyPresentView.frame = CGRectMake(alreadyPresentView.frame.origin.x, alreadyPresentView.frame.origin.y, alreadyPresentView.frame.size.width, imageContainerHeight);
        
        float heightDiff = imageContainerHeight - currentHeight;
        fileScroll.contentSize = CGSizeMake(fileScroll.frame.size.width, fileScroll.contentSize.height + heightDiff);
        
        yIndex += heightDiff;
        
    } else {
        imageContainerHeight += floorf(group.fileInfo.count/countPerRow)*boxWidth;
        if(group.fileInfo.count%countPerRow > 0) {
            imageContainerHeight += boxWidth;
        }

        GroupedView *groupedView = [[GroupedView alloc] initWithFrame:CGRectMake(0, yIndex, fileScroll.frame.size.width, imageContainerHeight) withGroup:group isSelectible:isSelectible withImageWidth:boxWidth withImageCountPerRow:countPerRow];
        groupedView.delegate = self;
        [fileScroll addSubview:groupedView];
        
        fileScroll.contentSize = CGSizeMake(fileScroll.frame.size.width, fileScroll.contentSize.height + imageContainerHeight);
        
        yIndex += imageContainerHeight;
    }
    [self neutralizeSearchBar];
}

- (void) deleteSuccessCallback {
    [delegate revisitedGroupedPhotoDidFinishDeleting];
//    [self proceedSuccessForProgressViewWithAddButtonKey:@"PhotoTab"];
}

- (void) deleteFailCallback:(NSString *) errorMessage {
    [progress hide:YES];
//    [self proceedFailureForProgressViewWithAddButtonKey:@"PhotoTab"];
    [delegate revisitedGroupedPhotoDidFailDeletingWithError:errorMessage];
}

- (void) setToSelectible {
    isSelectible = YES;
    [refreshControl setEnabled:NO];
    [selectedFileList removeAllObjects];

    for(id row in fileScroll.subviews) {
        if([row isKindOfClass:[GroupedView class]]) {
            GroupedView *castedView = (GroupedView *) row;
            [castedView setToSelectible];
        }
    }
}

- (void) setToUnselectiblePriorToRefresh {
    isSelectible = NO;
    [refreshControl setEnabled:YES];
    [selectedFileList removeAllObjects];
    
    if(imgFooterActionMenu) {
        [imgFooterActionMenu removeFromSuperview];
        imgFooterActionMenu = nil;
    }
}

- (void) setToUnselectible {
    isSelectible = NO;
    [refreshControl setEnabled:YES];
    [selectedFileList removeAllObjects];
    
    if(imgFooterActionMenu) {
        [imgFooterActionMenu removeFromSuperview];
        imgFooterActionMenu = nil;
    }

    for(id row in fileScroll.subviews) {
        if([row isKindOfClass:[GroupedView class]]) {
            GroupedView *castedView = (GroupedView *) row;
            [castedView setToUnselectible];
        }
    }
}

- (void) readSuccessCallback:(NSArray *) fileList {
    [progress hide:YES];
    if([fileList count] > 0) {
        [files addObjectsFromArray:fileList];
        
        NSMutableDictionary *groupDict = [[NSMutableDictionary alloc] init];
        for(MetaFile *row in fileList) {
            if(row.detail.fileDate) {
                NSString *dateStr = [dateCompareFormat stringFromDate:row.detail.fileDate];
                if([[groupDict allKeys] count] == 0) {
                    FileInfoGroup *newGroup = [[FileInfoGroup alloc] init];
                    newGroup.customTitle = dateStr;
                    newGroup.locationInfo = @"";
                    newGroup.fileInfo = [[NSMutableArray alloc] init];
                    [newGroup.fileInfo addObject:row];
                    newGroup.sequence = groupSequence;
                    newGroup.groupKey = dateStr;
                    [groupDict setObject:newGroup forKey:dateStr];
                    
                    groupSequence ++;
                } else {
                    FileInfoGroup *currentGroup = [groupDict objectForKey:dateStr];
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
                        [groupDict setObject:newGroup forKey:dateStr];
                        groupSequence ++;
                    }
                }
            }
        }

        NSArray *groups = [groupDict allValues];
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"sequence" ascending:YES];
        NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
        groups = [groups sortedArrayUsingDescriptors:sortDescriptors];
     
        for(FileInfoGroup *row in groups) {
            [self addOrUpdateGroup:row];
        }
    }
    
    isLoading = NO;
    [refreshControl endRefreshing];
    
    if ([files count] == 0 && !anyOngoingPresent) {
        if (noItemView == nil) {
            noItemView = [[NoItemView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, fileScroll.frame.size.height) imageName:@"no_photo_icon" titleText:NSLocalizedString(@"EmptyPhotosVideosTitle", @"") descriptionText:NSLocalizedString(@"EmptyPhotosVideosDescription", @"")];
            [fileScroll addSubview:noItemView];
        }
    } else if (noItemView != nil) {
        [noItemView removeFromSuperview];
    }
}

- (void) readFailCallback:(NSString *) errorMessage {
    [progress hide:YES];
    isLoading = NO;
    [refreshControl endRefreshing];
}

/*
- (void) photoListSuccessCallback:(NSArray *) files {
    [self hideLoading];
    
    int counter = (int)[photoList count];
    
    int imagePerLine = 3;
    
    float imageWidth = 100;
    float interImageMargin = 5;
    
    if(IS_IPAD) {
        imagePerLine = 5;
        imageWidth = (self.view.frame.size.width - interImageMargin*(imagePerLine+1))/imagePerLine;
    }
    
    float imageTotalWidth = imageWidth + interImageMargin;
    
    for(MetaFile *row in files) {
        CGRect imgRect = CGRectMake(interImageMargin + (counter%imagePerLine * imageTotalWidth), 15 + ((int)floor(counter/imagePerLine)*imageTotalWidth), imageWidth, imageWidth);
        SquareImageView *imgView = [[SquareImageView alloc] initWithFrame:imgRect withFile:row withSelectibleStatus:isSelectible];
        imgView.delegate = self;
        [photosScroll addSubview:imgView];
        counter ++;
    }
    float contentSizeHeight = ((int)ceil(counter/imagePerLine)+1)*imageTotalWidth + 20;
    if(contentSizeHeight <= photosScroll.frame.size.height) {
        contentSizeHeight = photosScroll.frame.size.height + 1;
    }
    photosScroll.contentSize = CGSizeMake(photosScroll.frame.size.width, contentSizeHeight);
    [photoList addObjectsFromArray:files];
    if (photoList.count == 0) {
        if (noItemView == nil)
            noItemView = [[NoItemView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, photosScroll.frame.size.height) imageName:@"no_photo_icon" titleText:NSLocalizedString(@"EmptyPhotosVideosTitle", @"") descriptionText:NSLocalizedString(@"EmptyPhotosVideosDescription", @"")];
        [photosScroll addSubview:noItemView];
    }
    else if (noItemView != nil)
        [noItemView removeFromSuperview];
    if(refreshControlPhotos) {
        [refreshControlPhotos endRefreshing];
    }
    if(refreshControlAlbums) {
        [refreshControlAlbums endRefreshing];
    }
    isLoading = NO;
}

- (void) alignPhotosScrollPostDelete {
    NSMutableArray *filteredFiles = [[NSMutableArray alloc] init];
    NSMutableArray *ongoingFiles = [[NSMutableArray alloc] init];
    for(id row in photoList) {
        if([row isKindOfClass:[MetaFile class]]) {
            MetaFile *file = (MetaFile *) row;
            if(![selectedFileList containsObject:file.uuid]) {
                [filteredFiles addObject:row];
            }
        } else {
            [ongoingFiles addObject:row];
        }
    }
    
    for(UIView *subView in photosScroll.subviews) {
        if([subView isKindOfClass:[SquareImageView class]]) {
            if(((SquareImageView *) subView).uploadRef == nil) {
                [subView removeFromSuperview];
            }
        }
    }
    
    int counter = (int)[ongoingFiles count];
    
    int imagePerLine = 3;
    
    float imageWidth = 100;
    float interImageMargin = 5;
    
    if(IS_IPAD) {
        imagePerLine = 5;
        imageWidth = (self.view.frame.size.width - interImageMargin*(imagePerLine+1))/imagePerLine;
    }
    
    float imageTotalWidth = imageWidth + interImageMargin;
    
    for(MetaFile *row in filteredFiles) {
        CGRect imgRect = CGRectMake(interImageMargin + (counter%imagePerLine * imageTotalWidth), 15 + ((int)floor(counter/imagePerLine)*imageTotalWidth), imageWidth, imageWidth);
        SquareImageView *imgView = [[SquareImageView alloc] initWithFrame:imgRect withFile:row withSelectibleStatus:isSelectible];
        imgView.delegate = self;
        [photosScroll addSubview:imgView];
        counter ++;
    }
    float contentSizeHeight = ((int)ceil(counter/imagePerLine)+1)*imageTotalWidth + 20;
    if(contentSizeHeight <= photosScroll.frame.size.height) {
        contentSizeHeight = photosScroll.frame.size.height + 1;
    }
    photosScroll.contentSize = CGSizeMake(photosScroll.frame.size.width, contentSizeHeight);
    
    self.photoList = ongoingFiles;
    [photoList addObjectsFromArray:filteredFiles];
    
    if (photoList.count == 0) {
        if (noItemView == nil)
            noItemView = [[NoItemView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, photosScroll.frame.size.height) imageName:@"no_photo_icon" titleText:NSLocalizedString(@"EmptyPhotosVideosTitle", @"") descriptionText:NSLocalizedString(@"EmptyPhotosVideosDescription", @"")];
        [photosScroll addSubview:noItemView];
    }
}

- (void) photoListFailCallback:(NSString *) errorMessage {
    [self hideLoading];
    [self showErrorAlertWithMessage:errorMessage];
}
*/

- (void) scrollViewDidScroll:(UIScrollView *)scrollView {

    if(!isLoading) {
        CGFloat currentOffset = fileScroll.contentOffset.y;
        CGFloat maximumOffset = fileScroll.contentSize.height - fileScroll.frame.size.height;
        
        if (maximumOffset > 0.0f && currentOffset - maximumOffset >= 0.0f) {
            isLoading = YES;
            [self dynamicallyLoadNextPage];
        }
    }
}

- (void) dynamicallyLoadNextPage {
    listOffset ++;
    int packageSize = GROUP_PACKAGE_SIZE;
    if([[Util deviceType] isEqualToString:@"iPhone 6 Plus"] || [[Util deviceType] isEqualToString:@"iPhone 6S Plus"]) {
        packageSize = 60;
    }
    [readDao requestPhotosForPage:listOffset andSize:packageSize andSortType:SortTypeDateDesc];
}

- (FileInfoGroup *) groupByKey:(NSString *) groupKey {
    for(id row in [fileScroll subviews]) {
        if([row isKindOfClass:[GroupedView class]]) {
            GroupedView *castedView = (GroupedView *) row;
            if([castedView.group.groupKey isEqualToString:groupKey]) {
                return castedView.group;
            }
        }
    }
    return nil;
}

- (void) groupedViewImageWasSelectedForFile:(MetaFile *) fileSelected forGroupWithKey:(NSString *) groupKey {
    NSArray *listToPass = @[fileSelected];
    FileInfoGroup *group = [self groupByKey:groupKey];
    if(group != nil) {
        listToPass = group.fileInfo;
    }
    [delegate revisitedGroupedPhotoDidSelectFile:fileSelected withList:listToPass];
}

- (void) groupedViewImageWasMarkedForFile:(MetaFile *) fileSelected {
    if(fileSelected.uuid) {
        if(![selectedFileList containsObject:fileSelected.uuid]) {
            [selectedFileList addObject:fileSelected.uuid];
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

- (void) groupedViewImageWasUnmarkedForFile:(MetaFile *) fileSelected {
    if([selectedFileList containsObject:fileSelected.uuid]) {
        [selectedFileList removeObject:fileSelected.uuid];
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

- (void) showImgFooterMenu {
    if(imgFooterActionMenu) {
        imgFooterActionMenu.hidden = NO;
    } else {
        imgFooterActionMenu = [[FooterActionsMenuView alloc] initWithFrame:CGRectMake(0, self.frame.size.height - 60, self.frame.size.width, 60) shouldShowShare:YES shouldShowMove:YES shouldShowDelete:YES shouldShowPrint:YES];
        imgFooterActionMenu.delegate = self;
        [self addSubview:imgFooterActionMenu];
    }
}

- (void) hideImgFooterMenu {
    imgFooterActionMenu.hidden = YES;
}

- (void) groupedViewImageUploadFinishedForFile:(NSString *) fileSelectedUuid {
}

- (void) groupedViewImageWasLongPressedForFile:(MetaFile *) fileSelected {
    [self setToSelectible];
    [delegate revisitedGroupedPhotoDidChangeToSelectState];
}

- (void) groupedViewImageUploadQuotaError:(MetaFile *) fileSelected {
}

- (void) groupedViewImageUploadLoginError:(MetaFile *) fileSelected {
}

- (void) groupedViewImageWasSelectedForView:(SquareImageView *) ref {
}

- (void) shouldContinueDelete {
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
        [deleteDao requestDeleteFiles:selectedFileList];
        [self bringSubviewToFront:progress];
        [progress show:YES];
    }
}

- (void) footerActionMenuDidSelectDelete:(FooterActionsMenuView *) menu {
    if([CacheUtil showConfirmDeletePageFlag]) {
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
    [APPDELEGATE.base showPhotoAlbums];
}

- (void) footerActionMenuDidSelectShare:(FooterActionsMenuView *) menu {
    [APPDELEGATE.base triggerShareForFiles:selectedFileList];
}

- (void) footerActionMenuDidSelectPrint:(FooterActionsMenuView *)menu {
    [delegate revisitedGroupedPhotoShouldPrintWithFileList:selectedFileList];
}

- (void) destinationAlbumChosenWithUuid:(NSString *) chosenAlbumUuid {
    [albumAddPhotosDao requestAddPhotos:selectedFileList toAlbum:chosenAlbumUuid];
    [self bringSubviewToFront:progress];
    [progress show:YES];
//TODO    [self pushProgressViewWithProcessMessage:NSLocalizedString(@"AlbumMovePhotoProgressMessage", @"") andSuccessMessage:NSLocalizedString(@"MoveSuccessMessageNew", @"") andFailMessage:NSLocalizedString(@"AlbumMovePhotoFailMessage", @"")];
}

- (void) photosAddedSuccessCallback {
    [progress hide:YES];
    [delegate revisitedGroupedPhotoDidFinishMoving];
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
    [deleteDao requestDeleteFiles:selectedFileList];
    [self bringSubviewToFront:progress];
    [progress show:YES];
}

- (void) cancelRequests {
    [readDao cancelRequest];
    readDao = nil;
    
    [deleteDao cancelRequest];
    deleteDao = nil;
    
    [albumAddPhotosDao cancelRequest];
    albumAddPhotosDao = nil;
}

- (void) neutralizeSearchBar {
    if(fileScroll.contentOffset.y < 60) {
        fileScroll.contentOffset = CGPointMake(0, 60);
    }
}

- (void) autoIterationFinished {
    IGLog(@"At RevisitedGroupedPhotoView autoIterationFinished");
    if([[UploadQueue sharedInstance] remainingCount] > 0) {
        IGLog(@"At RevisitedGroupedPhotoView autoIterationFinished pullData will be called");
        [self pullData];
    }
}

@end
