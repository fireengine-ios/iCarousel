//
//  RevisitedAlbumListView.m
//  Depo
//
//  Created by Mahir Tarlan on 09/08/16.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import "RevisitedAlbumListView.h"
#import "Util.h"
#import "AppDelegate.h"
#import "AppSession.h"
#import "PhotoAlbum.h"
#import "MainPhotoAlbumCell.h"
#import "NoItemCell.h"
#import "MyNavigationController.h"
#import "CacheUtil.h"
#import "MyViewController.h"

@interface RevisitedAlbumListView() {
    int tableUpdateCounter;
    int listOffset;
    BOOL isLoading;
    NSIndexPath *selectedAlbumIndexPath;
    
}
@end

@implementation RevisitedAlbumListView

@synthesize delegate;
@synthesize albums;
@synthesize albumTable;
@synthesize albumsDao;
@synthesize deleteAlbumDao;
@synthesize addAlbumDao;
@synthesize refreshControl;
@synthesize isSelectible;
@synthesize selectedAlbumList;
@synthesize footerActionMenu;
@synthesize progress;

- (id) initWithFrame:(CGRect)frame {
    if(self = [super initWithFrame:frame]) {
        self.backgroundColor = [Util UIColorForHexColor:@"FFFFFF"];

        albumsDao = [[AlbumListDao alloc] init];
        albumsDao.delegate = self;
        albumsDao.successMethod = @selector(albumListSuccessCallback:);
        albumsDao.failMethod = @selector(albumListFailCallback:);

        deleteAlbumDao = [[DeleteAlbumsDao alloc] init];
        deleteAlbumDao.delegate = self;
        deleteAlbumDao.successMethod = @selector(deleteAlbumSuccessCallback);
        deleteAlbumDao.failMethod = @selector(deleteAlbumFailCallback:);

        addAlbumDao = [[AddAlbumDao alloc] init];
        addAlbumDao.delegate = self;
        addAlbumDao.successMethod = @selector(addAlbumSuccessCallback);
        addAlbumDao.failMethod = @selector(addAlbumFailCallback:);
        
        tableUpdateCounter = 0;
        listOffset = 0;
        
        selectedAlbumList = [[NSMutableArray alloc] init];
        
        albumTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height) style:UITableViewStylePlain];
        albumTable.backgroundColor = [UIColor clearColor];
        albumTable.backgroundView = nil;
        albumTable.delegate = self;
        albumTable.dataSource = self;
        albumTable.separatorStyle = UITableViewCellSeparatorStyleNone;
        albumTable.isAccessibilityElement = YES;
        albumTable.accessibilityIdentifier = @"albumTableRevisitedAlbum";
        [self addSubview:albumTable];
        
        [self createRefreshControl];

        UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(triggerSelectionState:)];
        longPressGesture.minimumPressDuration = 1.0;
        [albumTable addGestureRecognizer:longPressGesture];

        progress = [[MBProgressHUD alloc] initWithFrame:self.frame];
        progress.opacity = 0.4f;
        [self addSubview:progress];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(coverPhotoChanged) name:ALBUM_COVER_PHOTO_SET_NOTIFICATION object:nil];
        
    }
    return self;
}

-(void)createRefreshControl {
    if (!refreshControl) {
        refreshControl = [[UIRefreshControl alloc] init];
        [refreshControl addTarget:self action:@selector(pullData) forControlEvents:UIControlEventValueChanged];
        [albumTable addSubview:refreshControl];
    }
}

-(void)removeRefreshControl {
    [refreshControl removeFromSuperview];
    refreshControl = nil;
}

- (void) triggerSelectionState:(UILongPressGestureRecognizer *)gestureRecognizer {
    if(!isSelectible) {
        if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
            CGPoint p = [gestureRecognizer locationInView:albumTable];
            NSIndexPath *indexPath = [albumTable indexPathForRowAtPoint:p];
            if (indexPath != nil) {
                UITableViewCell *cell = [albumTable cellForRowAtIndexPath:indexPath];
                if (cell.isHighlighted) {
                    [self setToSelectible];
                    [delegate revisitedAlbumListDidChangeToSelectState];
                    [albumTable selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
                    [self selectAlbumIndex:indexPath];
                }
            }
        }
    }
}

- (void) setToSelectible {
    isSelectible = YES;
    [self removeRefreshControl];
//    [refreshControl setEnabled:NO];
    [selectedAlbumList removeAllObjects];
    
    albumTable.allowsMultipleSelection = YES;
    tableUpdateCounter ++;
    [albumTable reloadData];
}

- (void) setToUnselectiblePriorToRefresh {
    isSelectible = NO;
    [self createRefreshControl];
//    [refreshControl setEnabled:YES];
    [selectedAlbumList removeAllObjects];
    
    if(footerActionMenu) {
        [footerActionMenu removeFromSuperview];
        footerActionMenu = nil;
    }
}

