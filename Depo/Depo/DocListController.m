//
//  DocListController.m
//  Depo
//
//  Created by Mahir on 4.11.2014.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "DocListController.h"
#import "AppDelegate.h"
#import "AppSession.h"
#import "FolderEmptyCell.h"
#import "SimpleDocCell.h"
#import "FileDetailInWebViewController.h"
#import "PreviewUnavailableController.h"
#import "BaseViewController.h"
#import "NoItemCell.h"

@interface DocListController ()

@end

@implementation DocListController

@synthesize docTable;
@synthesize refreshControl;
@synthesize docList;
@synthesize selectedDocList;
@synthesize footerActionMenu;

- (id) init {
    if(self = [super init]) {
        self.view.backgroundColor = [UIColor whiteColor];
        self.title = NSLocalizedString(@"DocTitle", @"");
        
        listOffset = 0;
        
        shareDao = [[ShareLinkDao alloc] init];
        shareDao.delegate = self;
        shareDao.successMethod = @selector(shareSuccessCallback:);
        shareDao.failMethod = @selector(shareFailCallback:);
        
        elasticSearchDao = [[ElasticSearchDao alloc] init];
        elasticSearchDao.delegate = self;
        elasticSearchDao.successMethod = @selector(docListSuccessCallback:);
        elasticSearchDao.failMethod = @selector(docListFailCallback:);
        
        favoriteDao = [[FavoriteDao alloc] init];
        favoriteDao.delegate = self;
        favoriteDao.successMethod = @selector(favSuccessCallback:);
        favoriteDao.failMethod = @selector(favFailCallback:);
        
        moveDao = [[MoveDao alloc] init];
        moveDao.delegate = self;
        moveDao.successMethod = @selector(moveSuccessCallback);
        moveDao.failMethod = @selector(moveFailCallback:);
        
        deleteDao = [[DeleteDao alloc] init];
        deleteDao.delegate = self;
        deleteDao.successMethod = @selector(deleteSuccessCallback);
        deleteDao.failMethod = @selector(deleteFailCallback:);

        selectedDocList = [[NSMutableArray alloc] init];
        
        docTable = [[UITableView alloc] initWithFrame:CGRectMake(0, self.topIndex, self.view.frame.size.width, self.view.frame.size.height - self.bottomIndex) style:UITableViewStylePlain];
        docTable.delegate = self;
        docTable.dataSource = self;
        docTable.backgroundColor = [UIColor clearColor];
        docTable.backgroundView = nil;
        docTable.separatorStyle = UITableViewCellSeparatorStyleNone;
        docTable.contentInset = UIEdgeInsetsMake(0, 0, 50, 0);
        [self.view addSubview:docTable];

        UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(shouldMoveToSelectionState:)];
        longPressGesture.minimumPressDuration = 1.0;
        [docTable addGestureRecognizer:longPressGesture];

        refreshControl = [[UIRefreshControl alloc] init];
        [refreshControl addTarget:self action:@selector(triggerRefresh) forControlEvents:UIControlEventValueChanged];
        [docTable addSubview:refreshControl];
        
        [elasticSearchDao requestDocForPage:listOffset andSize:21 andSortType:APPDELEGATE.session.sortType];
        [self showLoading];
    }
    return self;
}

- (void) shouldMoveToSelectionState:(UILongPressGestureRecognizer *)gestureRecognizer {
    if(!isSelectible) {
        if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
            CGPoint p = [gestureRecognizer locationInView:docTable];
            NSIndexPath *indexPath = [docTable indexPathForRowAtPoint:p];
            if (indexPath != nil) {
                [self changeToSelectedStatus];
            }
        }
    }
}

- (void) triggerRefresh {
    listOffset = 0;
    [docList removeAllObjects];
    [elasticSearchDao requestDocForPage:listOffset andSize:21 andSortType:APPDELEGATE.session.sortType];
}

