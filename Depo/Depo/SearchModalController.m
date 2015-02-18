//
//  SearchModalController.m
//  Depo
//
//  Created by NCO on 18/11/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//


#import "SearchModalController.h"
#import "Util.h"
#import "AppDelegate.h"
#import "FolderCell.h"
#import "AbstractFileFolderCell.h"
#import "FolderEmptyCell.h"
#import "MusicCell.h"
#import "ImageCell.h"
#import "DocCell.h"
#import "TableHeaderView.h"
#import "MessageCell.h"
#import "SearchMoreModalController.h"
#import "FileListController.h"
#import "ImagePreviewController.h"
#import "MusicPreviewController.h"
#import "VideoPreviewController.h"
#import "FileDetailInWebViewController.h"
#import "PreviewUnavailableController.h"
#import "AppDelegate.h"
#import "BaseViewController.h"

@interface SearchModalController ()

@end

@implementation SearchModalController

@synthesize deleteType;

- (id) init {
    if (self = [super init]) {
        self.view.backgroundColor = [UIColor whiteColor];
        self.title = NSLocalizedString(@"SearchTitle", @"");
        
        searchDao = [[SearchDao alloc] init];
        searchDao.delegate = self;
        searchDao.successMethod = @selector(searchListSuccessCallback:);
        searchDao.failMethod = @selector(searchListFailCallback:);
        
        deleteDao = [[DeleteDao alloc] init];
        deleteDao.delegate = self;
        deleteDao.successMethod = @selector(deleteSuccessCallback);
        deleteDao.failMethod = @selector(deleteFailCallback:);
        
        folderDeleteDao = [[DeleteDao alloc] init];
        folderDeleteDao.delegate = self;
        folderDeleteDao.successMethod = @selector(folderDeleteSuccessCallback);
        folderDeleteDao.failMethod = @selector(folderDeleteFailCallback:);
        
        favoriteDao = [[FavoriteDao alloc] init];
        favoriteDao.delegate = self;
        favoriteDao.successMethod = @selector(favSuccessCallback:);
        favoriteDao.failMethod = @selector(favFailCallback:);
        
        folderFavDao = [[FavoriteDao alloc] init];
        folderFavDao.delegate = self;
        folderFavDao.successMethod = @selector(folderFavSuccessCallback:);
        folderFavDao.failMethod = @selector(folderFavFailCallback:);
        
        moveDao = [[MoveDao alloc] init];
        moveDao.delegate = self;
        moveDao.successMethod = @selector(moveSuccessCallback);
        moveDao.failMethod = @selector(moveFailCallback:);

        CustomButton *crossButton = [[CustomButton alloc]initWithFrame:CGRectMake(40, 15, 30, 30) withImageName:@"multiply"];
        [crossButton addTarget:self action:@selector(triggerDismiss) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithCustomView:crossButton];
        self.navigationItem.leftBarButtonItem = cancelItem;
        
        searchFieldContainer = [[UIView alloc] init];
        searchFieldContainer.backgroundColor = [Util UIColorForHexColor:@"1a1e24"];
        
        searchField = [[SearchTextField alloc] initWithFrame:CGRectMake(12, 38, 296, 43)];
        searchField.placeholder = @"";
        searchField.returnKeyType = UIReturnKeySearch;
        searchField.delegate = self;
        [searchField addTarget:self
                      action:@selector(searchFieldDidChange)
            forControlEvents:UIControlEventEditingChanged];
        [searchFieldContainer addSubview:searchField];
        
        recentSearchesTableView = [[RecentSearchesTableView alloc] initWithSearchField:searchField];
        recentSearchesTableView.ownerController = self;
        recentSearchesTableView.searchMethod = @selector(startSearch:);
        
        searchResultsTable = [[UITableView alloc] initWithFrame:CGRectMake(0, self.topIndex + 60, self.view.frame.size.width, self.view.frame.size.height - self.bottomIndex - 60)];
        searchResultsTable.separatorStyle = UITableViewCellSeparatorStyleNone;
        searchResultsTable.hidden = YES;
        searchResultsTable.delegate = self;
        searchResultsTable.dataSource = self;
        tableUpdateCounter = 0;
        
        [self.view addSubview:searchResultsTable];
        [self.view addSubview:recentSearchesTableView];
        [self.view addSubview:searchFieldContainer];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onKeyboardShow:)
                                                     name:UIKeyboardDidShowNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onKeyboardHide:)
                                                     name:UIKeyboardDidHideNotification
                                                   object:nil];
    }
    return self;
}