- (void) setToUnselectible {
    isSelectible = NO;
    [self createRefreshControl];
//    [refreshControl setEnabled:YES];
    [selectedAlbumList removeAllObjects];
    
    if(footerActionMenu) {
        [footerActionMenu removeFromSuperview];
        footerActionMenu = nil;
    }

    albumTable.allowsMultipleSelection = NO;
    tableUpdateCounter ++;
    [albumTable reloadData];
}

- (void) pullData {
    isLoading = YES;
    listOffset = 0;
    [albumsDao requestAlbumListForStart:0 andSize:50 andSortType:APPDELEGATE.session.sortType];
    
    [self bringSubviewToFront:progress];
    [progress show:YES];
}

- (void) albumListSuccessCallback:(NSMutableArray *) list {
    [progress hide:YES];

    self.albums = list;
    tableUpdateCounter ++;
    isLoading = NO;
    [refreshControl endRefreshing];
    [albumTable reloadData];
}

- (void) albumListFailCallback:(NSString *) errorMessage {
    isLoading = NO;
    [progress hide:YES];
    //[delegate revisitedAlbumListDidFailRetrievingList:errorMessage];
}

- (void) deleteAlbumSuccessCallback {
    [delegate revisitedAlbumListDidFinishDeleting];
}

- (void) deleteAlbumFailCallback:(NSString *) errorMessage {
    [progress hide:YES];
    [delegate revisitedAlbumListDidFailDeletingWithError:errorMessage];
}

- (void) showAlbumFooterMenu {
    if(footerActionMenu) {
        footerActionMenu.hidden = NO;
    } else {
        footerActionMenu = [[FooterActionsMenuView alloc] initWithFrame:CGRectMake(0, self.frame.size.height - 70, self.frame.size.width, 60) shouldShowShare:YES shouldShowMove:NO shouldShowDelete:YES shouldShowDownload:YES shouldShowPrint:NO];
        footerActionMenu.delegate = self;
        [self addSubview:footerActionMenu];
    }
}

