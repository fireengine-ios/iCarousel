//
//  MoreMenuView.m
//  Depo
//
//  Created by Mahir on 9/26/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "MoreMenuView.h"
#import "MoreMenuCell.h"
#import "Util.h"
#import "AppDelegate.h"
#import "BaseViewController.h"



@implementation MoreMenuView

@synthesize delegate;
@synthesize moreTable;
@synthesize moreList;
@synthesize fileFolder;
@synthesize album;

- (id)initWithFrame:(CGRect)frame withList:(NSArray *) moreListRef {
    return [self initWithFrame:frame withList:moreListRef withFileFolder:nil];
}

- (id)initWithFrame:(CGRect)frame withList:(NSArray *) moreListRef withFileFolder:(MetaFile *) _fileFolder {
    return [self initWithFrame:frame withList:moreListRef withFileFolder:_fileFolder withAlbum:nil];
}

- (id)initWithFrame:(CGRect)frame withList:(NSArray *) moreListRef withFileFolder:(MetaFile *) _fileFolder withAlbum:(PhotoAlbum *) _album {
    self = [super initWithFrame:frame];
    if (self) {
        self.moreList = moreListRef;
        self.fileFolder = _fileFolder;
        self.album = _album;
        
        UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        bgView.backgroundColor = [UIColor blackColor];
        bgView.alpha = 0.8;
        [self addSubview:bgView];

        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(triggerDismiss)];
        tapGestureRecognizer.numberOfTapsRequired = 1;
        tapGestureRecognizer.enabled = YES;
        tapGestureRecognizer.delegate = self;
        [self addGestureRecognizer:tapGestureRecognizer];

        moreTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height) style:UITableViewStylePlain];
        moreTable.bounces = NO;
        moreTable.delegate = self;
        moreTable.dataSource = self;
        moreTable.backgroundColor = [UIColor clearColor];
        moreTable.backgroundView = nil;
        moreTable.separatorStyle = UITableViewCellSeparatorStyleNone;
        [moreTable sizeToFit];
        moreTable.isAccessibilityElement = YES;
        moreTable.accessibilityIdentifier = @"moreTableMoreMenu";
        [self addSubview:moreTable];
        
        UIImage *dropImg = self.fileFolder ? self.fileFolder.folder ? [UIImage imageNamed:@"menu_drop.png"] : [UIImage imageNamed:@"menu_drop_black.png"] : [UIImage imageNamed:@"menu_drop.png"];
        UIImageView *dropImgView = [[UIImageView alloc] initWithFrame:CGRectMake(self.frame.size.width - (IS_IPAD ? 100 : 30), 0, dropImg.size.width, dropImg.size.height)];
        dropImgView.image = dropImg;
        [self addSubview:dropImgView];
    }
    return self;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [moreList count];
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = [NSString stringWithFormat:@"MORE_MENU_CELL_%d", (int)indexPath.row];
    NSNumber *typeAsNumber = [moreList objectAtIndex:indexPath.row];
    MoreMenuType type = (MoreMenuType)[typeAsNumber intValue];
    MoreMenuCell *cell = nil;
    if(self.fileFolder) {
        cell = [[MoreMenuCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier withMenuType:type withFileType:self.fileFolder.contentType];
    } else {
        cell = [[MoreMenuCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier withMenuType:type];
    }
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    [self removeFromSuperview];
    NSNumber *typeAsNumber = [moreList objectAtIndex:indexPath.row];
    MoreMenuType type = (MoreMenuType)[typeAsNumber intValue];
    switch (type) {
        case MoreMenuTypeDelete:
            [delegate moreMenuDidSelectDelete];
            break;
        case MoreMenuTypeRemoveFromAlbum:
            [delegate moreMenuDidSelectRemoveFromAlbum];
            break;
        case MoreMenuTypeSort:
            [delegate moreMenuDidSelectSort];
            break;
        case MoreMenuTypeSortWithList:
            [delegate moreMenuDidSelectSortWithList];
            break;
        case MoreMenuTypeSelect:
            [delegate moreMenuDidSelectUpdateSelectOption];
            break;
        case MoreMenuTypeFavourites:
            [delegate moreMenuDidSelectFavourites];
            break;
        case MoreMenuTypeFolderDetail:
            [delegate moreMenuDidSelectFolderDetailForFolder:self.fileFolder];
            break;
        case MoreMenuTypeAlbumDetail:
            [delegate moreMenuDidSelectAlbumDetailForAlbum:self.album];
            break;
        case MoreMenuTypeFav:
            [delegate moreMenuDidSelectFav];
            break;
        case MoreMenuTypeUnfav:
            [delegate moreMenuDidSelectUnfav];
            break;
        case MoreMenuTypeFileDetail:
            [delegate moreMenuDidSelectFileDetailForFile:self.fileFolder];
            break;
        case MoreMenuTypeImageDetail:
            [delegate moreMenuDidSelectImageDetail];
            break;
        case MoreMenuTypeVideoDetail:
            [delegate moreMenuDidSelectVideoDetail];
            break;
        case MoreMenuTypeAlbumDelete:
            [delegate moreMenuDidSelectAlbumDelete];
            break;
        case MoreMenuTypeAlbumShare:
            [delegate moreMenuDidSelectAlbumShare];
            break;
        case MoreMenuTypeShare:
            [delegate moreMenuDidSelectShare];
            break;
        case MoreMenuTypeDownloadImage:
            [delegate moreMenuDidSelectDownloadImage];
            break;
        case MoreMenutypeDownloadAlbum:
            [delegate moreMenuDidSelectDownloadAlbum];
            break;
        case MoreMenuTypeSetCoverPhoto:
            [delegate moreMenuDidSelectSetCoverPhoto];
            break;
        case MoreMenuTypeMusicDetail:
            [delegate moreMenuDidSelectMusicDetail];
            break;
        case MoreMenuTypeVideofy:
            [delegate moreMenuDidSelectVideofy];
            break;
        default:
            break;
    }
    if([delegate respondsToSelector:@selector(moreMenuDidDismiss)]) {
        [delegate moreMenuDidDismiss];
    }
    [self removeFromSuperview];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([touch.view isDescendantOfView:moreTable]) {
        return NO;
    }
    return YES;
}

- (void) triggerDismiss {
    if([delegate respondsToSelector:@selector(moreMenuDidDismiss)]) {
        [delegate moreMenuDidDismiss];
    }
    [self removeFromSuperview];
}

 /*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/


#pragma mark - Class Methods

+(void)presentConfirmRemoveFromController:(UIViewController *)controller delegateOwner:(id<ConfirmRemoveDelegate>)delegateOwner {
    ConfirmRemoveModalController *confirmRemove = [[ConfirmRemoveModalController alloc] init];
    confirmRemove.delegate = delegateOwner;
    MyNavigationController *modalNav = [[MyNavigationController alloc] initWithRootViewController:confirmRemove];
    [controller presentViewController:modalNav animated:YES completion:nil];
}

+(void)presentConfirmDeleteFromController:(UIViewController *)controller delegateOwner:(id<ConfirmDeleteDelegate>)delegateOwner withMessage:(NSString*)message{
    ConfirmDeleteModalController *confirmDelete = [[ConfirmDeleteModalController alloc] initWithMessage:message];
    confirmDelete.delegate = delegateOwner;
    MyNavigationController *modalNav = [[MyNavigationController alloc] initWithRootViewController:confirmDelete];
    [controller presentViewController:modalNav animated:YES completion:nil];
}

+(void)presentConfirmDeleteFromController:(UIViewController *)controller delegateOwner:(id<ConfirmDeleteDelegate>)delegateOwner {
    ConfirmDeleteModalController *confirmDelete = [[ConfirmDeleteModalController alloc] init];
    confirmDelete.delegate = delegateOwner;
    MyNavigationController *modalNav = [[MyNavigationController alloc] initWithRootViewController:confirmDelete];
    [controller presentViewController:modalNav animated:YES completion:nil];
}

+(void)presentSortFromController:(UIViewController *)controller delegateOwner:(id<SortModalDelegate>)delegateOwner {
    SortModalController *sort = [[SortModalController alloc] init];
    sort.delegate = delegateOwner;
    MyNavigationController *modalNav = [[MyNavigationController alloc] initWithRootViewController:sort];
    [controller presentViewController:modalNav animated:YES completion:nil];
}

+(void)presnetSortWithList:(NSArray *)sortTypeList
            fromController:(UIViewController *)controller
             delegateOwner:(id<SortModalDelegate>)delegateOwner {
    
    SortModalController *sort = [[SortModalController alloc] initWithList:sortTypeList];
    sort.delegate = delegateOwner;
    MyNavigationController *modalNav = [[MyNavigationController alloc] initWithRootViewController:sort];
    [controller presentViewController:modalNav animated:YES completion:nil];
}

+(void)presentMoveFoldersListFromController:(UIViewController *)controller delegateOwner:(id<MoveListModalProtocol>)delegateOwner {
    MoveListModalController *move = [[MoveListModalController alloc] initForFolder:nil];
    move.delegate = delegateOwner;
    MyNavigationController *modalNav = [[MyNavigationController alloc] initWithRootViewController:move];
    [controller presentViewController:modalNav animated:YES completion:nil];
}

+(void)presentMoveFoldersListWithExcludingFolder:(NSString *)folderUUID
                                  fromController:(UIViewController *)controller
                                   delegateOwner:(id<MoveListModalProtocol>)delegateOwner {
    
    MoveListModalController *move = [[MoveListModalController alloc] initForFolder:nil withExludingFolder:folderUUID];
    move.delegate = delegateOwner;
    MyNavigationController *modalNav = [[MyNavigationController alloc] initWithRootViewController:move];
    [controller presentViewController:modalNav animated:YES completion:nil];
}

+(void)presentMoveFoldersListWithExcludingFolder:(NSString *)folderUUID
                            prohibitedFolderList:(NSArray *)prohibitedList
                                  fromController:(UIViewController *)controller
                                   delegateOwner:(id<MoveListModalProtocol>)delegateOwner {
    
    MoveListModalController *move = [[MoveListModalController alloc] initForFolder:nil withExludingFolder:folderUUID withProhibitedFolders:prohibitedList];
    move.delegate = delegateOwner;
    MyNavigationController *modalNav = [[MyNavigationController alloc] initWithRootViewController:move];
    [controller presentViewController:modalNav animated:YES completion:nil];
}

+(void)presentPhotoAlbumsFromController:(UIViewController *)controller delegateOwner:(id<AlbumModalDelete>)delegateOwner {
    PhotoAlbumListModalController *albumList = [[PhotoAlbumListModalController alloc] init];
    albumList.delegate = delegateOwner;
    MyNavigationController *modalNav = [[MyNavigationController alloc] initWithRootViewController:albumList];
    [controller presentViewController:modalNav animated:YES completion:nil];
}

+(void)presentRecentActivitesFromController:(UIViewController *)controller {
    RecentActivitiesController *recentActivities = [[RecentActivitiesController alloc] init];
    MyNavigationController *modalNav = [[MyNavigationController alloc] initWithRootViewController:recentActivities];
    [controller presentViewController:modalNav animated:YES completion:nil];
}

+(void)presentFolderDetailForFolder:(MetaFile *)folder
                    fromController:(UIViewController *)controller
                     delegateOwner:(id<FolderDetailDelegate>)delegateOwner {
    
    FolderDetailModalController *folderDetail = [[FolderDetailModalController alloc] initWithFolder:folder];
    folderDetail.delegate = delegateOwner;
    MyNavigationController *modalNav = [[MyNavigationController alloc] initWithRootViewController:folderDetail];
    [controller presentViewController:modalNav animated:YES completion:nil];
}

+(void)presentFileDetailForFile:(MetaFile *)file
                 fromController:(UIViewController *)controller
                  delegateOwner:(id<FileDetailDelegate>)delegateOwner {
    
    FileDetailModalController *fileDetail = [[FileDetailModalController alloc] initWithFile:file];
    fileDetail.delegate = delegateOwner;
    MyNavigationController *modalNav = [[MyNavigationController alloc] initWithRootViewController:fileDetail];
    [controller presentViewController:modalNav animated:YES completion:nil];
}

+(void)presentAlbumDetailForAlbum:(PhotoAlbum *)album
                   fromController:(UIViewController *)controller
                    delegateOwner:(id<AlbumDetailDelegate>)delegateOwner {
    
    AlbumDetailModalController *albumDetail = [[AlbumDetailModalController alloc] initWithAlbum:album];
    albumDetail.delegate = delegateOwner;
    MyNavigationController *modalNav = [[MyNavigationController alloc] initWithRootViewController:albumDetail];
    [controller presentViewController:modalNav animated:YES completion:nil];
}




@end