- (void)startSearch:(NSString *)searchText {
    [super showLoading];
    currentSearchText = searchText;
    [super fadeOut:searchResultsTable duration:0.01];
    [recentSearchesTableView addTextToSearchHistory:searchText];
    [searchField resignFirstResponder];
    tableUpdateCounter++;
    [searchDao requestMetadata:searchText andPage:0 andSize:1000000 andSortType:APPDELEGATE.session.sortType andSearchListType:SearchListTypeAllFiles];
}

- (void) searchListSuccessCallback:(NSArray *) files {
    if (fileList == nil)
        fileList = [[NSMutableArray alloc] init];
    else
        [fileList removeAllObjects];
    
    if (photoVideoList == nil)
        photoVideoList = [[NSMutableArray alloc] init];
    else
        [photoVideoList removeAllObjects];
    
    if (musicList == nil)
        musicList = [[NSMutableArray alloc] init];
    else
        [musicList removeAllObjects];
    
    if (docList == nil)
        docList = [[NSMutableArray alloc] init];
    else
        [docList removeAllObjects];
    
    [fileList addObjectsFromArray:files];
    for (int i = 0; i < files.count; i++)
    {
        id objAtIndex = [fileList objectAtIndex:i];
        if ([objAtIndex isKindOfClass:[MetaFile class]]) {
            MetaFile *fileAtIndex = (MetaFile *) objAtIndex;
            if (fileAtIndex.contentType == ContentTypePhoto || fileAtIndex.contentType == ContentTypeVideo)
                [photoVideoList addObject:fileAtIndex];
            else if (fileAtIndex.contentType == ContentTypeMusic)
                [musicList addObject:fileAtIndex];
            else if (fileAtIndex.contentType == ContentTypeDoc)
                [docList addObject:fileAtIndex];
        }
    }
    
    tableUpdateCounter++;
    [searchResultsTable reloadData];
    [super hideLoading];
    NSLog(@"alpha before in: %f", searchResultsTable.alpha);
    [super fadeIn:searchResultsTable duration:0.2];
    
}

- (void) searchListFailCallback:(NSString *) errorMessage {
    [super hideLoading];
    [super showErrorAlertWithMessage:errorMessage];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    animateSearchArea = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.navigationController.navigationBar setBarTintColor:[Util UIColorForHexColor:@"1a1e24"]];
    [self.navigationController.navigationBar setTintColor:[Util UIColorForHexColor:@"1a1e24"]];
    if (animateSearchArea) {
        searchFieldContainer.frame = CGRectMake(0, self.topIndex, 320, 90);
        [UIView animateWithDuration:0.3
                              delay:0
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             searchFieldContainer.frame = CGRectMake(0, searchFieldContainer.frame.origin.y - 30, searchFieldContainer.frame.size.width, searchFieldContainer.frame.size.height);
                         } completion:^(BOOL finished) {
                             [searchField becomeFirstResponder];
                         }];
        animateSearchArea = NO;
    }
    
}

- (void)onKeyboardShow:(NSNotification *)notification
{
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    float keyboardHeight = MIN(keyboardSize.height,keyboardSize.width);
    if (recentSearchesTableView.tableHeight == 0) {
        recentSearchesTableView.tableHeight = self.view.frame.size.height - (self.bottomIndex + keyboardHeight) + 4;
        recentSearchesTableView.frame = CGRectMake(0, self.topIndex + 60 - recentSearchesTableView.tableHeight, self.view.frame.size.width, recentSearchesTableView.tableHeight);
    }
    [recentSearchesTableView showTableView];
}

- (void)onKeyboardHide:(NSNotification *)notification {
    [recentSearchesTableView hideTableView];
}

