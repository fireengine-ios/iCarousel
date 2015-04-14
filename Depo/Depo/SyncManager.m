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
#import "ALAssetRepresentation+MD5.h"
#import "SyncUtil.h"
#import "UploadRef.h"
#import "UploadManager.h"
#import "AppDelegate.h"
#import "UploadQueue.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "ReachabilityManager.h"
#import "Reachability.h"

@implementation SyncManager

@synthesize assetsLibrary;
@synthesize elasticSearchDao;
@synthesize locManager;
@synthesize autoSyncIterationInProgress;

- (id) init {
    if(self = [super init]) {
        elasticSearchDao = [[ElasticSearchDao alloc] init];
        elasticSearchDao.delegate = self;
        elasticSearchDao.successMethod = @selector(photoListSuccessCallback:);
        elasticSearchDao.failMethod = @selector(photoListFailCallback:);

        self.assetsLibrary = [[ALAssetsLibrary alloc] init];
        
         [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityDidChange) name:kReachabilityChangedNotification object:nil];
    }
    return self;
}

- (void) startFirstTimeSync {
    if(autoSyncIterationInProgress)
        return;

    [elasticSearchDao requestPhotosForPage:0 andSize:20000 andSortType:SortTypeAlphaAsc];
    autoSyncIterationInProgress = YES;
}

- (void) photoListSuccessCallback:(NSArray *) files {
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        NSMutableArray *summaryArray = [[NSMutableArray alloc] init];
        NSMutableArray *hashArray = [[NSMutableArray alloc] init];
        for(MetaFile *row in files) {
            if(row.metaHash != nil) {
                [hashArray addObject:row.metaHash];
            }
            MetaFileSummary *fileSummary = [[MetaFileSummary alloc] init];
            fileSummary.bytes = row.bytes;
            fileSummary.fileName = row.name;
            [summaryArray addObject:fileSummary];
        }
        if([summaryArray count] > 0) {
            [SyncUtil cacheSyncFileSummaries:summaryArray];
        }
        if([hashArray count] > 0) {
            [SyncUtil cacheSyncHashesRemotely:hashArray];
        }
        autoSyncIterationInProgress = NO;
        [self initializeNextAutoSyncPackage];
    });
}

- (void) initializeNextAutoSyncPackage {
    if(autoSyncIterationInProgress)
        return;

    EnableOption photoSyncFlag = (EnableOption)[CacheUtil readCachedSettingSyncPhotosVideos];
    
    BOOL triggerSyncing = NO;
    if(photoSyncFlag == EnableOptionAuto || photoSyncFlag == EnableOptionOn) {
        ConnectionOption connectionOption = (ConnectionOption)[CacheUtil readCachedSettingSyncingConnectionType];
        if([ReachabilityManager isReachableViaWiFi]) {
            triggerSyncing = YES;
        } else if([ReachabilityManager isReachableViaWWAN] && connectionOption == ConnectionOptionWifi3G) {
            triggerSyncing = YES;
        }
    }
    
    if(triggerSyncing) {
        NSArray *remoteHashList = [SyncUtil readSyncHashRemotely];
        NSArray *remoteSummaryList = [SyncUtil readSyncFileSummaries];
        NSMutableDictionary *bgOngoingTasks = [SyncUtil readOngoingTasks];
        
        NSTimeInterval timeInMiliseconds1 = [[NSDate date] timeIntervalSince1970];
        NSLog(@"startFirstTimeSync Start: %f", timeInMiliseconds1);
        
        autoSyncIterationInProgress = YES;
        [self.assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
            if(group) {
                int startIndex = [SyncUtil readAutoSyncIndex] * AUTO_SYNC_ASSET_COUNT;
                int length = AUTO_SYNC_ASSET_COUNT;
                if(startIndex + length > [group numberOfAssets]) {
                    length = (int)[group numberOfAssets] - startIndex;
                }
                NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(startIndex, length)];
                NSLog(@"AUTO SYNC INDEX: %@", indexSet);
                [group enumerateAssetsAtIndexes:indexSet options:0 usingBlock:^(ALAsset *asset, NSUInteger index, BOOL *stop) {
                    if(asset) {
                        EnableOption photoSyncFlag = (EnableOption)[CacheUtil readCachedSettingSyncPhotosVideos];
                        if(photoSyncFlag == EnableOptionAuto || photoSyncFlag == EnableOptionOn) {
                            ConnectionOption connectionOption = (ConnectionOption)[CacheUtil readCachedSettingSyncingConnectionType];
                            if([ReachabilityManager isReachableViaWiFi] || ([ReachabilityManager isReachableViaWWAN] && connectionOption == ConnectionOptionWifi3G)) {
                                NSString *localHash = [SyncUtil md5StringOfString:[asset.defaultRepresentation.url absoluteString]];
                                BOOL serverContainsImageFlag = [remoteHashList containsObject:localHash];
                                if(!serverContainsImageFlag) {
                                    ALAssetRepresentation *defaultRep = [asset defaultRepresentation];
                                    NSString *assetFileName = [defaultRep filename];
                                    for(MetaFileSummary *summary in remoteSummaryList) {
                                        if([summary.fileName isEqualToString:assetFileName] && summary.bytes == [defaultRep size]) {
                                            serverContainsImageFlag = YES;
                                        }
                                    }
                                }
                                serverContainsImageFlag = ([bgOngoingTasks objectForKey:asset.defaultRepresentation.filename] != nil);
                                if(!serverContainsImageFlag) {
                                    NSLog(@"auto upload started for index: %d", (int) index);
                                    [self startUploadForAsset:asset andLocalHash:localHash];
                                    [SyncUtil lockAutoSyncBlockInProgress];
                                    [SyncUtil writeFirstTimeSyncFlag];
                                    [SyncUtil updateLastSyncDate];
                                }
                            }
                        }
                    } else {
                        [SyncUtil increaseAutoSyncIndex];
                        //check and set if no enumeration left
                        if([SyncUtil readAutoSyncIndex] * AUTO_SYNC_ASSET_COUNT >= [group numberOfAssets]) {
                            [SyncUtil writeFirstTimeSyncFinishedFlag];
                        }
                    }
                }];
            } else {
                [self firstTimeBlockSyncEnumerationFinished];
                autoSyncIterationInProgress = NO;
            }
        } failureBlock:^(NSError *error) {
        }];
    }
}

