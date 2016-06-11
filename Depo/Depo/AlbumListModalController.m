//
//  AlbumListModalController.m
//  Depo
//
//  Created by Mahir on 10/3/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "AlbumListModalController.h"
#import "RefAlbumCell.h"
#import "PhotoListModalController.h"

@interface AlbumListModalController ()

@end

@implementation AlbumListModalController

@synthesize delegateRef;
@synthesize albums;
@synthesize albumTable;
@synthesize al;

- (id)init {
    self = [super init];
    if (self) {
        self.view.backgroundColor = [UIColor whiteColor];
        self.title = NSLocalizedString(@"AlbumsTitle", @"");
        
        CustomButton *cancelButton = [[CustomButton alloc] initWithFrame:CGRectMake(0, 0, 60, 20) withImageName:nil withTitle:NSLocalizedString(@"ButtonCancel", @"") withFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:18] withColor:[UIColor whiteColor]];
        [cancelButton addTarget:self action:@selector(triggerDismiss) forControlEvents:UIControlEventTouchUpInside];
        
        UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithCustomView:cancelButton];
        self.navigationItem.rightBarButtonItem = cancelItem;
        
        self.al = [[ALAssetsLibrary alloc] init];
        self.albums = [[NSMutableArray alloc] init];

        albumTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 64) style:UITableViewStylePlain];
        albumTable.backgroundColor = [UIColor clearColor];
        albumTable.backgroundView = nil;
        albumTable.delegate = self;
        albumTable.dataSource = self;
        albumTable.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self.view addSubview:albumTable];
        
        [al enumerateGroupsWithTypes:ALAssetsGroupAlbum | ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
            if(group) {
                [group enumerateAssetsUsingBlock:^(ALAsset *asset, NSUInteger index, BOOL *stop) {
                    NSString *albumName = [group valueForProperty:ALAssetsGroupPropertyName];
                    NSUInteger compareIndex = [albums indexOfObjectPassingTest:^BOOL(MetaAlbum *obj, NSUInteger idx, BOOL *stop) {
                        return [obj.albumName isEqualToString:albumName];
                    }];
                    if (compareIndex == NSNotFound) {
                        MetaAlbum *album = [[MetaAlbum alloc] init];
                        album.albumName = albumName;
                        album.thumbnailImg = [UIImage imageWithCGImage:[asset thumbnail]];
                        album.count = 0;
                        [albums addObject:album];
                    } else {
                        MetaAlbum *album = albums[compareIndex];
                        album.count += 1;
                        [albums setObject:album atIndexedSubscript:compareIndex];
                    }
                }];
            } else {
                [self showAlbums];
            }
        } failureBlock:^(NSError *error) {
            if (error.code == ALAssetsLibraryAccessUserDeniedError || error.code == ALAssetsLibraryAccessGloballyDeniedError) {
                [self showErrorAlertWithMessage:NSLocalizedString(@"ALAssetsAccessError", @"")];
            }
        }];
    }
    return self;
}

- (void) showAlbums {
    [albumTable reloadData];
}

- (int) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.albums count];
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return IS_IPAD ? 90 : 60;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = [NSString stringWithFormat:@"ALBUM_CELL_%d", (int) indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(cell == nil) {
        MetaAlbum *album = [self.albums objectAtIndex:indexPath.row];
        cell = [[RefAlbumCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier withAlbum:album];
    }
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    MetaAlbum *album = [self.albums objectAtIndex:indexPath.row];
    
    PhotoListModalController *photoListController = [[PhotoListModalController alloc] initWithAlbum:album];
    photoListController.modalDelegate = self.delegateRef;
    [self.navigationController pushViewController:photoListController animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    IGLog(@"AlbumListModalController viewDidLoad");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
