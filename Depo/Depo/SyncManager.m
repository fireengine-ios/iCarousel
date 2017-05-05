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
#import "CurioSDK.h"
#import "MPush.h"

@implementation SyncManager

@synthesize queueCountDelegate;
@synthesize infoDelegate;
@synthesize assetsLibrary;
@synthesize elasticSearchDao;
@synthesize autoSyncIterationInProgress;

+ (SyncManager *) sharedInstance {
    static SyncManager *sharedInstance;
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
        [elasticSearchDao requestPhotosAndVideosForPage:0 andSize:300000 andSortType:SortTypeAlphaAsc isMinimal:YES];
        autoSyncIterationInProgress = YES;
    }
}

- (void) photoListSuccessCallback:(NSArray *) files {
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(void) {
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
        if([SyncUtil readFirstTimeSyncFlag]) {
            IGLog(@"SyncManager photoListSuccessCallback readFirstTimeSyncFlag is true calling manuallyCheckIfAlbumChanged");
            [SyncUtil writeOneTimeSyncFlag];
            [self manuallyCheckIfAlbumChanged];
        } else {
            IGLog(@"SyncManager photoListSuccessCallback readFirstTimeSyncFlag is false calling initializeNextAutoSyncPackage");
            [self initializeNextAutoSyncPackage];
        }
    });
}

- (void) initializeNextAutoSyncPackage {
    IGLog(@"SyncManager initializeNextAutoSyncPackage called");
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
        IGLog(@"SyncManager initializeNextAutoSyncPackage at triggerSyncing");
        NSArray *localHashList = [SyncUtil readSyncHashLocally];
        NSArray *remoteHashList = [SyncUtil readSyncHashRemotely];
        NSArray *remoteSummaryList = [SyncUtil readSyncFileSummaries];
        
        autoSyncIterationInProgress = YES;
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(void) {
            [self.assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
                if(group) {
                    [group setAssetsFilter:[ALAssetsFilter allPhotos]];
                    
                    int startIndex = [SyncUtil readAutoSyncIndex];
                    //check and set "finished flag" to TRUE if no enumeration is left
                    if(startIndex >= [group numberOfAssets]) {
                        [SyncUtil writeFirstTimeSyncFinishedFlag];
                    } else {
                        int length = AUTO_SYNC_ASSET_COUNT * 100;
                        if(startIndex + length > [group numberOfAssets]) {
                            length = (int)[group numberOfAssets] - startIndex;
                        }
                        NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(startIndex, length)];
                        if (indexSet.lastIndex > [group numberOfAssets]) {
                            indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(startIndex, [group numberOfAssets])];
                        }
                        
                        [[CurioSDK shared] sendEvent:@"FirstSyncStarted" eventValue:[NSString stringWithFormat:@"start index: %d", startIndex]];
                        
                        [group enumerateAssetsAtIndexes:indexSet options:0 usingBlock:^(ALAsset *asset, NSUInteger index, BOOL *stop) {
                            NSString *referenceAlbumName = nil;//[group valueForProperty:ALAssetsGroupPropertyName];
                            if(asset && [[asset valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypePhoto]) {
                                NSDictionary *metadataDict = [asset.defaultRepresentation metadata];
                                if(metadataDict) {
                                    NSDictionary *tiffDict = [metadataDict objectForKey:@"{TIFF}"];
                                    if(tiffDict) {
                                        NSString *softwareVal = [tiffDict objectForKey:@"Software"];
                                        if(softwareVal) {
                                            if([SPECIAL_LOCAL_ALBUM_NAMES containsObject:softwareVal]) {
                                                referenceAlbumName = softwareVal;
                                            }
                                        }
                                    }
                                }
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
                                            NSString *logInfo = [NSString stringWithFormat:@"SyncManager initializeNextAutoSyncPackage sync starting for asset: %@", [defaultRep filename]];
                                            IGLog(logInfo);
                                            [self startUploadForAsset:asset withReferenceAlbumName:referenceAlbumName  andLocalHash:localHash];
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
                    IGLog(@"SyncManager initializeNextAutoSyncPackage group enumeration finished");
                    autoSyncIterationInProgress = NO;
                    [self firstTimeBlockSyncEnumerationFinished];
                    [[UploadQueue sharedInstance] manualAutoSyncIterationFinished];
                    [[NSNotificationCenter defaultCenter] postNotificationName:AUTO_ITERATION_FINISHED_NOT_KEY object:nil];
                }
            } failureBlock:^(NSError *error) {
            }];
        });
    }
}

