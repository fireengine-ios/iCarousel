//
//  AppSession.m
//  Depo
//
//  Created by Mahir on 9/18/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "AppSession.h"
#import "UploadManager.h"

@implementation AppSession

@synthesize user;
@synthesize authToken;
@synthesize baseUrl;
@synthesize uploadManagers;
@synthesize sortType;
@synthesize playerItemFilesRef;
@synthesize playerItems;
@synthesize playerItem;
@synthesize audioPlayer;
@synthesize currentAudioItemIndex;

- (id) init {
    if(self = [super init]) {
        self.uploadManagers = [[NSMutableArray alloc] init];
        self.sortType = SortTypeAlphaDesc;

        //TODO
        self.user = [[User alloc] init];
        self.user.profileImgUrl = @"http://s.turkcell.com.tr/profile_img/532/225/cjXlJsupflKCNP2jmf23A.jpg?wruN55vtoNoCItHngeSqW9QN4XM1Y9qgZHRnZnp8bGOut1pQZOk1!207944990!1411130039277";
        self.user.fullName = @"Mahir Kemal Tarlan";
        self.user.msisdn = @"5322102103";
        self.user.password = @"5322102103";
        //5322102103 for ios
        //5322109094 for presentation
    }
    return self;
}

- (NSArray *) uploadRefsForFolder:(NSString *) folderUuid {
    NSMutableArray *result = [[NSMutableArray alloc] init];
    for(UploadManager *manager in self.uploadManagers) {
        if(!manager.hasFinished) {
            if(manager.uploadRef.folderUuid == nil && folderUuid == nil) {
                [result addObject:manager.uploadRef];
            } else if([folderUuid isEqualToString:manager.uploadRef.folderUuid]){
                [result addObject:manager.uploadRef];
            }
        }
    }
    return result;
}

- (NSArray *) uploadImageRefs {
    NSMutableArray *result = [[NSMutableArray alloc] init];
    for(UploadManager *manager in self.uploadManagers) {
        if(!manager.hasFinished) {
            if(manager.uploadRef.contentType == ContentTypePhoto || manager.uploadRef.contentType == ContentTypeVideo) {
                [result addObject:manager.uploadRef];
            }
        }
    }
    return result;
}

- (NSArray *) uploadImageRefsForAlbum:(NSString *) albumUuid {
    NSMutableArray *result = [[NSMutableArray alloc] init];
    for(UploadManager *manager in self.uploadManagers) {
        if(!manager.hasFinished && [manager.uploadRef.albumUuid isEqualToString:albumUuid]) {
            if(manager.uploadRef.contentType == ContentTypePhoto || manager.uploadRef.contentType == ContentTypeVideo) {
                [result addObject:manager.uploadRef];
            }
        }
    }
    return result;
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
        [self.audioPlayer replaceCurrentItemWithPlayerItem:self.playerItem];
    }
    [self.audioPlayer seekToTime:kCMTimeZero];
    [self.audioPlayer play];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(queueItemDidReachEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.playerItem];

    [[NSNotificationCenter defaultCenter] postNotificationName:MUSIC_CHANGED_NOTIFICATION object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[self itemRefForCurrentAsset], CHANGED_MUSIC_OBJ_KEY, nil]];
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

- (void) queueItemDidReachEnd:(NSNotification *)notification {
    AVPlayerItem *lastItem = [notification object];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:lastItem];
    
    if(self.currentAudioItemIndex + 1 < [self.playerItems count]) {
        [self playAudioItemAtIndex:self.currentAudioItemIndex + 1];
    }
}

@end
