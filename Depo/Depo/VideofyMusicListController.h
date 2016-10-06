//
//  VideofyMusicListController.h
//  Depo
//
//  Created by Mahir Tarlan on 08/07/16.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import "MyModalController.h"
#import "VideofyAudioListDao.h"
#import "VideofyAudio.h"
#import "VideofyAudioCell.h"
#import <AVFoundation/AVFoundation.h>
#import "FloatingAddButton.h"
#import "FloatingAddMenu.h"
#import "Story.h"

@interface VideofyMusicListController : MyModalController <UITableViewDelegate, UITableViewDataSource, VideofyAudioCellDelegate, FloatingAddButtonDelegate, FloatingAddDelegate>

@property (nonatomic, strong) VideofyAudioListDao *audioDao;
@property (nonatomic, strong) NSArray *audioList;
@property (nonatomic, strong) UITableView *audioTable;
@property (nonatomic, strong) AVPlayer *audioPlayer;
@property (nonatomic, strong) FloatingAddButton *addButton;
@property (nonatomic, strong) FloatingAddMenu *addMenu;
@property (nonatomic) long audioIdSelected;
@property (nonatomic, strong) Story *story;

- (id) initWithStory:(Story *) _story;

@end
