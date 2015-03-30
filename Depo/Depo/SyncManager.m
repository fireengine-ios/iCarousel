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
    [elasticSearchDao requestPhotosForPage:0 andSize:10000 andSortType:SortTypeAlphaAsc];
}

- (void) photoListSuccessCallback:(NSArray *) files {
    for(MetaFile *row in files) {
        if(row.metaHash != nil) {
            [SyncUtil cacheSyncHashRemotely:row.metaHash];
        }
        MetaFileSummary *fileSummary = [[MetaFileSummary alloc] init];
        fileSummary.bytes = row.bytes;
        fileSummary.fileName = row.name;
        [SyncUtil cacheSyncFileSummary:fileSummary];
    }
    
    NSArray *remoteHashList = [SyncUtil readSyncHashRemotely];
    NSArray *remoteSummaryList = [SyncUtil readSyncFileSummaries];

    NSTimeInterval timeInMiliseconds1 = [[NSDate date] timeIntervalSince1970];
    NSLog(@"startFirstTimeSync Start: %f", timeInMiliseconds1);
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        [self.assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
            if(group) {
                [group enumerateAssetsUsingBlock:^(ALAsset *asset, NSUInteger index, BOOL *stop) {
                    if(asset) {
                        EnableOption photoSyncFlag = (EnableOption)[CacheUtil readCachedSettingSyncPhotosVideos];
                        if(photoSyncFlag == EnableOptionAuto || photoSyncFlag == EnableOptionOn) {
                            ConnectionOption connectionOption = (ConnectionOption)[CacheUtil readCachedSettingSyncingConnectionType];
                            if([ReachabilityManager isReachableViaWiFi] || ([ReachabilityManager isReachableViaWWAN] && connectionOption == ConnectionOptionWifi3G)) {
                                NSString *localHash = [asset.defaultRepresentation MD5];
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
                                if(!serverContainsImageFlag) {
                                    [self startUploadForAsset:asset andRemoteHash:nil andLocalHash:localHash];
                                    [SyncUtil writeFirstTimeSyncFlag];
                                    [SyncUtil updateLastSyncDate];
                                }
                            }
                        }
                    }
                }];
            } else {
                [self firstTimeSyncStartFinalized];
            }
        } failureBlock:^(NSError *error) {
        }];
    });

    /*
    NSArray *remoteHashList = [SyncUtil readSyncHashRemotely];
    
    NSTimeInterval timeInMiliseconds1 = [[NSDate date] timeIntervalSince1970];
    NSLog(@"Start: %f", timeInMiliseconds1);

    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        [assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll | ALAssetsGroupLibrary usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
            if(group) {
                [group enumerateAssetsUsingBlock:^(ALAsset *asset, NSUInteger index, BOOL *stop) {
                    if(asset) {
                        NSString *localHash = [asset.defaultRepresentation MD5];
                        
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
                            [self startUploadForAsset:asset andRemoteHash:remoteCalcHash andLocalHash:localHash];
                            [SyncUtil updateLastSyncDate];
                        }
                        
                    }
                }];
            } else {
                [self firstTimeSyncStartFinalized];
            }
        } failureBlock:^(NSError *error) {
        }];
    });
     */
}

- (void) photoListFailCallback:(NSString *) errorMessage {
}

- (void) firstTimeSyncStartFinalized {
    NSTimeInterval timeInMiliseconds2 = [[NSDate date] timeIntervalSince1970];
    NSLog(@"End: %f", timeInMiliseconds2);
    [SyncUtil writeFirstTimeSyncFlag];
    [SyncUtil updateLastSyncDate];
}

