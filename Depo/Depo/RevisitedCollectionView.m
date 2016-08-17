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

#define COLL_COUNT_FOR_PAGE 10

@interface RevisitedCollectionView() {
    int tableUpdateCounter;
    int listOffset;
    BOOL isLoading;
}
@end

@implementation RevisitedCollectionView

@synthesize delegate;
@synthesize collections;
@synthesize selectedFileList;
@synthesize refreshControl;
@synthesize collTable;
@synthesize collDao;
@synthesize imgFooterActionMenu;
@synthesize level;
@synthesize collDate;
@synthesize isSelectible;

- (id) initWithFrame:(CGRect)frame {
    if(self = [super initWithFrame:frame]) {
        self.backgroundColor = [Util UIColorForHexColor:@"FFFFFF"];

        collDao = [[SearchByGroupDao alloc] init];
        collDao.delegate = self;
        collDao.successMethod = @selector(groupSuccessCallback:);
        collDao.failMethod = @selector(groupFailCallback:);

        tableUpdateCounter = 0;
        listOffset = 0;
        
        collections = [[NSMutableArray alloc] init];
        selectedFileList = [[NSMutableArray alloc] init];
        
        collTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height) style:UITableViewStylePlain];
        collTable.backgroundColor = [UIColor clearColor];
        collTable.backgroundView = nil;
        collTable.delegate = self;
        collTable.dataSource = self;
        collTable.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self addSubview:collTable];
        
        refreshControl = [[UIRefreshControl alloc] init];
        [refreshControl addTarget:self action:@selector(pullData) forControlEvents:UIControlEventValueChanged];
        [collTable addSubview:refreshControl];
    }
    return self;
}

- (void) pullData {
    listOffset = 0;
    
    int groupSize = self.level == ImageGroupLevelYear ? 50 : 48;
    int pageSize = self.level == ImageGroupLevelDay ? 40 : (groupSize*COLL_COUNT_FOR_PAGE);
    [collDao requestImagesByGroupByPage:listOffset bySize:pageSize byLevel:self.level byGroupDate:nil /*TODO*/ byGroupSize:[NSNumber numberWithInt:groupSize] bySort:APPDELEGATE.session.sortType];
    isLoading = YES;
    [delegate revisitedCollectionShouldShowLoading];
}

- (void) groupSuccessCallback:(NSArray *) fileGroups {
    [self.collections addObjectsFromArray:fileGroups];
    
    isLoading = NO;
    [delegate revisitedCollectionShouldHideLoading];
    [refreshControl endRefreshing];
    [collTable reloadData];
}

- (void) groupFailCallback:(NSString *) errorMessage {
    [delegate revisitedCollectionShouldHideLoading];
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(collections.count > 0) {
        FileInfoGroup *group = [collections objectAtIndex:indexPath.row];
        int imageForRow = self.level == ImageGroupLevelYear ? 10 : self.level == ImageGroupLevelMonth ? 8 : 4;
        float imageItemSize = collTable.frame.size.width/imageForRow;
        float imageContainerHeight = floorf(group.fileInfo.count/imageForRow)*imageItemSize;
        if(group.fileInfo.count%imageForRow > 0) {
            imageContainerHeight += imageItemSize;
        }
        return imageContainerHeight + 60;
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
            FileInfoGroup *group = [collections objectAtIndex:indexPath.row];
            cell = [[GroupedPhotosCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier withGroup:group withLevel:self.level isSelectible:isSelectible];
//TODO            ((GroupedPhotosCell *)cell).delegate = self;
        } else {
            cell = [[NoItemCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier imageName:@"no_photo_icon" titleText:NSLocalizedString(@"EmptyPhotosVideosTitle", @"") descriptionText:NSLocalizedString(@"EmptyPhotosVideosDescription", @"")];
        }
    }
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if([collections count] > 0) {
        if(level == ImageGroupLevelYear || level == ImageGroupLevelMonth) {
            ImageGroupLevel nextLevel = level == ImageGroupLevelYear ? ImageGroupLevelMonth : ImageGroupLevelDay;
            FileInfoGroup *selectedGroup = [collections objectAtIndex:indexPath.row];
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
    int groupSize = self.level == ImageGroupLevelYear ? 50 : 48;
    int pageSize = self.level == ImageGroupLevelDay ? 40 : (groupSize*COLL_COUNT_FOR_PAGE);
    [collDao requestImagesByGroupByPage:listOffset bySize:pageSize byLevel:self.level byGroupDate:self.collDate byGroupSize:[NSNumber numberWithInt:groupSize] bySort:APPDELEGATE.session.sortType];
}

@end
