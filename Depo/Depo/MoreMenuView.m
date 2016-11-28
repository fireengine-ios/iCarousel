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
            if ([delegate respondsToSelector:@selector(moreMenuDidSelectUpdateSelectOption)]) {
                [delegate moreMenuDidSelectUpdateSelectOption];
            }
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

@end
