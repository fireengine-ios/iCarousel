//
//  SyncManager.m
//  Depo
//
//  Created by Mahir on 24.12.2014.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "SyncManager.h"
#import "CacheUtil.h"
#import "AppConstants.h"
#import "Reachability.h"

@implementation SyncManager

@synthesize assetsLibrary;

- (id) init {
    if(self = [super init]) {
        self.assetsLibrary = [[ALAssetsLibrary alloc] init];
        
        //TODO aç
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(albumChanged:) name:ALAssetsLibraryChangedNotification object:nil];
    }
    return self;
}

- (void) albumChanged:(NSNotification *) not {
    //TODO uncomment
    NSLog(@"At albumChanged");
    
    EnableOption photoSyncFlag = EnableOptionOn;//(EnableOption)[CacheUtil readCachedSettingSyncPhotosVideos];

    BOOL triggerSyncing = NO;
    if(photoSyncFlag == EnableOptionAuto || photoSyncFlag == EnableOptionOn) {
        NSLog(@"Album is changed and flag is on");
        NetworkStatus networkStatus = [[Reachability reachabilityForInternetConnection] currentReachabilityStatus];
        ConnectionOption connectionOption = (ConnectionOption)[CacheUtil readCachedSettingSyncingConnectionType];
        if(networkStatus == kReachableViaWiFi) {
            triggerSyncing = YES;
        } else if(networkStatus == kReachableViaWWAN && connectionOption == ConnectionOptionWifi3G) {
            triggerSyncing = YES;
        }
    }
    
    if(triggerSyncing) {
        if ([not userInfo]) {
            NSLog(@"NOT USERINFO: %@", [not userInfo]);

            [self.assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll | ALAssetsGroupLibrary usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
                if(group) {
                    [group enumerateAssetsUsingBlock:^(ALAsset *asset, NSUInteger index, BOOL *stop) {
                        if(asset) {
                            NSLog(@"%@", [[asset defaultRepresentation] url]);
                        }
                    }];
                }
            } failureBlock:^(NSError *error) {
            }];
        }
    }
}

@end
