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
#import "ALAssetRepresentation+MD5.h"
#import "SyncUtil.h"

@implementation SyncManager

@synthesize assetsLibrary;
@synthesize elasticSearchDao;

- (id) init {
    if(self = [super init]) {
        elasticSearchDao = [[ElasticSearchDao alloc] init];
        elasticSearchDao.delegate = self;
        elasticSearchDao.successMethod = @selector(photoListSuccessCallback:);
        elasticSearchDao.failMethod = @selector(photoListFailCallback:);

        self.assetsLibrary = [[ALAssetsLibrary alloc] init];
        
        //TODO aç
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(albumChanged:) name:ALAssetsLibraryChangedNotification object:nil];
    }
    return self;
}

- (void) startFirstTimeSync {
    [elasticSearchDao requestPhotosForPage:0 andSize:10000 andSortType:SortTypeAlphaAsc];
}

- (void) photoListSuccessCallback:(NSArray *) files {
    for(MetaFile *row in files) {
        [SyncUtil cacheSyncHashRemotely:row.hash];
    }

    NSArray *remoteHashList = [SyncUtil readSyncHashRemotely];
    
    NSTimeInterval timeInMiliseconds1 = [[NSDate date] timeIntervalSince1970];
    NSLog(@"Start: %f", timeInMiliseconds1);
    [assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll | ALAssetsGroupLibrary usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        if(group) {
            [group enumerateAssetsUsingBlock:^(ALAsset *asset, NSUInteger index, BOOL *stop) {
                if(asset) {
                    NSString *localHash = [asset.defaultRepresentation MD5];
                    [SyncUtil cacheSyncHashLocally:localHash];

                    NSString *remoteCalcHash = nil;
                    if ([[asset valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypeVideo]) {
                        ALAssetRepresentation *rep = [asset defaultRepresentation];
                        Byte *buffer = (Byte*)malloc(rep.size);
                        NSUInteger buffered = [rep getBytes:buffer fromOffset:0.0 length:rep.size error:nil];
                        NSData *videoData = [NSData dataWithBytesNoCopy:buffer length:buffered freeWhenDone:YES];
                        remoteCalcHash = [SyncUtil md5String:videoData];
                    } else {
                        ALAssetOrientation imgOrientation = [[asset valueForProperty:@"ALAssetPropertyOrientation"] intValue];
                        UIImage *image = [UIImage imageWithCGImage:[asset.defaultRepresentation fullResolutionImage] scale:1.0 orientation:imgOrientation];
                        remoteCalcHash = [SyncUtil md5String:UIImagePNGRepresentation(image)];
                    }
                    if(![remoteHashList containsObject:remoteCalcHash]) {
                        //TODO start uploading for asset
                        [SyncUtil cacheSyncHashRemotely:remoteCalcHash];
                    }

                }
            }];
        } else {
            [self firstTimeSyncStartFinalized];
        }
    } failureBlock:^(NSError *error) {
    }];

}

- (void) photoListFailCallback:(NSString *) errorMessage {
}

- (void) firstTimeSyncStartFinalized {
    NSTimeInterval timeInMiliseconds2 = [[NSDate date] timeIntervalSince1970];
    NSLog(@"End: %f", timeInMiliseconds2);
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
        }
        NSArray *localHashList = [SyncUtil readSyncHashLocally];
        
        [self.assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll | ALAssetsGroupLibrary usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
            if(group) {
                [group enumerateAssetsUsingBlock:^(ALAsset *asset, NSUInteger index, BOOL *stop) {
                    if(asset) {
                        NSString *localHash = [asset.defaultRepresentation MD5];
                        if(![localHashList containsObject:localHash]) {
                            //TODO start uploading for asset
                            [SyncUtil cacheSyncHashLocally:localHash];
                        }
                    }
                }];
            }
        } failureBlock:^(NSError *error) {
        }];
    }
}

@end