- (void)searchFieldDidChange {
    if (recentSearchesTableView != nil) {
        if (searchField.text.length > 0)
            [recentSearchesTableView hideTableView];
        else
            [recentSearchesTableView showTableView];
    }
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    textField.backgroundColor = [UIColor whiteColor];
    textField.textColor = [Util UIColorForHexColor:@"2c3037"];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    textField.backgroundColor = [Util UIColorForHexColor:@"2c3037"];
    textField.textColor = [UIColor whiteColor];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    NSString *searchText = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (searchText.length > 0)
        [self startSearch:searchText];
    return YES;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (fileList == nil || [fileList count] == 0)
        return 1;
    else
        return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (fileList == nil || [fileList count] == 0)
        return 1;
    else {
        if (section == SearchListTypeAllFiles && (fileList.count == photoVideoList.count || fileList.count == musicList.count || fileList.count == docList.count))
            return 0;
        NSMutableArray *currentList = [self getCurrentList:(int)section];
        if (currentList.count < 3)
            return currentList.count;
        else
            return 3;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == SearchListTypeAllFiles && (fileList.count == photoVideoList.count || fileList.count == musicList.count || fileList.count == docList.count))
        return 0;
    NSMutableArray *currentList = [self getCurrentList:(int)section];
    if (currentList.count == 0)
        return 0;
    else
        return 35;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (fileList == nil || [fileList count] == 0)
        return 320;
    else {
        if (indexPath.row < 2)
            return 68;
        else if (indexPath.row == 2)
            return 60;
        else
            return 0;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSMutableArray *currentList = [self getCurrentList:(int)section];
    NSString *titleText;
    switch (section) {
        case 0: titleText = NSLocalizedString(@"AllFilesHeader", @""); break;
        case 1: titleText = NSLocalizedString(@"PhotosVideosHeader", @""); break;
        case 2: titleText = NSLocalizedString(@"MusicHeader", @""); break;
        case 3: titleText = NSLocalizedString(@"DocumentsHeader", @""); break;
        default: return 0;
    }
    titleText = [NSString stringWithFormat:titleText, currentList.count];
    
    TableHeaderView *tableHeaderView = [[TableHeaderView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 35) andTitleText:titleText];
    
    return tableHeaderView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = [NSString stringWithFormat:@"FILE_CELL_%d_%d_%d", (int)indexPath.section, (int)indexPath.row, tableUpdateCounter];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        if (fileList != nil && [fileList count] != 0) {
            NSMutableArray *currentList = [self getCurrentList:(int)indexPath.section];
            id objAtIndex = [currentList objectAtIndex:indexPath.row];
            if ([objAtIndex isKindOfClass:[MetaFile class]]) {
                MetaFile *fileAtIndex = (MetaFile *) objAtIndex;
                
                if (indexPath.row == 0 || indexPath.row == 1) {
                    if (fileAtIndex.contentType == ContentTypeFolder)
                        cell = [[FolderCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier withFileFolder:fileAtIndex highlightedText:currentSearchText];
                    else if (fileAtIndex.contentType == ContentTypePhoto || fileAtIndex.contentType == ContentTypeVideo)
                        cell = [[ImageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier withFileFolder:fileAtIndex highlightedText:currentSearchText];
                    else if (fileAtIndex.contentType == ContentTypeMusic)
                        cell = [[MusicCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier withFileFolder:fileAtIndex highlightedText:currentSearchText];
                    else if (fileAtIndex.contentType == ContentTypeDoc)
                        cell = [[DocCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier withFileFolder:fileAtIndex highlightedText:currentSearchText];
                    else
                        cell = [[DocCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier withFileFolder:fileAtIndex highlightedText:currentSearchText];
                    ((AbstractFileFolderCell *) cell).delegate = self;
                }
                else if (indexPath.row == 2) {
                    cell = [[MessageCell alloc]initWithCellStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier titleText:NSLocalizedString(@"ShowMore", @"")];
                }
                else {
                    return nil;
                }
            }
        }
        else if (fileList == nil) {
            cell = [[MessageCell alloc]initWithCellStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier titleText:NSLocalizedString(@"ConnectionErrorWarning", @"")];
        }
        else if ([fileList count] == 0) {
            cell = [[MessageCell alloc]initWithCellStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier titleText:NSLocalizedString(@"NoSearchResultFound", @"")];
        }
    }
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSMutableArray *currentList = [self getCurrentList:(int)indexPath.section];
    if (indexPath.row < 2) {
        MetaFile *fileAtIndex = (MetaFile *) [currentList objectAtIndex:indexPath.row];
        
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        if([cell isKindOfClass:[AbstractFileFolderCell class]]) {
            AbstractFileFolderCell *fileFolderCell = (AbstractFileFolderCell *) cell;
            if(fileFolderCell.menuActive) {
                return;
            }
        }
        
        if(fileAtIndex.contentType == ContentTypeFolder) {
            FileListController *innerList = [[FileListController alloc] initForFolder:fileAtIndex];
            innerList.nav = self.nav;
            [self.nav pushViewController:innerList animated:NO];
        } else {
            if([AppUtil isMetaFileImage:fileAtIndex]) {
                ImagePreviewController *detail = [[ImagePreviewController alloc] initWithFile:fileAtIndex];
                MyNavigationController *modalNav = [[MyNavigationController alloc] initWithRootViewController:detail];
                detail.nav = modalNav;
                [self presentViewController:modalNav animated:YES completion:nil];
            } else if([AppUtil isMetaFileDoc:fileAtIndex]){
                FileDetailInWebViewController *detail = [[FileDetailInWebViewController alloc] initWithFile:fileAtIndex];
                detail.nav = self.nav;
                [self.nav pushViewController:detail animated:NO];
            } else if([AppUtil isMetaFileVideo:fileAtIndex]) {
                VideoPreviewController *detail = [[VideoPreviewController alloc] initWithFile:fileAtIndex];
                MyNavigationController *modalNav = [[MyNavigationController alloc] initWithRootViewController:detail];
                detail.nav = modalNav;
                [APPDELEGATE.base presentViewController:modalNav animated:YES completion:nil];
            } else if([AppUtil isMetaFileMusic:fileAtIndex]) {
                MusicPreviewController *detail = [[MusicPreviewController alloc] initWithFile:fileAtIndex.uuid withFileList:@[fileAtIndex]];
                detail.nav = self.nav;
                [self.nav pushViewController:detail animated:NO];
            } else {
                PreviewUnavailableController *detail = [[PreviewUnavailableController alloc] initWithFile:fileAtIndex];
                detail.nav = self.nav;
                [self.nav pushViewController:detail animated:NO];
            }
        }
    }
    else if (indexPath.row == 2)
        [self didTriggerMoreResults:currentSearchText andSearchListType:indexPath.section andFileCount:currentList.count];

}

- (NSMutableArray *)getCurrentList:(int)sectionNumber {
    switch (sectionNumber) {
        case SearchListTypeAllFiles: return fileList;
        case SearchListTypePhotosAndVides: return photoVideoList;
        case SearchListTypeMusics: return musicList;
        case SearchListTypeDocumnets: return docList;
        default: return nil;
    }
}

- (void) didTriggerMoreResults:(NSString *)searchText andSearchListType:(int)searchListType andFileCount:(int)fileCount {
    SearchMoreModalController *searchMoreModalController = [[SearchMoreModalController alloc] initWithSearchText:searchText andSearchListType:searchListType andFileCount:fileCount ];
    searchMoreModalController.nav = self.nav;
    [self.nav pushViewController:searchMoreModalController animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
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



#pragma mark AbstractFileFolderDelegate methods

- (void) fileFolderCellShouldFavForFile:(MetaFile *)fileSelected {
    [favoriteDao requestMetadataForFiles:@[fileSelected.uuid] shouldFavorite:YES];
    //    [self showLoading];
    [self pushProgressViewWithProcessMessage:NSLocalizedString(@"FavAddProgressMessage", @"") andSuccessMessage:NSLocalizedString(@"FavAddSuccessMessage", @"") andFailMessage:NSLocalizedString(@"FavAddFailMessage", @"")];
}

- (void) fileFolderCellShouldUnfavForFile:(MetaFile *)fileSelected {
    [favoriteDao requestMetadataForFiles:@[fileSelected.uuid] shouldFavorite:NO];
    //    [self showLoading];
    [self pushProgressViewWithProcessMessage:NSLocalizedString(@"UnfavProgressMessage", @"") andSuccessMessage:NSLocalizedString(@"UnfavSuccessMessage", @"") andFailMessage:NSLocalizedString(@"UnfavFailMessage", @"")];
}

- (void) fileFolderCellShouldDeleteForFile:(MetaFile *)fileSelected {
    if([CacheUtil showConfirmDeletePageFlag]) {
        [deleteDao requestDeleteFiles:@[fileSelected.uuid]];
        [self pushProgressViewWithProcessMessage:NSLocalizedString(@"DeleteProgressMessage", @"") andSuccessMessage:NSLocalizedString(@"DeleteSuccessMessage", @"") andFailMessage:NSLocalizedString(@"DeleteFailMessage", @"")];
    } else {
        fileSelectedRef = fileSelected;
        self.deleteType = DeleteTypeSwipeMenu;
        [APPDELEGATE.base showConfirmDelete];
    }
}

- (void) fileFolderCellShouldShareForFile:(MetaFile *)fileSelected {
    [APPDELEGATE.base triggerShareForFiles:@[fileSelected.uuid]];
}



- (void) favSuccessCallback:(NSNumber *) favFlag {
    
}

- (void) favFailCallback:(NSString *) errorMessage {
    [self showErrorAlertWithMessage:errorMessage];
}





@end