- (void) photoListFailCallback:(NSString *) errorMessage {
    autoSyncIterationInProgress = NO;
}

- (void) firstTimeBlockSyncEnumerationFinished {
    NSTimeInterval timeInMiliseconds2 = [[NSDate date] timeIntervalSince1970];
    NSLog(@"End: %f", timeInMiliseconds2);
    [SyncUtil writeFirstTimeSyncFlag];
    [SyncUtil updateLastSyncDate];

    dispatch_async(dispatch_get_main_queue(), ^{
        if(![SyncUtil readFirstTimeSyncFinishedFlag] && ![SyncUtil readAutoSyncBlockInProgress]) {
            [self initializeNextAutoSyncPackage];
        }
    });
}

- (void) manuallyCheckIfAlbumChanged {
    NSLog(@"manuallyCheckIfAlbumChanged called");
    if(autoSyncIterationInProgress)
        return;
    
    EnableOption photoSyncFlag = (EnableOption)[CacheUtil readCachedSettingSyncPhotosVideos];

    BOOL triggerSyncing = NO;
    if(photoSyncFlag == EnableOptionAuto || photoSyncFlag == EnableOptionOn) {
        ConnectionOption connectionOption = (ConnectionOption)[CacheUtil readCachedSettingSyncingConnectionType];
        if([ReachabilityManager isReachableViaWiFi]) {
            triggerSyncing = YES;
        } else if([ReachabilityManager isReachableViaWWAN] && connectionOption == ConnectionOptionWifi3G) {
            triggerSyncing = YES;
        }
    }
    
    if(triggerSyncing) {
        NSArray *localHashList = [SyncUtil readSyncHashLocally];
        NSLog(@"local hash: %@", localHashList);
        NSArray *remoteHashList = [SyncUtil readSyncHashRemotely];
        NSLog(@"remote hash: %@", remoteHashList);
        NSArray *remoteSummaryList = [SyncUtil readSyncFileSummaries];
        NSMutableDictionary *bgOngoingTasks = [SyncUtil readOngoingTasks];
        
        NSTimeInterval timeInMilisecondsStart = [[NSDate date] timeIntervalSince1970];
        NSLog(@"auto sync start: %f", timeInMilisecondsStart);

        autoSyncIterationInProgress = YES;
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
            [self.assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
                if(group) {
                    [group enumerateAssetsUsingBlock:^(ALAsset *asset, NSUInteger index, BOOL *stop) {
                        if(asset) {
                            EnableOption photoSyncFlag = (EnableOption)[CacheUtil readCachedSettingSyncPhotosVideos];
                            if(photoSyncFlag == EnableOptionAuto || photoSyncFlag == EnableOptionOn) {
                                ConnectionOption connectionOption = (ConnectionOption)[CacheUtil readCachedSettingSyncingConnectionType];
                                if([ReachabilityManager isReachableViaWiFi] || ([ReachabilityManager isReachableViaWWAN] && connectionOption == ConnectionOptionWifi3G)) {
//                                    NSString *localHash = [asset.defaultRepresentation MD5];
                                    NSString *localHash = [SyncUtil md5StringOfString:[asset.defaultRepresentation.url absoluteString]];
                                    NSLog(@"Calculated local hash:%@", localHash);
                                    BOOL shouldStartUpload = ![localHashList containsObject:localHash] && ![remoteHashList containsObject:localHash] && ([APPDELEGATE.uploadQueue uploadRefForAsset:[asset.defaultRepresentation.url absoluteString]] == nil) && ([bgOngoingTasks objectForKey:asset.defaultRepresentation.filename] == nil);
                                    if(shouldStartUpload) {
                                        ALAssetRepresentation *defaultRep = [asset defaultRepresentation];
                                        NSString *assetFileName = [defaultRep filename];
                                        for(MetaFileSummary *summary in remoteSummaryList) {
                                            NSLog(@"SUMMARY ROW FILENAME:%@ AND BYTES:%lld", summary.fileName, summary.bytes);
                                            NSLog(@"SUMMARY CURRENT ASSET:%@ AND BYTES:%lld", assetFileName, [defaultRep size]);
                                            if([summary.fileName isEqualToString:assetFileName] && summary.bytes == [defaultRep size]) {
                                                shouldStartUpload = NO;
                                            }
                                        }
                                    }
                                    if(shouldStartUpload) {
                                        [self startUploadForAsset:asset andLocalHash:localHash];
                                    }
                                }
                            }
                        }
                    }];
                } else {
                    NSTimeInterval timeInMilisecondsEnd = [[NSDate date] timeIntervalSince1970];
                    NSLog(@"auto sync end: %f", timeInMilisecondsEnd);
                    [SyncUtil writeLastSyncDate:[NSDate date]];
                    autoSyncIterationInProgress = NO;
//                    [APPDELEGATE.uploadQueue startReadyTasks];
                }
            } failureBlock:^(NSError *error) {
            }];
        });
        
    }
}

