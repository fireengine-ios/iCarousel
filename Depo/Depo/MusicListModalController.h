//
//  MusicListModalController.h
//  Depo
//
//  Created by Mahir on 10/3/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "MyModalController.h"
#import <MediaPlayer/MediaPlayer.h>

@interface MusicListModalController : MyModalController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSArray *songs;
@property (nonatomic, strong) UITableView *songTable;
@property (nonatomic, strong) MPMediaQuery *songQuery;

@end
