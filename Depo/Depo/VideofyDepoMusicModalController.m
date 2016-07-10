//
//  VideofyDepoMusicModalController.m
//  Depo
//
//  Created by Mahir Tarlan on 10/07/16.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import "VideofyDepoMusicModalController.h"
#import "AppDelegate.h"
#import "NoItemCell.h"
#import "SimpleMusicCell.h"

@interface VideofyDepoMusicModalController ()

@end

@implementation VideofyDepoMusicModalController

@synthesize musicTable;
@synthesize musicList;

- (id) init {
    if(self = [super init]) {
        self.view.backgroundColor = [UIColor whiteColor];
        self.title = NSLocalizedString(@"MusicTitle", @"");
        
        listOffset = 0;
        
        elasticSearchDao = [[ElasticSearchDao alloc] init];
        elasticSearchDao.delegate = self;
        elasticSearchDao.successMethod = @selector(musicListSuccessCallback:);
        elasticSearchDao.failMethod = @selector(musicListFailCallback:);
        
        musicTable = [[UITableView alloc] initWithFrame:CGRectMake(0, self.topIndex, self.view.frame.size.width, self.view.frame.size.height - self.bottomIndex) style:UITableViewStylePlain];
        musicTable.delegate = self;
        musicTable.dataSource = self;
        musicTable.backgroundColor = [UIColor clearColor];
        musicTable.backgroundView = nil;
        musicTable.separatorStyle = UITableViewCellSeparatorStyleNone;
        musicTable.contentInset = UIEdgeInsetsMake(0, 0, 50, 0);
        [self.view addSubview:musicTable];
        
        [elasticSearchDao requestMusicForPage:listOffset andSize:21 andSortType:APPDELEGATE.session.sortType];
        [self showLoading];
    }
    return self;
}

- (void) musicListSuccessCallback:(NSArray *) files {
    [self hideLoading];
    
    isLoading = NO;
    
    if(musicList == nil) {
        musicList = [[NSMutableArray alloc] init];
    }
    [musicList addObjectsFromArray:[self filterFilesFromList:files]];
    
    [musicTable reloadData];
}

- (void) musicListFailCallback:(NSString *) errorMessage {
    [self hideLoading];
    [self showErrorAlertWithMessage:errorMessage];
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(musicList == nil) {
        return 0;
    } else if([musicList count] == 0) {
        return 1;
    } else {
        return [musicList count];
    }
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(musicList == nil || [musicList count] == 0) {
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
    NSString *cellIdentifier = [NSString stringWithFormat:@"MUSIC_MODAL_CELL_%d", (int)indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(!cell) {
        if(musicList == nil || [musicList count] == 0) {
            cell = [[NoItemCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier imageName:@"empty_state_icon" titleText:NSLocalizedString(@"EmptyMusicTitle", @"") descriptionText:@""];
        } else {
            MetaFile *fileAtIndex = [musicList objectAtIndex:indexPath.row];
            cell = [[SimpleMusicCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier withFileFolder:fileAtIndex isSelectible:NO isSwipeable:NO];
        }
    }
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(musicList == nil || [musicList count] == 0) {
        return;
    }
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if([cell isKindOfClass:[AbstractFileFolderCell class]]) {
        MetaFile *file = [musicList objectAtIndex:indexPath.row];
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:file.uuid forKey:@"depo_file_selected"];
        [[NSNotificationCenter defaultCenter] postNotificationName:VIDEOFY_DEPO_MUSIC_SELECTED_NOTIFICATION object:nil userInfo:userInfo];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
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

- (void) scrollViewDidScroll:(UIScrollView *)scrollView {
    if(!isLoading) {
        CGFloat currentOffset = musicTable.contentOffset.y;
        CGFloat maximumOffset = musicTable.contentSize.height - musicTable.frame.size.height;
        
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

- (void)viewDidLoad {
    [super viewDidLoad];
    IGLog(@"CurrentMusicListModalController viewDidLoad");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

@end