- (void) startUploadForAsset:(ALAsset *) asset andLocalHash:(NSString *) localHash {
    NSString *mimeType = (__bridge_transfer NSString*)UTTypeCopyPreferredTagWithClass
    ((__bridge CFStringRef)[asset.defaultRepresentation UTI], kUTTagClassMIMEType);

    NSLog(@"At startUploadForAsset for hash: %@", localHash);
    if(asset.defaultRepresentation.url != nil && [asset.defaultRepresentation.url absoluteString] != nil) {
        NSLog(@"At startUploadForAsset asset.defaultRepresentation.url not null");
        MetaFileSummary *summary = [[MetaFileSummary alloc] init];
        summary.fileName = [asset.defaultRepresentation filename];
        summary.bytes = [asset.defaultRepresentation size];
        
        UploadRef *ref = [[UploadRef alloc] init];
        ref.localHash = localHash;
        ref.fileName = asset.defaultRepresentation.filename;
        ref.filePath = [asset.defaultRepresentation.url absoluteString];
        ref.autoSyncFlag = YES;
        ref.ownerPage = UploadStarterPageAuto;
        ref.folderUuid = APPDELEGATE.session.user.mobileUploadFolderUuid;
        ref.summary = summary;
        ref.mimeType = mimeType;
        
        if ([[asset valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypeVideo]) {
            ref.contentType = ContentTypeVideo;
        } else {
            ref.contentType = ContentTypePhoto;
        }
        
        UploadManager *manager = [[UploadManager alloc] initWithUploadInfo:ref];
        [manager configureUploadAsset:ref.filePath atFolder:nil];
        [APPDELEGATE.uploadQueue addNewUploadTask:manager];
    }
}

- (void) reachabilityDidChange {
    BOOL triggerAutoSync = NO;
    EnableOption photoSyncFlag = (EnableOption)[CacheUtil readCachedSettingSyncPhotosVideos];
    if(photoSyncFlag == EnableOptionAuto || photoSyncFlag == EnableOptionOn) {
        ConnectionOption connectionOption = (ConnectionOption)[CacheUtil readCachedSettingSyncingConnectionType];
        if([ReachabilityManager isReachableViaWiFi]) {
            //auto sync çalışmalıdır
            triggerAutoSync = YES;
        } else if([ReachabilityManager isReachableViaWWAN]) {
            if(connectionOption == ConnectionOptionWifi3G) {
                //auto sync çalışmalıdır
                triggerAutoSync = YES;
            } else if(connectionOption == ConnectionOptionWifi) {
                //auto sync çalışmamalı ve queue'dakiler de temizlenmelidir
                [APPDELEGATE.uploadQueue cancelRemainingUploads];
            }
        }
    }

    if(triggerAutoSync) {
        [self decideAndStartAutoSync];
    }
}

- (void) decideAndStartAutoSync {
    if(![SyncUtil readFirstTimeSyncFlag]) {
        [self startFirstTimeSync];
    } else if(![SyncUtil readFirstTimeSyncFinishedFlag]) {
        if(![SyncUtil readAutoSyncBlockInProgress]) {
            [self initializeNextAutoSyncPackage];
        }
    } else {
        [self manuallyCheckIfAlbumChanged];
    }
}

@end
