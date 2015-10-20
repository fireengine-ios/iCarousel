//
//  AppSession.m
//  Depo
//
//  Created by Mahir on 9/18/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "AppSession.h"
#import "UploadManager.h"
#import "CacheUtil.h"
#import "ContactSyncSDK.h"
#import "SyncUtil.h"
#import "SharedUtil.h"

@implementation AppSession

@synthesize user;
@synthesize authToken;
@synthesize baseUrl;
@synthesize baseUrlConstant;
@synthesize sortType;
@synthesize playerItemFilesRef;
@synthesize playerItems;
@synthesize playerItem;
@synthesize audioPlayer;
@synthesize currentAudioItemIndex;
@synthesize usage;
@synthesize newUserFlag;
@synthesize migrationUserFlag;
@synthesize syncResult;
@synthesize profileImageRef;
@synthesize mobileUploadsFolderName;
@synthesize syncType;
@synthesize shuffleFlag;
@synthesize bgOngoingTasksOriginalUrls;

- (id) init {
    if(self = [super init]) {
        self.sortType = SortTypeDateDesc;

        if([CacheUtil readRememberMeToken] != nil) {
            self.user = [[User alloc] init];
//            self.user.profileImgUrl = @"http://s.turkcell.com.tr/profile_img/532/225/cjXlJsupflKCNP2jmf23A.jpg?wruN55vtoNoCItHngeSqW9QN4XM1Y9qgZHRnZnp8bGOut1pQZOk1!207944990!1411130039277";
//            self.user.fullName = @"Mahir Kemal Tarlan";
        }
        
        //5322102103 for ios
        //5322109094 for presentation

        [self checkLatestContactSyncStatus];
    }
    return self;
}

- (void) playAudioItem {
    if(self.audioPlayer) {
        [self.audioPlayer play];
        [[NSNotificationCenter defaultCenter] postNotificationName:MUSIC_RESUMED_NOTIFICATION object:nil userInfo:nil];
    }
}

- (void) pauseAudioItem {
    if(self.audioPlayer) {
        [self.audioPlayer pause];
        [[NSNotificationCenter defaultCenter] postNotificationName:MUSIC_PAUSED_NOTIFICATION object:nil userInfo:nil];
    }
}

- (void) playAudioItemAtIndex:(int) itemIndex {
    self.currentAudioItemIndex = itemIndex;
    
    self.playerItem = [self.playerItems objectAtIndex:itemIndex];
    if(self.audioPlayer == nil) {
        self.audioPlayer = [AVPlayer playerWithPlayerItem:self.playerItem];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.audioPlayer replaceCurrentItemWithPlayerItem:self.playerItem];
        });
    }
    [self.audioPlayer seekToTime:kCMTimeZero];
    [self.audioPlayer play];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(queueItemDidReachEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.playerItem];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(queueItemDidFail) name:AVPlayerItemPlaybackStalledNotification object:self.playerItem];
    

    [[NSNotificationCenter defaultCenter] postNotificationName:MUSIC_CHANGED_NOTIFICATION object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[self itemRefForCurrentAsset], CHANGED_MUSIC_OBJ_KEY, nil]];
}

- (void) stopAudioItem {
    [self.audioPlayer pause];
    [[NSNotificationCenter defaultCenter] postNotificationName:MUSIC_SHOULD_BE_REMOVED_NOTIFICATION object:nil userInfo:nil];
}

- (BOOL) isPrevNextAvailable {
    return ([self.playerItems count] > 1);
}

- (void) playNextAudioItem {
    if(self.currentAudioItemIndex + 1 < [self.playerItems count]) {
        [self playAudioItemAtIndex:self.currentAudioItemIndex + 1];
    }
}

- (void) playPreviousAudioItem {
    if(self.currentAudioItemIndex - 1 >= 0) {
        [self playAudioItemAtIndex:self.currentAudioItemIndex - 1];
    }
}