- (void) photoListFailCallback:(NSString *) errorMessage {
    autoSyncIterationInProgress = NO;
}

- (void) firstTimeBlockSyncEnumerationFinished {
    [SyncUtil writeFirstTimeSyncFlag];
    [SyncUtil writeOneTimeSyncFlag];
    [SyncUtil updateLastSyncDate];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if(![SyncUtil readFirstTimeSyncFinishedFlag] && ![SyncUtil readAutoSyncBlockInProgress]) {
            [self initializeNextAutoSyncPackage];
        }
    });
}

- (void) manuallyCheckIfAlbumChanged {
    IGLog(@"SyncManager manuallyCheckIfAlbumChanged");
    if(autoSyncIterationInProgress)
        return;
    
    if([SyncUtil readBaseUrlConstant] == nil)
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
        IGLog(@"SyncManager manuallyCheckIfAlbumChanged at triggerSyncing");
        NSArray *localHashList = [SyncUtil readSyncHashLocally];
        NSArray *remoteHashList = [SyncUtil readSyncHashRemotely];
        NSArray *remoteSummaryList = [SyncUtil readSyncFileSummaries];
        
        [[CurioSDK shared] sendEvent:@"BackgroundSync" eventValue:@"started"];
        
        autoSyncIterationInProgress = YES;
        //        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(void) {
        [self.assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
            if(group) {
                [group setAssetsFilter:[ALAssetsFilter allPhotos]];
                [group enumerateAssetsUsingBlock:^(ALAsset *asset, NSUInteger index, BOOL *stop) {
                    NSString *referenceAlbumName = nil;//[group valueForProperty:ALAssetsGroupPropertyName];
                    if(asset && [[asset valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypePhoto]) {
                        NSDictionary *metadataDict = [asset.defaultRepresentation metadata];
                        if(metadataDict) {
                            NSDictionary *tiffDict = [metadataDict objectForKey:@"{TIFF}"];
                            if(tiffDict) {
                                NSString *softwareVal = [tiffDict objectForKey:@"Software"];
                                if(softwareVal) {
                                    if([SPECIAL_LOCAL_ALBUM_NAMES containsObject:softwareVal]) {
                                        referenceAlbumName = softwareVal;
                                    }
                                }
                            }
                        }
                        EnableOption photoSyncFlag = (EnableOption)[CacheUtil readCachedSettingSyncPhotosVideos];
                        if(photoSyncFlag == EnableOptionAuto || photoSyncFlag == EnableOptionOn) {
                            ConnectionOption connectionOption = (ConnectionOption)[CacheUtil readCachedSettingSyncingConnectionType];
                            if([ReachabilityManager isReachableViaWiFi] || ([ReachabilityManager isReachableViaWWAN] && connectionOption == ConnectionOptionWifi3G)) {
                                
                                ALAssetRepresentation *defaultRep = [asset defaultRepresentation];
                                NSString *repUrl = [defaultRep.url absoluteString];
                                if(repUrl != nil) {
                                    NSString *localHash = [SyncUtil md5StringOfString:repUrl];
                                    
                                    BOOL shouldStartUpload = ![localHashList containsObject:localHash] && ![remoteHashList containsObject:localHash];
                                    
                                    if(shouldStartUpload) {
                                        MetaFileSummary *assetSummary = [[MetaFileSummary alloc] init];
                                        assetSummary.bytes = [defaultRep size];
                                        assetSummary.fileName = [defaultRep filename];
                                        shouldStartUpload = ![remoteSummaryList containsObject:assetSummary];
                                    }
                                    if(shouldStartUpload) {
                                        NSString *logInfo = [NSString stringWithFormat:@"SyncManager manuallyCheckIfAlbumChanged sync starting for asset: %@", [defaultRep filename]];
                                        IGLog(logInfo);
                                        NSLog(@"%@", logInfo);
                                        [[SyncManager sharedInstance] startUploadForAsset:asset withReferenceAlbumName:referenceAlbumName andLocalHash:localHash];
                                    }
                                }
                            }
                        }
                    }
                }];
            } else {
                IGLog(@"SyncManager manuallyCheckIfAlbumChanged group enumeration finished");
                [SyncUtil writeLastSyncDate:[NSDate date]];
                autoSyncIterationInProgress = NO;
                [[UploadQueue sharedInstance] manualAutoSyncIterationFinished];
                [[NSNotificationCenter defaultCenter] postNotificationName:AUTO_ITERATION_FINISHED_NOT_KEY object:nil];
                [[CurioSDK shared] sendEvent:@"BackgroundSync" eventValue:@"ended"];
            }
        } failureBlock:^(NSError *error) {
        }];
        //        });
    }
}

