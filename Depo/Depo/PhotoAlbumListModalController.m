//
//  PhotoAlbumListModalController.m
//  Depo
//
//  Created by Mahir on 12.11.2014.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "PhotoAlbumListModalController.h"
#import "AppDelegate.h"
#import "AppSession.h"
#import "MainPhotoAlbumCell.h"

@interface PhotoAlbumListModalController ()

@end

@implementation PhotoAlbumListModalController

@synthesize delegate;
@synthesize albumTable;
@synthesize albumList;

- (id)init {
    if(self = [super init]) {
        self.view.backgroundColor = [UIColor whiteColor];
        self.title = @" ";
        
        CustomButton *cancelButton = [[CustomButton alloc] initWithFrame:CGRectMake(0, 0, 60, 20) withImageName:nil withTitle:NSLocalizedString(@"ButtonCancel", @"") withFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:18] withColor:[UIColor whiteColor]];
        [cancelButton addTarget:self action:@selector(triggerDismiss) forControlEvents:UIControlEventTouchUpInside];
        
        UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithCustomView:cancelButton];
        self.navigationItem.rightBarButtonItem = cancelItem;
        
        albumsDao = [[AlbumListDao alloc] init];
        albumsDao.delegate = self;
        albumsDao.successMethod = @selector(albumListSuccessCallback:);
        albumsDao.failMethod = @selector(albumListFailCallback:);
        
        albumTable = [[UITableView alloc] initWithFrame:CGRectMake(0, self.topIndex, self.view.frame.size.width, self.view.frame.size.height - self.bottomIndex) style:UITableViewStylePlain];
        albumTable.delegate = self;
        albumTable.dataSource = self;
        albumTable.backgroundColor = [UIColor clearColor];
        albumTable.backgroundView = nil;
        albumTable.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self.view addSubview:albumTable];
        
        [albumsDao requestAlbumListForStart:0 andSize:50];
    }
    return self;
}

- (void) albumListSuccessCallback:(NSMutableArray *) list {
    self.albumList = list;
    [albumTable reloadData];
}

- (void) albumListFailCallback:(NSString *) errorMessage {
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [albumList count];
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.view.frame.size.width/2;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = [NSString stringWithFormat:@"MOVE_ALBUM_CELL_%d", (int)indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(!cell) {
        PhotoAlbum *album = [albumList objectAtIndex:indexPath.row];
        cell = [[MainPhotoAlbumCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier withPhotoAlbum:album];
    }
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    PhotoAlbum *album = [albumList objectAtIndex:indexPath.row];
    [delegate albumModalDidSelectAlbum:album.uuid];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) prepareAndSetNavigationTitleView {
    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 160, 40)];
    CustomLabel *subTitleLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(0, 0, titleView.frame.size.width, 16) withFont:[UIFont fontWithName:@"TurkcellSaturaDem" size:14] withColor:[UIColor whiteColor] withText:NSLocalizedString(@"MoveModalSubTitleForAlbumNew", @"")];
    subTitleLabel.textAlignment = NSTextAlignmentCenter;
    [titleView addSubview:subTitleLabel];
    CustomLabel *mainTitleLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(0, 18, titleView.frame.size.width, 22) withFont:[UIFont fontWithName:@"TurkcellSaturaDem" size:18] withColor:[UIColor whiteColor] withText:NSLocalizedString(@"AlbumsTitle", @"")];
    mainTitleLabel.textAlignment = NSTextAlignmentCenter;
    [titleView addSubview:mainTitleLabel];
    [self.navigationItem setTitleView:titleView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void) viewDidAppear:(BOOL)animated {
    [self prepareAndSetNavigationTitleView];
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
