//
//  MusicListModalController.m
//  Depo
//
//  Created by Mahir on 10/3/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "MusicListModalController.h"
#import "RefSongCell.h"
#import "AppConstants.h"

@interface MusicListModalController ()

@end

@implementation MusicListModalController

@synthesize songs;
@synthesize songTable;
@synthesize songQuery;

- (id)init {
    self = [super init];
    if (self) {
        self.title = NSLocalizedString(@"MusicsTitle", @"");
        self.view.backgroundColor = [UIColor whiteColor];

        CustomButton *cancelButton = [[CustomButton alloc] initWithFrame:CGRectMake(0, 0, 60, 20) withImageName:nil withTitle:NSLocalizedString(@"ButtonCancel", @"") withFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:18] withColor:[UIColor whiteColor]];
        [cancelButton addTarget:self action:@selector(triggerDismiss) forControlEvents:UIControlEventTouchUpInside];
        
        UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithCustomView:cancelButton];
        self.navigationItem.rightBarButtonItem = cancelItem;

        songTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStylePlain];
        songTable.backgroundColor = [UIColor clearColor];
        songTable.backgroundView = nil;
        songTable.delegate = self;
        songTable.dataSource = self;
        songTable.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self.view addSubview:songTable];

    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    IGLog(@"MusicListModalController viewDidLoad");

    MPMediaPropertyPredicate *predicate = [MPMediaPropertyPredicate predicateWithValue:[NSNumber numberWithInteger:MPMediaTypeAny] forProperty:MPMediaItemPropertyMediaType];
    
    self.songQuery = [[MPMediaQuery alloc] init];
    [songQuery addFilterPredicate:predicate];
    
    self.songs = [self.songQuery items];
    [self.songTable reloadData];
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.songs count];
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = [NSString stringWithFormat:@"SONG_CELL_%d", (int) indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(cell == nil) {
        MPMediaItem *song = [self.songs objectAtIndex:indexPath.row];
        cell = [[RefSongCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier withMedia:song];
    }
    return cell;
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
