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
#import "AppUtil.h"

@implementation SyncManager

@synthesize assetsLibrary;
@synthesize elasticSearchDao;
@synthesize autoSyncIterationInProgress;

+ (SyncManager *) sharedInstance {
    static SyncManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[SyncManager alloc] init];
    });
    return sharedInstance;
}

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
        [elasticSearchDao requestPhotosForPage:0 andSize:20000 andSortType:SortTypeAlphaAsc];
        autoSyncIterationInProgress = YES;
    }
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
        NSArray *localHashList = [SyncUtil readSyncHashLocally];
        NSArray *remoteHashList = [SyncUtil readSyncHashRemotely];
        NSArray *remoteSummaryList = [SyncUtil readSyncFileSummaries];
        
        NSTimeInterval timeInMilisecondsStart = [[NSDate date] timeIntervalSince1970];
        NSLog(@"FirstTimeSync Start: %f", timeInMilisecondsStart);
        
        autoSyncIterationInProgress = YES;
        [self.assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
            if(group) {
                int startIndex = [SyncUtil readAutoSyncIndex];
                //check and set "finished flag" to TRUE if no enumeration is left
                if(startIndex >= [group numberOfAssets]) {
                    [SyncUtil writeFirstTimeSyncFinishedFlag];
                } else {
                    int length = AUTO_SYNC_ASSET_COUNT;
                    if(startIndex + length > [group numberOfAssets]) {
                        length = (int)[group numberOfAssets] - startIndex;
                    }
                    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(startIndex, length)];
                    [group enumerateAssetsAtIndexes:indexSet options:0 usingBlock:^(ALAsset *asset, NSUInteger index, BOOL *stop) {
                        if(asset && [[asset valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypePhoto]) {
                            EnableOption photoSyncFlag = (EnableOption)[CacheUtil readCachedSettingSyncPhotosVideos];
                            if(photoSyncFlag == EnableOptionAuto || photoSyncFlag == EnableOptionOn) {
                                ConnectionOption connectionOption = (ConnectionOption)[CacheUtil readCachedSettingSyncingConnectionType];
                                if([ReachabilityManager isReachableViaWiFi] || ([ReachabilityManager isReachableViaWWAN] && connectionOption == ConnectionOptionWifi3G)) {
                                    
                                    ALAssetRepresentation *defaultRep = [asset defaultRepresentation];
                                    NSString *localHash = [SyncUtil md5StringOfString:[defaultRep.url absoluteString]];
                                    
                                    BOOL serverContainsImageFlag = [remoteHashList containsObject:localHash] || [localHashList containsObject:localHash];
                                    
                                    if(!serverContainsImageFlag) {
                                        MetaFileSummary *assetSummary = [[MetaFileSummary alloc] init];
                                        assetSummary.bytes = [defaultRep size];
                                        assetSummary.fileName = [defaultRep filename];
                                        serverContainsImageFlag = [remoteSummaryList containsObject:assetSummary];
                                    }
                                    if(!serverContainsImageFlag) {
                                        NSLog(@"auto upload started for image: %@", defaultRep.filename);
                                        [self startUploadForAsset:asset andLocalHash:localHash];
                                        [SyncUtil lockAutoSyncBlockInProgress];
                                        [SyncUtil updateLastSyncDate];
                                    } else {
                                        [SyncUtil increaseAutoSyncIndex];
                                    }
                                }
                            }
                        } else if(!asset) {
                            //check and set "finished flag" to TRUE if no enumeration is left
                            if([SyncUtil readAutoSyncIndex] >= [group numberOfAssets]) {
                                [SyncUtil writeFirstTimeSyncFinishedFlag];
                            }
                        }
                    }];
                }
            } else {
                autoSyncIterationInProgress = NO;
                [self firstTimeBlockSyncEnumerationFinished];
                [[UploadQueue sharedInstance] manualAutoSyncIterationFinished];
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
    NSLog(@"ManuallyCheckIfAlbumChanged called");
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
        NSLog(@"Local Hash List: %@", localHashList);
        NSArray *remoteHashList = [SyncUtil readSyncHashRemotely];
        NSArray *remoteSummaryList = [SyncUtil readSyncFileSummaries];
        
        NSTimeInterval timeInMilisecondsStart = [[NSDate date] timeIntervalSince1970];
        NSLog(@"Auto Sync Start: %f", timeInMilisecondsStart);

        autoSyncIterationInProgress = YES;
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
            [self.assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
                if(group) {
                    [group enumerateAssetsUsingBlock:^(ALAsset *asset, NSUInteger index, BOOL *stop) {
                        if(asset && [[asset valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypePhoto]) {
                            EnableOption photoSyncFlag = (EnableOption)[CacheUtil readCachedSettingSyncPhotosVideos];
                            if(photoSyncFlag == EnableOptionAuto || photoSyncFlag == EnableOptionOn) {
                                ConnectionOption connectionOption = (ConnectionOption)[CacheUtil readCachedSettingSyncingConnectionType];
                                if([ReachabilityManager isReachableViaWiFi] || ([ReachabilityManager isReachableViaWWAN] && connectionOption == ConnectionOptionWifi3G)) {

                                    ALAssetRepresentation *defaultRep = [asset defaultRepresentation];
                                    NSString *localHash = [SyncUtil md5StringOfString:[defaultRep.url absoluteString]];

                                    BOOL shouldStartUpload = ![localHashList containsObject:localHash] && ![remoteHashList containsObject:localHash];

                                    if(shouldStartUpload) {
                                        MetaFileSummary *assetSummary = [[MetaFileSummary alloc] init];
                                        assetSummary.bytes = [defaultRep size];
                                        assetSummary.fileName = [defaultRep filename];
                                        shouldStartUpload = ![remoteSummaryList containsObject:assetSummary];
                                    }
                                    if(shouldStartUpload) {
                                        NSLog(@"At ManuallyCheckIfAlbumChanged : starting upload for asset: %@ with hash: %@", asset.defaultRepresentation.filename, localHash);
                                        [[SyncManager sharedInstance] startUploadForAsset:asset andLocalHash:localHash];
                                    }
                                }
                            }
                        }
                    }];
                } else {
                    NSTimeInterval timeInMilisecondsEnd = [[NSDate date] timeIntervalSince1970];
                    NSLog(@"Auto Sync End: %f", timeInMilisecondsEnd);
                    [SyncUtil writeLastSyncDate:[NSDate date]];
                    autoSyncIterationInProgress = NO;
                    [[UploadQueue sharedInstance] manualAutoSyncIterationFinished];
                }
            } failureBlock:^(NSError *error) {
            }];
        });
        
    }
}

- (void) startUploadForAsset:(ALAsset *) asset andLocalHash:(NSString *) localHash {
    NSString *mimeType = (__bridge_transfer NSString*)UTTypeCopyPreferredTagWithClass
    ((__bridge CFStringRef)[asset.defaultRepresentation UTI], kUTTagClassMIMEType);

    if(asset.defaultRepresentation.url != nil && [asset.defaultRepresentation.url absoluteString] != nil) {
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
        [[UploadQueue sharedInstance] addNewUploadTask:manager];
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
                [[UploadQueue sharedInstance] cancelRemainingUploads];
            }
        }
    }

    if(triggerAutoSync) {
        [self decideAndStartAutoSync];
    }
}

- (void) decideAndStartAutoSync {
    if(APPDELEGATE.session.user) {
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
}

@end