- (void) docListSuccessCallback:(NSArray *) files {
    [self hideLoading];
    
    if(refreshControl) {
        [refreshControl endRefreshing];
    }
    isLoading = NO;
    
    if(docList == nil) {
        docList = [[NSMutableArray alloc] init];
    }
    [docList addObjectsFromArray:[self filterFilesFromList:files]];
    
    self.tableUpdateCounter ++;
    [docTable reloadData];
}

- (void) docListFailCallback:(NSString *) errorMessage {
    [self hideLoading];
    [self showErrorAlertWithMessage:errorMessage];
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(docList == nil) {
        return 0;
    } else if([docList count] == 0) {
        return 1;
    } else {
        return [docList count];
    }
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(docList == nil || [docList count] == 0) {
        if(IS_IPAD) {
            return 420;
        } else {
            return 320;
        }
    } else {
        if(IS_IPAD) {
            return 102;
        } else {
            return 68;
        }
    }
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = [NSString stringWithFormat:@"DOC_CELL_%d_%d", (int)indexPath.row, self.tableUpdateCounter];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(!cell) {
        if(docList == nil || [docList count] == 0) {
            cell = [[NoItemCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier imageName:@"empty_state_icon" titleText:NSLocalizedString(@"EmptyDocumentsTitle", @"") descriptionText:@""];
        } else {
            MetaFile *fileAtIndex = [docList objectAtIndex:indexPath.row];
            cell = [[SimpleDocCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier withFileFolder:fileAtIndex isSelectible:isSelectible];
            ((AbstractFileFolderCell *) cell).delegate = self;
        }
    }
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(docList == nil || [docList count] == 0) {
        return;
    }

    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if(isSelectible) {
        if([cell isKindOfClass:[AbstractFileFolderCell class]]) {
            AbstractFileFolderCell *fileFolderCell = (AbstractFileFolderCell *) cell;
            [fileFolderCell triggerFileSelectDeselect];
        }
        return;
    }
    
    if([cell isKindOfClass:[FolderEmptyCell class]]) {
        return;
    }
    if([cell isKindOfClass:[AbstractFileFolderCell class]]) {
        AbstractFileFolderCell *fileFolderCell = (AbstractFileFolderCell *) cell;
        if(fileFolderCell.menuActive) {
            return;
        }
    }
    
    MetaFile *fileAtIndex = [docList objectAtIndex:indexPath.row];
    if([AppUtil isMetaFileDoc:fileAtIndex]){
        FileDetailInWebViewController *detail = [[FileDetailInWebViewController alloc] initWithFile:fileAtIndex];
        detail.nav = self.nav;
        [self.nav pushViewController:detail animated:NO];
    } else {
        PreviewUnavailableController *detail = [[PreviewUnavailableController alloc] initWithFile:fileAtIndex];
        detail.nav = self.nav;
        [self.nav pushViewController:detail animated:NO];
    }
}

- (void) scrollViewDidScroll:(UIScrollView *)scrollView {
    if(!isLoading) {
        CGFloat currentOffset = docTable.contentOffset.y;
        CGFloat maximumOffset = docTable.contentSize.height - docTable.frame.size.height;
        
        if (currentOffset - maximumOffset >= 0.0) {
            isLoading = YES;
            [self dynamicallyLoadNextPage];
        }
    }
}

- (void) dynamicallyLoadNextPage {
    listOffset ++;
    [elasticSearchDao requestDocForPage:listOffset andSize:21 andSortType:APPDELEGATE.session.sortType];
}

#pragma mark AbstractFileFolderDelegate methods

- (void) fileFolderCellShouldFavForFile:(MetaFile *)fileSelected {
    [favoriteDao requestMetadataForFiles:@[fileSelected.uuid] shouldFavorite:YES];
    [self pushProgressViewWithProcessMessage:NSLocalizedString(@"FavAddProgressMessage", @"") andSuccessMessage:NSLocalizedString(@"FavAddSuccessMessage", @"") andFailMessage:NSLocalizedString(@"FavAddFailMessage", @"")];
}

- (void) fileFolderCellShouldUnfavForFile:(MetaFile *)fileSelected {
    [favoriteDao requestMetadataForFiles:@[fileSelected.uuid] shouldFavorite:NO];
    [self pushProgressViewWithProcessMessage:NSLocalizedString(@"UnfavProgressMessage", @"") andSuccessMessage:NSLocalizedString(@"UnfavSuccessMessage", @"") andFailMessage:NSLocalizedString(@"UnfavFailMessage", @"")];
}

- (void) fileFolderCellShouldDeleteForFile:(MetaFile *)fileSelected {
    if([CacheUtil showConfirmDeletePageFlag]) {
        [deleteDao requestDeleteFiles:@[fileSelected.uuid]];
        [self pushProgressViewWithProcessMessage:NSLocalizedString(@"DeleteProgressMessage", @"") andSuccessMessage:NSLocalizedString(@"DeleteSuccessMessage", @"") andFailMessage:NSLocalizedString(@"DeleteFailMessage", @"")];
    } else {
        fileSelectedRef = fileSelected;
        self.deleteType = DeleteTypeSwipeMenu;
        [MoreMenuView presentConfirmDeleteFromController:self.nav delegateOwner:self];
    }
}

- (void) fileFolderCellShouldShareForFile:(MetaFile *)fileSelected {
    [self triggerShareForFiles:@[fileSelected.uuid]];
    //[APPDELEGATE.base triggerShareForFiles:@[fileSelected.uuid]];
}

- (void) fileFolderCellShouldMoveForFile:(MetaFile *)fileSelected {
    selectedDocList = [[NSMutableArray alloc] initWithObjects:fileSelected.uuid, nil];
    [MoreMenuView presentMoveFoldersListFromController:self.nav delegateOwner:self];
}

#pragma mark - Share

- (void) triggerShareForFiles:(NSArray *) fileUuidList {
    [shareDao requestLinkForFiles:fileUuidList];
    [self showLoading];
}

#pragma mark ShareLinkDao Delegate Methods
- (void) shareSuccessCallback:(NSString *) linkToShare {
    [self hideLoading];
    NSArray *activityItems = [NSArray arrayWithObjects:linkToShare, nil];
    
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
    [activityViewController setValue:NSLocalizedString(@"AppTitleRef", @"") forKeyPath:@"subject"];
    activityViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    
    //    activityViewController.excludedActivityTypes = @[UIActivityTypePrint, UIActivityTypeAssignToContact, UIActivityTypeSaveToCameraRoll];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [self presentViewController:activityViewController animated:YES completion:nil];
    } else {
        UIPopoverController *popup = [[UIPopoverController alloc] initWithContentViewController:activityViewController];
        [popup presentPopoverFromRect:CGRectMake(self.view.frame.size.width-240, self.view.frame.size.height-40, 240, 300)inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
}

- (void) shareFailCallback:(NSString *) errorMessage {
    [self hideLoading];
}

- (void) fileFolderCellDidSelectFile:(MetaFile *)fileSelected {
    if(![selectedDocList containsObject:fileSelected.uuid]) {
        [selectedDocList addObject:fileSelected.uuid];
    }
    if([selectedDocList count] > 0) {
        [self showFooterMenu];
        self.title = [NSString stringWithFormat:NSLocalizedString(@"FilesSelectedTitle", @""), [selectedDocList count]];
    } else {
        [self hideFooterMenu];
        self.title = NSLocalizedString(@"SelectFilesTitle", @"");
    }
}

- (void) fileFolderCellDidUnselectFile:(MetaFile *)fileSelected {
}

- (void) moveListModalDidSelectFolder:(NSString *)folderUuid {
    [moveDao requestMoveFiles:selectedDocList toFolder:folderUuid];
    [self pushProgressViewWithProcessMessage:NSLocalizedString(@"MoveProgressMessage", @"") andSuccessMessage:NSLocalizedString(@"MoveSuccessMessage", @"") andFailMessage:NSLocalizedString(@"MoveFailMessage", @"")];
}

- (NSMutableArray *) filterFilesFromList:(NSArray *) list {
    NSMutableArray *result = [[NSMutableArray alloc] init];
    for(MetaFile *row in list) {
        if(!row.folder) {
            [result addObject:row];
        }
    }
    return result;
}

- (void) favSuccessCallback:(NSNumber *) favFlag {
    [self proceedSuccessForProgressView];
    [self triggerRefresh];
}

- (void) favFailCallback:(NSString *) errorMessage {
    [self proceedFailureForProgressView];
    [self showErrorAlertWithMessage:errorMessage];
}

- (void) moveSuccessCallback {
    [self proceedSuccessForProgressView];
    [self triggerRefresh];
}

- (void) moveFailCallback:(NSString *) errorMessage {
    [self proceedFailureForProgressView];
    [self showErrorAlertWithMessage:errorMessage];
}

- (void) deleteSuccessCallback {
    [self proceedSuccessForProgressView];
    [self triggerRefresh];
}

- (void) deleteFailCallback:(NSString *) errorMessage {
    [self proceedFailureForProgressView];
    [self showErrorAlertWithMessage:errorMessage];
}

- (void) sortDidChange {
    [self triggerRefresh];
}

- (void) changeToSelectedStatus {
    isSelectible = YES;
    self.title = NSLocalizedString(@"SelectFilesTitle", @"");
    
    previousButtonRef = self.navigationItem.leftBarButtonItem;
    
    CustomButton *cancelButton = [[CustomButton alloc] initWithFrame:CGRectMake(0, 0, 60, 20) withImageName:nil withTitle:NSLocalizedString(@"ButtonCancel", @"") withFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:18] withColor:[UIColor whiteColor]];
    [cancelButton addTarget:self action:@selector(cancelSelectible) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithCustomView:cancelButton];
    self.navigationItem.leftBarButtonItem = cancelItem;
    moreButton.hidden = YES;
    
    [APPDELEGATE.base immediateHideAddButton];
    
    [selectedDocList removeAllObjects];
    
    self.tableUpdateCounter++;
    [self.docTable reloadData];
    
    if(footerActionMenu) {
        [footerActionMenu removeFromSuperview];
    }
    footerActionMenu = [[FooterActionsMenuView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 60, self.view.frame.size.width, 60) shouldShowShare:NO shouldShowMove:NO shouldShowDelete:YES shouldShowPrint:NO];
    footerActionMenu.delegate = self;
    footerActionMenu.hidden = YES;
    [self.view addSubview:footerActionMenu];
}

- (void) cancelSelectible {
    self.title = NSLocalizedString(@"DocTitle", @"");
    self.navigationItem.leftBarButtonItem = previousButtonRef;
    moreButton.hidden = NO;
    
    isSelectible = NO;
    [selectedDocList removeAllObjects];
    
//    [APPDELEGATE.base immediateShowAddButton];
    
    self.tableUpdateCounter++;
    [self.docTable reloadData];
    
    if(footerActionMenu) {
        [footerActionMenu removeFromSuperview];
    }
}

- (void) showFooterMenu {
    footerActionMenu.hidden = NO;
}

- (void) hideFooterMenu {
    footerActionMenu.hidden = YES;
}

#pragma mark FooterMenuDelegate methods

- (void) footerActionMenuDidSelectDelete:(FooterActionsMenuView *) menu {
    BOOL inAnyAlbum = NO;
    if([CacheUtil showConfirmDeletePageFlag]) {
        for (NSInteger j = 0; j < [docTable numberOfSections]; ++j) {
            for (NSInteger i = 0; i < [docTable numberOfRowsInSection:j]; ++i) {
                UITableViewCell *cell = [docTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:j]];
                if([cell isKindOfClass:[AbstractFileFolderCell class]]) {
                    AbstractFileFolderCell *fileCell = (AbstractFileFolderCell *) cell;
                    if([selectedDocList containsObject:fileCell.fileFolder.uuid]) {
                        if(fileCell.fileFolder.addedAlbumUuids != nil && [fileCell.fileFolder.addedAlbumUuids count] > 0)
                            inAnyAlbum = YES;
                        [fileCell addMaskLayer];
                    }
                }
            }
        }
        [deleteDao requestDeleteFiles:selectedDocList];
        [self pushProgressViewWithProcessMessage:NSLocalizedString(@"DeleteProgressMessage", @"") andSuccessMessage:NSLocalizedString(@"DeleteSuccessMessage", @"") andFailMessage:NSLocalizedString(@"DeleteFailMessage", @"")];
    } else {
        self.deleteType = DeleteTypeFooterMenu;
        [MoreMenuView presentConfirmDeleteFromController:self.nav delegateOwner:self];
    }
}

- (void) footerActionMenuDidSelectMove:(FooterActionsMenuView *) menu {
}

- (void) footerActionMenuDidSelectShare:(FooterActionsMenuView *) menu {
}

- (void) moreClicked {
    [self presentMoreMenuWithList:@[[NSNumber numberWithInt:MoreMenuTypeSort], [NSNumber numberWithInt:MoreMenuTypeSelect]]];
}


#pragma mark - More Menu Delegate

-(void)moreMenuDidSelectSort {
    [MoreMenuView presentSortFromController:self.nav delegateOwner:self];
}

-(void)moreMenuDidSelectUpdateSelectOption {
    [self changeToSelectedStatus];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    IGLog(@"DocListController viewDidLoad");

    moreButton = [[CustomButton alloc] initWithFrame:CGRectMake(0, 0, 22, 22) withImageName:@"dots_icon.png"];
    [moreButton addTarget:self action:@selector(moreClicked) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *moreItem = [[UIBarButtonItem alloc] initWithCustomView:moreButton];
    self.navigationItem.rightBarButtonItem = moreItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark ConfirmDeleteModalDelegate methods

- (void) confirmDeleteDidCancel {
}

- (void) confirmDeleteDidConfirm {
    if(self.deleteType == DeleteTypeFooterMenu) {
        BOOL inAnyAlbum = NO;
        for (NSInteger j = 0; j < [docTable numberOfSections]; ++j) {
            for (NSInteger i = 0; i < [docTable numberOfRowsInSection:j]; ++i) {
                UITableViewCell *cell = [docTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:j]];
                if([cell isKindOfClass:[AbstractFileFolderCell class]]) {
                    AbstractFileFolderCell *fileCell = (AbstractFileFolderCell *) cell;
                    if([selectedDocList containsObject:fileCell.fileFolder.uuid]) {
                        if(fileCell.fileFolder.addedAlbumUuids != nil && [fileCell.fileFolder.addedAlbumUuids count] > 0)
                            inAnyAlbum = YES;
                        [fileCell addMaskLayer];
                    }
                }
            }
        }
        [deleteDao requestDeleteFiles:selectedDocList];
        [self pushProgressViewWithProcessMessage:NSLocalizedString(@"DeleteProgressMessage", @"") andSuccessMessage:NSLocalizedString(@"DeleteSuccessMessage", @"") andFailMessage:NSLocalizedString(@"DeleteFailMessage", @"")];
    } else if(self.deleteType == DeleteTypeSwipeMenu) {
        [deleteDao requestDeleteFiles:@[fileSelectedRef.uuid]];
        [self pushProgressViewWithProcessMessage:NSLocalizedString(@"DeleteProgressMessage", @"") andSuccessMessage:NSLocalizedString(@"DeleteSuccessMessage", @"") andFailMessage:NSLocalizedString(@"DeleteFailMessage", @"")];
    }
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationPortrait | UIInterfaceOrientationPortraitUpsideDown;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown);
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void) cancelRequests {
    [elasticSearchDao cancelRequest];
    elasticSearchDao = nil;
    
    [favoriteDao cancelRequest];
    favoriteDao = nil;
    
    [moveDao cancelRequest];
    moveDao = nil;
    
    [deleteDao cancelRequest];
    deleteDao = nil;
}

@end