- (void) manuallyCheckIfAlbumChanged {
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
        
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
            [self.assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
                if(group) {
                    [group enumerateAssetsUsingBlock:^(ALAsset *asset, NSUInteger index, BOOL *stop) {
                        if(asset) {
                            EnableOption photoSyncFlag = (EnableOption)[CacheUtil readCachedSettingSyncPhotosVideos];
                            if(photoSyncFlag == EnableOptionAuto || photoSyncFlag == EnableOptionOn) {
                                ConnectionOption connectionOption = (ConnectionOption)[CacheUtil readCachedSettingSyncingConnectionType];
                                if([ReachabilityManager isReachableViaWiFi] || ([ReachabilityManager isReachableViaWWAN] && connectionOption == ConnectionOptionWifi3G)) {
                                    NSString *localHash = [asset.defaultRepresentation MD5];
                                    BOOL shouldStartUpload = ![localHashList containsObject:localHash] && ![remoteHashList containsObject:localHash] && [APPDELEGATE.uploadQueue uploadRefForAsset:[asset.defaultRepresentation.url absoluteString]] == nil;
                                    if(shouldStartUpload) {
                                        ALAssetRepresentation *defaultRep = [asset defaultRepresentation];
                                        NSString *assetFileName = [defaultRep filename];
                                        NSLog(@"ASSET NAME:%@ SIZE:%lld", assetFileName, [defaultRep size]);
                                        for(MetaFileSummary *summary in remoteSummaryList) {
                                            NSLog(@"SUMMARY NAME:%@ SIZE:%lld", summary.fileName, summary.bytes);
                                            if([summary.fileName isEqualToString:assetFileName] && summary.bytes == [defaultRep size]) {
                                                shouldStartUpload = NO;
                                            }
                                        }
                                    }
                                    if(shouldStartUpload) {
                                        [self startUploadForAsset:asset andRemoteHash:nil andLocalHash:localHash];
                                        //                                [SyncUtil updateLastSyncDate];
                                        //                                [SyncUtil increaseBadgeCount];
                                    }
                                }
                            }
                        }
                    }];
                } else {
                    NSTimeInterval timeInMiliseconds2 = [[NSDate date] timeIntervalSince1970];
                    NSLog(@"End: %f", timeInMiliseconds2);
                    [SyncUtil writeLastSyncDate:[NSDate date]];
//                    [APPDELEGATE.uploadQueue startReadyTasks];
                }
            } failureBlock:^(NSError *error) {
            }];
        });
        
    }
}

- (void) startUploadForAsset:(ALAsset *) asset andRemoteHash:(NSString *) remoteHash andLocalHash:(NSString *) localHash {
    NSString *mimeType = (__bridge_transfer NSString*)UTTypeCopyPreferredTagWithClass
    ((__bridge CFStringRef)[asset.defaultRepresentation UTI], kUTTagClassMIMEType);
    NSLog(@"MIME TYPE: %@", mimeType);

    MetaFileSummary *summary = [[MetaFileSummary alloc] init];
    summary.fileName = [asset.defaultRepresentation filename];
    summary.bytes = [asset.defaultRepresentation size];

    UploadRef *ref = [[UploadRef alloc] init];
    ref.remoteHash = remoteHash;
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

- (void) reachabilityDidChange {
    EnableOption photoSyncFlag = (EnableOption)[CacheUtil readCachedSettingSyncPhotosVideos];
    if(photoSyncFlag == EnableOptionAuto || photoSyncFlag == EnableOptionOn) {
        ConnectionOption connectionOption = (ConnectionOption)[CacheUtil readCachedSettingSyncingConnectionType];
        if([ReachabilityManager isReachableViaWiFi]) {
                //auto sync çalışmalıdır
            [self manuallyCheckIfAlbumChanged];
        } else if([ReachabilityManager isReachableViaWWAN]) {
            if(connectionOption == ConnectionOptionWifi3G) {
                //auto sync çalışmalıdır
                [self manuallyCheckIfAlbumChanged];
            } else if(connectionOption == ConnectionOptionWifi) {
                //auto sync çalışmamalı ve queue'dakiler de temizlenmelidir
                [APPDELEGATE.uploadQueue cancelRemainingUploads];
            }
        }
    }
}

@end