- (void) remainingQueueCount {
    NSArray *localHashList = [SyncUtil readSyncHashLocally];
    NSArray *remoteHashList = [SyncUtil readSyncHashRemotely];
    NSArray *remoteSummaryList = [SyncUtil readSyncFileSummaries];
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(void) {
        __block int waitingInQueueCount = 0;
        [self.assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
            
            if(group) {
                [group setAssetsFilter:[ALAssetsFilter allPhotos]];
                [group enumerateAssetsUsingBlock:^(ALAsset *asset, NSUInteger index, BOOL *stop) {
                    if(asset && [[asset valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypePhoto]) {
                        ALAssetRepresentation *defaultRep = [asset defaultRepresentation];
                        NSString *localHash = [SyncUtil md5StringOfString:[defaultRep.url absoluteString]];
                        
                        BOOL isWaitingForSync = ![localHashList containsObject:localHash] && ![remoteHashList containsObject:localHash];
                        
                        if(isWaitingForSync) {
                            MetaFileSummary *assetSummary = [[MetaFileSummary alloc] init];
                            assetSummary.bytes = [defaultRep size];
                            assetSummary.fileName = [defaultRep filename];
                            isWaitingForSync = ![remoteSummaryList containsObject:assetSummary];
                        }
                        if(isWaitingForSync) {
                            waitingInQueueCount++;
                        }
                    }
                }];
            } else {
                [queueCountDelegate syncManagerNumberOfImagesInQueue:waitingInQueueCount];
            }
        } failureBlock:^(NSError *error) {
        }];
    });
}

- (void) startUploadForAsset:(ALAsset *) asset withReferenceAlbumName:(NSString *) referenceAlbumName andLocalHash:(NSString *) localHash {
    NSString *mimeType = (__bridge_transfer NSString*)UTTypeCopyPreferredTagWithClass
    ((__bridge CFStringRef)[asset.defaultRepresentation UTI], kUTTagClassMIMEType);
    
    if(asset.defaultRepresentation.url != nil && [asset.defaultRepresentation.url absoluteString] != nil) {
        NSString *logMessage = [NSString stringWithFormat:@"SyncManager startUploadForAsset called for %@", asset.defaultRepresentation.filename];
        IGLog(logMessage);
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
        ref.referenceFolderName = referenceAlbumName;
        
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
    IGLog(@"SyncManager reachabilityDidChange called");
    [[UploadQueue sharedInstance] cancelAllUploads];
    IGLog(@"SyncManager all uploads cancelled");
    EnableOption photoSyncFlag = (EnableOption)[CacheUtil readCachedSettingSyncPhotosVideos];
    if(photoSyncFlag == EnableOptionAuto || photoSyncFlag == EnableOptionOn) {
        ConnectionOption connectionOption = (ConnectionOption)[CacheUtil readCachedSettingSyncingConnectionType];
        if([ReachabilityManager isReachableViaWiFi]) {
            IGLog(@"SyncManager reachabilityDidChange isReachableViaWiFi");
            //auto sync çalışmalıdır
            triggerAutoSync = YES;
        } else if([ReachabilityManager isReachableViaWWAN]) {
            IGLog(@"SyncManager reachabilityDidChange isReachableViaWWAN");
            if(connectionOption == ConnectionOptionWifi3G) {
                IGLog(@"SyncManager reachabilityDidChange isReachableViaWWAN ConnectionOptionWifi3G");
                //auto sync çalışmalıdır
                triggerAutoSync = YES;
            } else if(connectionOption == ConnectionOptionWifi) {
                IGLog(@"SyncManager reachabilityDidChange isReachableViaWWAN ConnectionOptionWifi");
                //auto sync çalışmamalı ve queue'dakiler de temizlenmelidir
                [[UploadQueue sharedInstance] cancelAllUploads];
            }
        } else if(![ReachabilityManager isReachable]) {
            IGLog(@"SyncManager reachabilityDidChange isReachable NO");
            //bağlantı gidince queue temizlenmeli ve bağlantı gelince bu akışa yeniden girmeli
            [[UploadQueue sharedInstance] cancelAllUploads];
        }
    }
    
    if(triggerAutoSync) {
        [self decideAndStartAutoSync];
    }
}

- (void) decideAndStartAutoSync {
    IGLog(@"SyncManager decideAndStartAutoSync");
    if(APPDELEGATE.session.user) {
        if([SyncUtil read413Lock] && ![SyncUtil isLast413CheckDateOneDayOld]) {
            IGLog(@"SyncManager loop ignored by 413 lock");
            return;
        }
        if(![SyncUtil readFirstTimeSyncFlag]) {
            IGLog(@"SyncManager starting first time sync");
            [self startFirstTimeSync];
        } else if(![SyncUtil readFirstTimeSyncFinishedFlag]) {
            if(![SyncUtil readAutoSyncBlockInProgress]) {
                IGLog(@"SyncManager initializing next auto sync package");
                [self initializeNextAutoSyncPackage];
            }
        } else {
            IGLog(@"SyncManager before calling manuallyCheckIfAlbumChanged");
            if(![SyncUtil readAutoSyncBlockInProgress]) {
                if(![SyncUtil readOneTimeSyncFlag]) {
                    IGLog(@"SyncManager calling elastic search for one more time");
                    [self startFirstTimeSync];
                } else {
                    IGLog(@"SyncManager calling manuallyCheckIfAlbumChanged");
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                        [self manuallyCheckIfAlbumChanged];
                    });
                }
            }
        }
    }
}

