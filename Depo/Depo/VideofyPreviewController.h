//
//  VideofyPreviewController.h
//  Depo
//
//  Created by Mahir Tarlan on 26/07/16.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import "MyModalController.h"
#import "Story.h"
#import "CustomAVPlayer.h"
#import "VideofyCreateDao.h"

@interface VideofyPreviewController : MyModalController <CustomAVPlayerDelegate>

@property (nonatomic, strong) Story *story;
@property (nonatomic, strong) CustomAVPlayer *avPlayer;
@property (nonatomic, strong) VideofyCreateDao *createDao;

- (id) initWithStory:(Story *) _story;

@end
