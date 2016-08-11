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

@interface RevisitedAlbumListView() {
    int tableUpdateCounter;
    int listOffset;
    BOOL isLoading;
}
@end

@implementation RevisitedAlbumListView

@synthesize delegate;
@synthesize albums;
@synthesize albumTable;
@synthesize albumsDao;
@synthesize refreshControl;
@synthesize isSelectible;
@synthesize selectedAlbumList;

- (id) initWithFrame:(CGRect)frame {
    if(self = [super initWithFrame:frame]) {
        self.backgroundColor = [Util UIColorForHexColor:@"FFFFFF"];

        albumsDao = [[AlbumListDao alloc] init];
        albumsDao.delegate = self;
        albumsDao.successMethod = @selector(albumListSuccessCallback:);
        albumsDao.failMethod = @selector(albumListFailCallback:);

        tableUpdateCounter = 0;
        listOffset = 0;
        
        selectedAlbumList = [[NSMutableArray alloc] init];
        
        albumTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height) style:UITableViewStylePlain];
        albumTable.backgroundColor = [UIColor clearColor];
        albumTable.backgroundView = nil;
        albumTable.delegate = self;
        albumTable.dataSource = self;
        albumTable.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self addSubview:albumTable];
        
        refreshControl = [[UIRefreshControl alloc] init];
        [refreshControl addTarget:self action:@selector(pullData) forControlEvents:UIControlEventValueChanged];
        [albumTable addSubview:refreshControl];
    }
    return self;
}

- (void) pullData {
    listOffset = 0;
    [albumsDao requestAlbumListForStart:0 andSize:50 andSortType:APPDELEGATE.session.sortType];
}

- (void) albumListSuccessCallback:(NSMutableArray *) list {
    self.albums = list;
    tableUpdateCounter ++;
    isLoading = NO;
    [refreshControl endRefreshing];
    [albumTable reloadData];
    
    [delegate revisitedAlbumListDidFinishLoading];
}

- (void) albumListFailCallback:(NSString *) errorMessage {
    [delegate revisitedAlbumListDidFailRetrievingList:errorMessage];
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.frame.size.width/2;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (albums.count == 0)
        return 1;
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
    
    PhotoAlbum *album = [albums objectAtIndex:indexPath.row];
    if(isSelectible) {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        if([cell isKindOfClass:[MainPhotoAlbumCell class]]) {
            if(![selectedAlbumList containsObject:album.uuid]) {
                [selectedAlbumList addObject:album.uuid];
            }
            if([selectedAlbumList count] > 0) {
//TODO                [self showAlbumFooterMenu];
//TODO                self.title = [NSString stringWithFormat:NSLocalizedString(@"AlbumsSelectedTitle", @""), [selectedAlbumList count]];
            } else {
//TODO                [self hideAlbumFooterMenu];
//TODO                self.title = NSLocalizedString(@"SelectAlbumsTitle", @"");
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
//TODO                [self showAlbumFooterMenu];
//TODO                self.title = [NSString stringWithFormat:NSLocalizedString(@"AlbumsSelectedTitle", @""), [selectedAlbumList count]];
            } else {
//TODO                [self hideAlbumFooterMenu];
//TODO                self.title = NSLocalizedString(@"SelectAlbumsTitle", @"");
            }
        }
    }
}

@end