- (void) hideAlbumFooterMenu {
    footerActionMenu.hidden = YES;
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.frame.size.width/2;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (albums.count == 0)
        return isLoading ? 0 : 1;
    return [albums count];
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = [NSString stringWithFormat:@"%@_%d_%d", @"ALBUM_CELL",  (int)indexPath.row, tableUpdateCounter];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(cell == nil) {
        if (albums.count > 0) {
            PhotoAlbum *album = [albums objectAtIndex:indexPath.row];
            cell = [[MainPhotoAlbumCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier withPhotoAlbum:album isSelectible:isSelectible];
        } else {
            cell = [[NoItemCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier imageName:@"no_album_icon" titleText:NSLocalizedString(@"EmptyAlbumsTitle", @"") descriptionText:NSLocalizedString(@"EmptyAlbumsDescription", @"")];
        }
    }
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(albums == nil || [albums count] == 0) {
        return;
    }
    [self selectAlbumIndex:indexPath];
}

-(void)selectAlbumIndex:(NSIndexPath*)indexPath {
    selectedAlbumIndexPath = indexPath;
    PhotoAlbum *album = [albums objectAtIndex:indexPath.row];
    if(isSelectible) {
        UITableViewCell *cell = [albumTable cellForRowAtIndexPath:indexPath];
        if([cell isKindOfClass:[MainPhotoAlbumCell class]]) {
            if(![selectedAlbumList containsObject:album.uuid]) {
                [selectedAlbumList addObject:album.uuid];
            }
            if([selectedAlbumList count] > 0) {
                [self showAlbumFooterMenu];
                [delegate revisitedAlbumListChangeTitleTo:[NSString stringWithFormat:NSLocalizedString(@"AlbumsSelectedTitle", @""), [selectedAlbumList count]]];
            } else {
                [self hideAlbumFooterMenu];
                [delegate revisitedAlbumListChangeTitleTo:NSLocalizedString(@"SelectAlbumsTitle", @"")];
            }
        }
    } else {
        [delegate revisitedAlbumListDidSelectAlbum:album];
    }
}

- (void) cleanPageRelatedRequests {
    [albumsDao cancelRequest];
}

- (void) tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(isSelectible) {
        if(!albums || [albums count] == 0) {
            return;
        }
        if([albums count] > indexPath.row) {
            PhotoAlbum *album = [albums objectAtIndex:indexPath.row];
            if([selectedAlbumList containsObject:album.uuid]) {
                [selectedAlbumList removeObject:album.uuid];
            }
            if([selectedAlbumList count] > 0) {
                [self showAlbumFooterMenu];
                [delegate revisitedAlbumListChangeTitleTo:[NSString stringWithFormat:NSLocalizedString(@"AlbumsSelectedTitle", @""), [selectedAlbumList count]]];
            } else {
                [self hideAlbumFooterMenu];
                [delegate revisitedAlbumListChangeTitleTo:NSLocalizedString(@"SelectAlbumsTitle", @"")];
            }
        }
    }
}



- (void) footerActionMenuDidSelectDelete:(FooterActionsMenuView *) menu {
    if([CacheUtil showConfirmDeletePageFlag]) {
        [self confirmDeleteDidConfirm];
    } else {
        ConfirmDeleteModalController *confirmDelete = [[ConfirmDeleteModalController alloc] initWithMessage:@"ConfirmDeleteAlbumMessage"];
        confirmDelete.delegate = self;
        MyNavigationController *modalNav = [[MyNavigationController alloc] initWithRootViewController:confirmDelete];
        MyViewController * parent = (MyViewController*)self.delegate;
        [parent presentViewController:modalNav animated:YES completion:nil];
    }
}

-(void)confirmDeleteDidConfirm {
    NSArray* selectedAlbums = [self getSelectedAlbums];
    BOOL hasReadOnlyAlbums = NO;
    for (PhotoAlbum* album in selectedAlbums) {
        if (album.isReadOnly) {
            hasReadOnlyAlbums = YES;
            break;
        }
    }
    if (!hasReadOnlyAlbums) {
        [deleteAlbumDao requestDeleteAlbums:self.selectedAlbumList];
        [self bringSubviewToFront:progress];
        [progress show:YES];
    }
    else {
        [delegate revisitedAlbumListDidFailDeletingWithError:NSLocalizedString(@"CanNotDeleteReadonlyAlbums", nil)];
    }
}

-(void)confirmDeleteDidCancel{
    
}

//- (void) footerActionMenuDidSelectDelete:(FooterActionsMenuView *) menu {
//    [deleteAlbumDao requestDeleteAlbums:self.selectedAlbumList];
//
//    [self bringSubviewToFront:progress];
//    [progress show:YES];
//}

- (void) footerActionMenuDidSelectMove:(FooterActionsMenuView *) menu {
}

- (void) footerActionMenuDidSelectShare:(FooterActionsMenuView *) menu {
    [delegate revisitedAlbumListShareAlbums:selectedAlbumList];
}

- (void) footerActionMenuDidSelectPrint:(FooterActionsMenuView *)menu {
}

-(void)footerActionMenuDidSelectDownload:(FooterActionsMenuView *)menu {
    [delegate revisitedAlbumListDownloadAlbums:[self getSelectedAlbums]];
//    [delegate revisitedAlbumListDownloadAlbums:selectedAlbumList albumNames:[self getSelectedAlbumNames]];
}

//-(NSArray *)getSelectedAlbumNames {
//    NSMutableArray *names = [NSMutableArray array];
//    for (PhotoAlbum *album in self.albums) {
//        for (NSString *uuid in selectedAlbumList) {
//            if ([album.uuid isEqualToString:uuid]) {
//                [names addObject:album.label];
//            }
//        }
//        
//    }
//    
//    return names;
//}

-(NSArray *)getSelectedAlbums {
    NSMutableArray *selectedAlbums = [NSMutableArray array];
    for (PhotoAlbum *album in self.albums) {
        for (NSString *uuid in selectedAlbumList) {
            if ([album.uuid isEqualToString:uuid]) {
                [selectedAlbums addObject:album];
            }
        }
        
    }
    
    return selectedAlbums;
}


- (void) addNewAlbumWithName:(NSString *) albumName {
    [addAlbumDao requestAddAlbumWithName:albumName];

    [self bringSubviewToFront:progress];
    [progress show:YES];
}

- (void) addAlbumSuccessCallback {
    [progress hide:YES];
    [self pullData];
}

- (void) addAlbumFailCallback:(NSString *) errorMessage {
    [progress hide:YES];
    [delegate revisitedAlbumListDidFailRetrievingList:errorMessage];
}

- (void) cancelRequests {
    [albumsDao cancelRequest];
    albumsDao = nil;
    
    [deleteAlbumDao cancelRequest];
    deleteAlbumDao = nil;
    
    [addAlbumDao cancelRequest];
    addAlbumDao = nil;
}

- (void) showLoading {
    [progress show:YES];
    [self bringSubviewToFront:progress];
}

- (void) hideLoading {
    [progress hide:YES];
}

- (void) coverPhotoChanged {
    [albumTable beginUpdates];
    [albumTable reloadRowsAtIndexPaths:[NSArray arrayWithObject:selectedAlbumIndexPath] withRowAnimation:UITableViewRowAnimationNone];
    [albumTable endUpdates];
    
}

@end
