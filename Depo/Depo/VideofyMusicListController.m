//
//  VideofyMusicListController.m
//  Depo
//
//  Created by Mahir Tarlan on 08/07/16.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import "VideofyMusicListController.h"
#import "VideofyDepoMusicModalController.h"

@interface VideofyMusicListController ()

@end

@implementation VideofyMusicListController

@synthesize audioDao;
@synthesize audioList;
@synthesize audioTable;
@synthesize audioPlayer;
@synthesize addButton;
@synthesize addMenu;
@synthesize audioIdSelected;

- (id) init {
    if(self = [super init]) {
        self.title = NSLocalizedString(@"VideofyAddMusic", @"");
        self.view.backgroundColor = [UIColor whiteColor];
        
        audioDao = [[VideofyAudioListDao alloc] init];
        audioDao.delegate = self;
        audioDao.successMethod = @selector(audioListSuccessCallback:);
        audioDao.failMethod = @selector(audioListFailCallback:);
        
        audioTable = [[UITableView alloc] initWithFrame:CGRectMake(0, self.topIndex, self.view.frame.size.width, self.view.frame.size.height - self.bottomIndex) style:UITableViewStylePlain];
        audioTable.delegate = self;
        audioTable.dataSource = self;
        audioTable.backgroundColor = [UIColor clearColor];
        audioTable.backgroundView = nil;
        audioTable.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self.view addSubview:audioTable];
        
        [audioDao requestAudioList];
        [self showLoading];

        self.addMenu = [[FloatingAddMenu alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) withBasePoint:CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height - 125)];
        addMenu.hidden = YES;
        addMenu.delegate = self;
        [addMenu loadButtons:[NSArray arrayWithObjects:@"AddTypeDepoMusicFav", nil]];
        [self.view addSubview:addMenu];

        self.addButton = [[FloatingAddButton alloc] initWithFrame:CGRectMake((self.view.frame.size.width - 70)/2, self.view.frame.size.height - 160, 70, 70)];
        addButton.delegate = self;
        [self.view addSubview:addButton];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    CustomButton *cancelButton = [[CustomButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30) withImageName:@"icon_ustbar_close.png"];
    [cancelButton addTarget:self action:@selector(triggerDismiss) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithCustomView:cancelButton];
    self.navigationItem.leftBarButtonItem = cancelItem;

    CustomButton *nextButton = [[CustomButton alloc] initWithFrame:CGRectMake(0, 0, 40, 20) withImageName:nil withTitle:NSLocalizedString(@"Add", @"") withFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:18] withColor:[UIColor whiteColor]];
    [nextButton addTarget:self action:@selector(triggerDone) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *nextItem = [[UIBarButtonItem alloc] initWithCustomView:nextButton];
    self.navigationItem.rightBarButtonItem = nextItem;
}

- (void) triggerDone {
    if(audioIdSelected > 0) {
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:[NSNumber numberWithLong:audioIdSelected] forKey:@"audio_file_selected"];
        [[NSNotificationCenter defaultCenter] postNotificationName:VIDEOFY_DEPO_MUSIC_SELECTED_NOTIFICATION object:nil userInfo:userInfo];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) audioListSuccessCallback:(NSArray *) list {
    [self hideLoading];
    self.audioList = list;
    [self.audioTable reloadData];
}

- (void) audioListFailCallback:(NSString *) errorMessage {
    [self hideLoading];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [audioList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier = [NSString stringWithFormat:@"AUDIO_CELL_%d", (int)indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if(!cell) {
        VideofyAudio *audio = [audioList objectAtIndex:indexPath.row];
        cell = [[VideofyAudioCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier withAudio:audio];
        ((VideofyAudioCell *) cell).delegate = self;
    }
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    VideofyAudio *audio = [audioList objectAtIndex:indexPath.row];
    audioIdSelected = audio.audioId;
}

- (void)videofyAudioCellPlayClickedWithId:(long)audioId {
    NSDictionary* userInfo = [NSDictionary dictionaryWithObject:[NSNumber numberWithLong:audioId] forKey:@"playingAudioId"];
    [[NSNotificationCenter defaultCenter] postNotificationName:VIDEOFY_MUSIC_PREVIEW_CHANGED_NOTIFICATION object:self userInfo:userInfo];
    
    if(audioPlayer) {
        [audioPlayer pause];
        audioPlayer = nil;
    }

    AVPlayerItem *item = nil;
    for(VideofyAudio *audio in self.audioList) {
        if(audio.audioId == audioId) {
            item = [[AVPlayerItem alloc] initWithURL:[NSURL URLWithString:audio.path]];
        }
    }
    audioPlayer = [[AVPlayer alloc] initWithPlayerItem:item];
    [audioPlayer play];
}

- (void) videofyAudioCellPauseClickedWithId:(long)audioId {
    [audioPlayer pause];
}

- (void) floatingAddButtonDidOpenMenu {
    addMenu.hidden = NO;
    [addMenu presentWithAnimation];
}

- (void) floatingAddButtonDidCloseMenu {
    [addMenu dismissWithAnimation];
    [self performSelector:@selector(hideAddMenu) withObject:nil afterDelay:0.3];
}

- (void) hideAddMenu {
    addMenu.hidden = YES;
}

- (void) floatingMenuDidTriggerAddMusicFromDepo {
    VideofyDepoMusicModalController *musicController = [[VideofyDepoMusicModalController alloc] init];
    [self.navigationController pushViewController:musicController animated:YES];

    [addButton immediateReset];
    addMenu.hidden = YES;
    [addMenu dismissWithAnimation];
}

- (void) musicModalListReturnedWithSelectedList:(NSArray *) uuids {
}

@end
