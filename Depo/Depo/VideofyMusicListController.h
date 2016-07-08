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

@interface VideofyMusicListController : MyModalController <UITableViewDelegate, UITableViewDataSource, VideofyAudioCellDelegate>

@property (nonatomic, strong) VideofyAudioListDao *audioDao;
@property (nonatomic, strong) NSArray *audioList;
@property (nonatomic, strong) UITableView *audioTable;
@property (nonatomic, strong) AVPlayer *audioPlayer;

@end
