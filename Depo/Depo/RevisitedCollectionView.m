//
//  RevisitedCollectionView.m
//  Depo
//
//  Created by Mahir Tarlan on 09/08/16.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import "RevisitedCollectionView.h"
#import "Util.h"
#import "AppDelegate.h"
#import "AppSession.h"
#import "CacheUtil.h"

#define COLL_COUNT_FOR_PAGE 10

@interface RevisitedCollectionView() {
    int tableUpdateCounter;
    int listOffset;
    BOOL isLoading;
    int photoCount;
}
@end

@implementation RevisitedCollectionView

@synthesize delegate;
@synthesize collections;
@synthesize selectedFileList;
@synthesize refreshControl;
@synthesize collTable;
@synthesize collDao;
@synthesize deleteDao;
@synthesize imgFooterActionMenu;
@synthesize level;
@synthesize collDate;
@synthesize isSelectible;
@synthesize progress;

- (id) initWithFrame:(CGRect)frame {
    if(self = [super initWithFrame:frame]) {
        self.backgroundColor = [Util UIColorForHexColor:@"FFFFFF"];

        collDao = [[SearchByGroupDao alloc] init];
        collDao.delegate = self;
        collDao.successMethod = @selector(groupSuccessCallback:);
        collDao.failMethod = @selector(groupFailCallback:);

        deleteDao = [[DeleteDao alloc] init];
        deleteDao.delegate = self;
        deleteDao.successMethod = @selector(deleteSuccessCallback);
        deleteDao.failMethod = @selector(deleteFailCallback:);

        tableUpdateCounter = 0;
        listOffset = 0;
        photoCount = 0;
        level = ImageGroupLevelYear;
        
        collections = [[NSMutableArray alloc] init];
        selectedFileList = [[NSMutableArray alloc] init];
        
        collTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height) style:UITableViewStylePlain];
        collTable.backgroundColor = [UIColor clearColor];
        collTable.backgroundView = nil;
        collTable.delegate = self;
        collTable.dataSource = self;
        collTable.separatorStyle = UITableViewCellSeparatorStyleNone;
        collTable.isAccessibilityElement = YES;
        collTable.accessibilityIdentifier = @"collTableRevisitedCollection";
        [self addSubview:collTable];
        
        refreshControl = [[UIRefreshControl alloc] init];
        [refreshControl addTarget:self action:@selector(pullData) forControlEvents:UIControlEventValueChanged];
        [collTable addSubview:refreshControl];

        progress = [[MBProgressHUD alloc] initWithFrame:self.frame];
        progress.opacity = 0.4f;
        [self addSubview:progress];
    }
    return self;
}

- (void) pullData {
    listOffset = 0;
    tableUpdateCounter ++;
    
    [self.collections removeAllObjects];
    
    int groupSize = 8;
    int pageSize = self.level == ImageGroupLevelDay ? 40 : (groupSize*COLL_COUNT_FOR_PAGE);
    [collDao requestImagesByGroupByPage:listOffset bySize:pageSize byLevel:self.level byGroupDate:collDate byGroupSize:[NSNumber numberWithInt:groupSize] bySort:APPDELEGATE.session.sortType];
    isLoading = YES;

    [self bringSubviewToFront:progress];
    [progress show:YES];
}

- (void) deleteSuccessCallback {
    [delegate revisitedCollectionDidFinishDeleting];
    //    [self proceedSuccessForProgressViewWithAddButtonKey:@"PhotoTab"];
}

- (void) deleteFailCallback:(NSString *) errorMessage {
    //    [self proceedFailureForProgressViewWithAddButtonKey:@"PhotoTab"];
    [delegate revisitedCollectionDidFailDeletingWithError:errorMessage];
}

- (void) setToSelectible {
    isSelectible = YES;
    [refreshControl setEnabled:NO];
    [selectedFileList removeAllObjects];
    
//    tableUpdateCounter ++;
//    [collTable reloadData];
}

