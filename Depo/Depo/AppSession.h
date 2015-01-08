//
//  AppSession.h
//  Depo
//
//  Created by Mahir on 9/18/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"
#import "AppConstants.h"
#import <AVFoundation/AVFoundation.h>
#import "NSMutableArray_Shuffling.h"
#import "MetaFile.h"
#import "Usage.h"

@interface AppSession : NSObject

@property (nonatomic, strong) User *user;
@property (nonatomic, strong) NSString *authToken;
@property (nonatomic, strong) NSString *baseUrl;
@property (nonatomic) SortType sortType;

@property (nonatomic, strong) NSArray *playerItemFilesRef;
@property (nonatomic, strong) NSMutableArray *playerItems;
@property (nonatomic, strong) AVPlayerItem *playerItem;
@property (nonatomic, strong) AVPlayer *audioPlayer;
@property (nonatomic) int currentAudioItemIndex;

@property (nonatomic, strong) Usage *usage;

- (void) playAudioItemAtIndex:(int) itemIndex;
- (void) playNextAudioItem;
- (void) playPreviousAudioItem;
- (void) playAudioItem;
- (void) pauseAudioItem;
- (void) shuffleItems;
- (MetaFile *) itemRefForCurrentAsset;

@end