- (void) listOfUnsyncedImages {
    IGLog(@"SyncManager listOfUnsyncedImages started");
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(void) {
        NSMutableArray *unsycedResult = [[NSMutableArray alloc] init];
        
        [self.assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
            if(group) {
//                [group setAssetsFilter:[ALAssetsFilter allPhotos]];
                [group enumerateAssetsUsingBlock:^(ALAsset *asset, NSUInteger index, BOOL *stop) {
                    if(asset && [[asset valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypePhoto]) {
                        [unsycedResult addObject:asset];
                    }
                }];
            } else {
                IGLog(@"SyncManager listOfUnsyncedImages group enumeration finished");
                //dispatch_async(dispatch_get_main_queue(), ^{
                    IGLog(@"SyncManager listOfUnsyncedImages ends with success");
                    if(infoDelegate) {
                        [infoDelegate syncManagerUnsyncedImageList:unsycedResult];
                    }
                //});
            }
        } failureBlock:^(NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                IGLog(@"SyncManager listOfUnsyncedImages ends with failure");
                IGLog(error.localizedDescription);
                if(infoDelegate) {
                    [infoDelegate syncManagerUnsyncedImageList:unsycedResult];
                }
            });
        }];
    });
}

- (void) numberOfUnsyncedImages {
    NSLog(@"numberOfUnsyncedImages start");
    IGLog(@"SyncManager numberOfUnsyncedImages started");
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(void) {
        NSArray *localHashList = [SyncUtil readSyncHashLocally];
        NSArray *remoteHashList = [SyncUtil readSyncHashRemotely];
        
        __block int waitCount = 0;
        
        [self.assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
            if(group) {
//                [group setAssetsFilter:[ALAssetsFilter allPhotos]];
                [group enumerateAssetsUsingBlock:^(ALAsset *asset, NSUInteger index, BOOL *stop) {
                    if(asset && [[asset valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypePhoto]) {
                        ALAssetRepresentation *defaultRep = [asset defaultRepresentation];
                        NSString *repUrl = [defaultRep.url absoluteString];
                        if(repUrl != nil) {
                            NSString *localHash = [SyncUtil md5StringOfString:repUrl];
                            
                            BOOL shouldStartUpload = ![localHashList containsObject:localHash] && ![remoteHashList containsObject:localHash];
                            
                            if (shouldStartUpload) {
                                MetaFileSummary *assetSummary = [[MetaFileSummary alloc] init];
                                assetSummary.bytes = [defaultRep size];
                                assetSummary.fileName = [defaultRep filename];
                                shouldStartUpload = ![[SyncUtil readSyncFileSummaries] containsObject:assetSummary];
                            }
                            
                            if(shouldStartUpload) {
                                waitCount ++;
                            }
                        }
                        
                    }
                }];
            } else {
                IGLog(@"SyncManager numberOfUnsyncedImages group enumeration finished");
                //dispatch_async(dispatch_get_main_queue(), ^{
                    IGLog(@"SyncManager numberOfUnsyncedImages ends with success");
                    if(infoDelegate) {
                        [infoDelegate syncManagerNumberOfImagesWaitingForUpload:waitCount];
                    }
                //});
            }
        } failureBlock:^(NSError *error) {
            IGLog(@"SyncManager numberOfUnsyncedImages ends with failure");
        }];
    });
}

@end