- (void) playNextShuffledAudioItem {
    int nextRandom = arc4random_uniform([self.playerItems count]);
    while(nextRandom == self.currentAudioItemIndex) {
        nextRandom = arc4random_uniform([self.playerItems count]);
    }
    [self playAudioItemAtIndex:nextRandom];
}

- (void) playPreviousShuffleAudioItem {
    int prevRandom = arc4random_uniform([self.playerItems count]);
    while(prevRandom == self.currentAudioItemIndex) {
        prevRandom = arc4random_uniform([self.playerItems count]);
    }
    [self playAudioItemAtIndex:prevRandom];
}

- (void) shuffleItems {
    [playerItems shuffle];
    int newIndex = 0;
    for(AVPlayerItem *item in self.playerItems) {
        if([item isEqual:self.playerItem]) {
            break;
        }
        newIndex ++;
    }
    self.currentAudioItemIndex = newIndex;
}

- (MetaFile *) itemRefForCurrentAsset {
    AVAsset *currentAsset = self.playerItem.asset;
    if ([currentAsset isKindOfClass:AVURLAsset.class]) {
        NSString *urlStr = [[(AVURLAsset *)currentAsset URL] absoluteString];
        for(MetaFile *file in self.playerItemFilesRef) {
            if([file.tempDownloadUrl isEqualToString:urlStr]) {
                return file;
            }
        }
    }
    
    return nil;
}

- (void) modifyPlayerItemFavUnfavFlag:(BOOL) favUnfav forUuid:(NSString *) uuid {
    for(MetaFile *file in self.playerItemFilesRef) {
        if([file.uuid isEqualToString:uuid]) {
            file.detail.favoriteFlag = favUnfav;
        }
    }
}

- (void) queueItemDidReachEnd:(NSNotification *)notification {
    AVPlayerItem *lastItem = [notification object];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:lastItem];
    
    if(self.shuffleFlag) {
        [self playNextShuffledAudioItem];
    } else {
        [self playNextAudioItem];
    }
}

- (void) queueItemDidFail {
}

- (void) checkLatestContactSyncStatus {
    SyncStatus *status = [SyncStatus shared];
    if(status != nil) {
        if(status.status == SYNC_RESULT_SUCCESS) {
            ContactSyncResult *currentSyncResult = [[ContactSyncResult alloc] init];
            currentSyncResult.clientUpdateCount = status.updatedContactsReceived.count;
            currentSyncResult.serverUpdateCount = status.updatedContactsSent.count;
            currentSyncResult.clientNewCount = status.createdContactsReceived.count;
            currentSyncResult.serverNewCount = status.createdContactsSent.count;
            currentSyncResult.clientDeleteCount = status.deletedContactsOnDevice.count;
            currentSyncResult.serverDeleteCount = status.deletedContactsOnServer.count;
            self.syncResult = currentSyncResult;
            [SyncUtil writeLastContactSyncResult:currentSyncResult];
        }
    }
    if(self.syncResult == nil) {
        self.syncResult = [SyncUtil readLastContactSyncResult];
    }
}

- (void) cleanoutAfterLogout {
    self.user = nil;
    self.authToken = nil;
    self.baseUrl = nil;
    self.baseUrlConstant = nil;
    [SyncUtil resetBaseUrlConstant];
    [SharedUtil writeSharedToken:nil];
}

- (void) addBgOngoingTaskUrl:(NSString *) taskUrl {
    if(!bgOngoingTasksOriginalUrls) {
        bgOngoingTasksOriginalUrls = [[NSMutableArray alloc] init];
    }
    [bgOngoingTasksOriginalUrls addObject:taskUrl];
}

- (void) cleanBgOngoingTaskUrls {
    if(bgOngoingTasksOriginalUrls) {
        [bgOngoingTasksOriginalUrls removeAllObjects];
    }
}

- (BOOL) isUrlPresentInBgOngoingTaskUrls:(NSString *) taskUrl {
    if(bgOngoingTasksOriginalUrls) {
        return [bgOngoingTasksOriginalUrls containsObject:taskUrl];
    }
    return NO;
}

@end