- (void) setToUnselectible {
    isSelectible = NO;
    [refreshControl setEnabled:YES];
    [selectedFileList removeAllObjects];
    
    if(imgFooterActionMenu) {
        [imgFooterActionMenu removeFromSuperview];
        imgFooterActionMenu = nil;
    }

    tableUpdateCounter ++;
    [collTable reloadData];
}

- (void) groupSuccessCallback:(NSArray *) fileGroups {
    [progress hide:YES];
    [self.collections addObjectsFromArray:fileGroups];
    
    isLoading = NO;
    [refreshControl endRefreshing];
    [collTable reloadData];
}

- (void) groupFailCallback:(NSString *) errorMessage {
    [progress hide:YES];
    isLoading = NO;
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(collections.count > 0) {
        FileInfoGroup *group = [collections objectAtIndex:indexPath.row];

        float boxWidth = collTable.frame.size.width/4;
        int boxCountPerRow = 4;
        
        float imageContainerHeight = 60;
        if(self.level == ImageGroupLevelYear || self.level == ImageGroupLevelMonth) {
            if(group.fileInfo.count >= 4) {
                imageContainerHeight += boxWidth*2;
            } else {
                imageContainerHeight += boxWidth;
            }
        } else {
            imageContainerHeight += floorf(group.fileInfo.count/boxCountPerRow)*boxWidth;
            if(group.fileInfo.count%boxCountPerRow > 0) {
                imageContainerHeight += boxWidth;
            }
        }
        return imageContainerHeight;
    } else {
        return self.frame.size.width/2;
    }
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (collections.count == 0)
        return isLoading ? 0 : 1;
    return [collections count];
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = [NSString stringWithFormat:@"%@_%d_%d", @"COLL_CELL",  (int)indexPath.row, tableUpdateCounter];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(cell == nil) {
        if(collections.count > 0) {
            float boxWidth = collTable.frame.size.width/4;
            int boxCountPerRow = 4;
            FileInfoGroup *group = [collections objectAtIndex:indexPath.row];
            cell = [[CollCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier withGroup:group withLevel:self.level isSelectible:isSelectible withImageWidth:boxWidth withImageCountPerRow:boxCountPerRow];
            ((CollCell *)cell).delegate = self;
        } else {
            cell = [[NoItemCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier imageName:@"no_photo_icon" titleText:NSLocalizedString(@"EmptyPhotosVideosTitle", @"") descriptionText:NSLocalizedString(@"EmptyPhotosVideosDescription", @"")];
        }
    }
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if([collections count] > 0) {
        if(level == ImageGroupLevelYear || level == ImageGroupLevelMonth) {
            //ImageGroupLevel nextLevel = level == ImageGroupLevelYear ? ImageGroupLevelMonth : ImageGroupLevelDay;
            //FileInfoGroup *selectedGroup = [collections objectAtIndex:indexPath.row];
            /* TODO
            GroupedPhotosAndVideosController *nextLevelController = [[GroupedPhotosAndVideosController alloc] initWithLevel:nextLevel withGroupDate:selectedGroup.rangeStart];
            nextLevelController.nav = self.nav;
            [self.nav pushViewController:nextLevelController animated:NO];
             */
        }
    }
}

- (void) scrollViewDidScroll:(UIScrollView *)scrollView {
    if(!isLoading) {
        CGFloat currentOffset = collTable.contentOffset.y;
        CGFloat maximumOffset = collTable.contentSize.height - collTable.frame.size.height;
        
        if (maximumOffset > 0.0f && currentOffset - maximumOffset >= 0.0f) {
            isLoading = YES;
            [self dynamicallyLoadNextPage];
        }
    }
}

- (void) dynamicallyLoadNextPage {
    listOffset ++;
    int groupSize = 8;
    int pageSize = self.level == ImageGroupLevelDay ? 40 : (groupSize*COLL_COUNT_FOR_PAGE);
    [collDao requestImagesByGroupByPage:listOffset bySize:pageSize byLevel:self.level byGroupDate:self.collDate byGroupSize:[NSNumber numberWithInt:groupSize] bySort:APPDELEGATE.session.sortType];
}

- (void) collCellImageWasSelectedForFile:(MetaFile *) fileSelected forGroupWithKey:(NSString *) groupKey {
    [delegate revisitedCollectionDidSelectFile:fileSelected withList:@[fileSelected]];
}

- (void) collCellImageWasMarkedForFile:(MetaFile *) fileSelected {
    if(fileSelected.uuid) {
        if(![selectedFileList containsObject:fileSelected.uuid]) {
            [selectedFileList addObject:fileSelected.uuid];
        }
    }
    if([selectedFileList count] > 0) {
        [self showImgFooterMenu];
        [delegate revisitedCollectionChangeTitleTo:[NSString stringWithFormat:NSLocalizedString(@"FilesSelectedTitle", @""), [selectedFileList count]]];
    } else {
        [self hideImgFooterMenu];
        [delegate revisitedCollectionChangeTitleTo:NSLocalizedString(@"SelectFilesTitle", @"")];
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

- (void) collCellImageWasUnmarkedForFile:(MetaFile *) fileSelected {
    if([selectedFileList containsObject:fileSelected.uuid]) {
        [selectedFileList removeObject:fileSelected.uuid];
    }
    if([selectedFileList count] > 0) {
        [self showImgFooterMenu];
        [delegate revisitedCollectionChangeTitleTo:[NSString stringWithFormat:NSLocalizedString(@"FilesSelectedTitle", @""), [selectedFileList count]]];
    } else {
        [self hideImgFooterMenu];
        [delegate revisitedCollectionChangeTitleTo:NSLocalizedString(@"SelectFilesTitle", @"")];
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

- (void) collCellImageUploadFinishedForFile:(NSString *) fileSelectedUuid {
}

- (void) collCellImageWasLongPressedForFile:(MetaFile *) fileSelected {
    [self setToSelectible];
    [delegate revisitedCollectionDidChangeToSelectState];
}

- (void) collCellImageUploadQuotaError:(MetaFile *) fileSelected {
}

- (void) collCellImageUploadLoginError:(MetaFile *) fileSelected {
}

- (void) collCellImageWasSelectedForView:(SquareImageView *) ref {
}

- (void) collCellMoreSelectedForDate:(NSString *) rangeStart {
    self.collDate = rangeStart;
    self.level = (self.level == ImageGroupLevelYear) ? ImageGroupLevelMonth : ImageGroupLevelDay;
    [self pullData];
}

- (void) footerActionMenuDidSelectDelete:(FooterActionsMenuView *) menu {
    if([CacheUtil showConfirmDeletePageFlag]) {
        [deleteDao requestDeleteFiles:selectedFileList];
        [self bringSubviewToFront:progress];
        [progress show:YES];
        
        //        [self pushProgressViewWithProcessMessage:NSLocalizedString(@"DeleteProgressMessage", @"") andSuccessMessage:NSLocalizedString(@"DeleteSuccessMessage", @"") andFailMessage:NSLocalizedString(@"DeleteFailMessage", @"")];
    } else {
        [delegate revisitedCollectionShouldConfirmForDeleting];
    }
}

- (void) footerActionMenuDidSelectMove:(FooterActionsMenuView *) menu {
}

- (void) footerActionMenuDidSelectShare:(FooterActionsMenuView *) menu {
}

- (void) footerActionMenuDidSelectPrint:(FooterActionsMenuView *)menu {
}

- (void) shouldContinueDelete {
    [deleteDao requestDeleteFiles:selectedFileList];
    [self bringSubviewToFront:progress];
    [progress show:YES];
}

@end
