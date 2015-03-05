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
#import "UploadRef.h"
#import "UploadManager.h"
#import "AppDelegate.h"
#import "UploadQueue.h"

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
    }
    return self;
}

- (void) startFirstTimeSync {
    [elasticSearchDao requestPhotosForPage:0 andSize:10000 andSortType:SortTypeAlphaAsc];
}

- (void) startAutoSync {
    /*
     notification'ın backgrounddan dönünce gelmesi dolayısıyla background fetch sorgusunda tüm photo albüm kontrol ediliyor. O nedenle notification commentlendi
     */
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(albumChanged:) name:ALAssetsLibraryChangedNotification object:nil];
//    [self startLocationManagerIfNecessary];
}

- (void) stopAutoSync {
    /*
     notification'ın backgrounddan dönünce gelmesi dolayısıyla background fetch sorgusunda tüm photo albüm kontrol ediliyor. O nedenle notification commentlendi. Background fetch nedeniyle location kullanımından vazgeçildi
     */
    
    /*
    if(locManager) {
        [locManager stopUpdatingLocation];
        locManager = nil;
    }
     */
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:ALAssetsLibraryChangedNotification object:nil];
}

/*
- (void) startLocationManagerIfNecessary {
    if(!locManager) {
        self.locManager = [[CLLocationManager alloc] init];
        self.locManager.delegate = self;
        self.locManager.pausesLocationUpdatesAutomatically = NO;
        self.locManager.distanceFilter = 2000;
        self.locManager.desiredAccuracy = kCLLocationAccuracyKilometer;
        [self.locManager requestAlwaysAuthorization];
    }
    [locManager startUpdatingLocation];
}
*/
 
- (void) photoListSuccessCallback:(NSArray *) files {
    for(MetaFile *row in files) {
        if(row.metaHash != nil) {
            [SyncUtil cacheSyncHashRemotely:row.metaHash];
        }
    }
    
    NSArray *remoteHashList = [SyncUtil readSyncHashRemotely];

    NSTimeInterval timeInMiliseconds1 = [[NSDate date] timeIntervalSince1970];
    NSLog(@"startFirstTimeSync Start: %f", timeInMiliseconds1);
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        [self.assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
            if(group) {
                [group enumerateAssetsUsingBlock:^(ALAsset *asset, NSUInteger index, BOOL *stop) {
                    if(asset) {
                        NSString *localHash = [asset.defaultRepresentation MD5];
                        if(![remoteHashList containsObject:localHash]) {
                            [self startUploadForAsset:asset andRemoteHash:nil andLocalHash:localHash];
                            [SyncUtil writeFirstTimeSyncFlag];
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
    [SyncUtil writeLastSyncDate:[NSDate date]];
//    [APPDELEGATE.uploadQueue startReadyTasks];
}

- (void) manuallyCheckIfAlbumChanged {
    [self albumChanged:nil];
}

- (void) albumChanged:(NSNotification *) not {
    NSLog(@"At albumChanged");
    
    EnableOption photoSyncFlag = (EnableOption)[CacheUtil readCachedSettingSyncPhotosVideos];

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
        NSArray *remoteHashList = [SyncUtil readSyncHashRemotely];
        
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
            [self.assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
                if(group) {
                    [group enumerateAssetsUsingBlock:^(ALAsset *asset, NSUInteger index, BOOL *stop) {
                        if(asset) {
                            NSString *localHash = [asset.defaultRepresentation MD5];
                            if(![localHashList containsObject:localHash] && ![remoteHashList containsObject:localHash] && [APPDELEGATE.uploadQueue uploadRefForAsset:[asset.defaultRepresentation.url absoluteString]] == nil) {
                                [self startUploadForAsset:asset andRemoteHash:nil andLocalHash:localHash];
//                                [SyncUtil updateLastSyncDate];
//                                [SyncUtil increaseBadgeCount];
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
    UploadRef *ref = [[UploadRef alloc] init];
    ref.remoteHash = remoteHash;
    ref.localHash = localHash;
    ref.fileName = asset.defaultRepresentation.filename;
    ref.filePath = [asset.defaultRepresentation.url absoluteString];
    if ([[asset valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypeVideo]) {
        ref.contentType = ContentTypeVideo;
    } else {
        ref.contentType = ContentTypePhoto;
    }
    
    UploadManager *manager = [[UploadManager alloc] initWithUploadInfo:ref];
    [manager configureUploadAsset:ref.filePath atFolder:nil];
    [APPDELEGATE.uploadQueue addNewUploadTask:manager];
}

/*
- (void) locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    
    CLLocationCoordinate2D currentCoordinates = newLocation.coordinate;
    NSLog(@"Entered new Location with the coordinates Latitude: %f Longitude: %f", currentCoordinates.latitude, currentCoordinates.longitude);
    [self manuallyCheckIfAlbumChanged];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"Unable to start location manager. Error:%@", [error description]);
    [self manuallyCheckIfAlbumChanged];
}

- (void) locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    NSLog(@"location manager auth status changed");
}
*/

@end
