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
    //TODO şimdilik sıfırdan silip yüklemelerde eski dosyalar için kontrol yok çünkü datayı hash'lemek gerekiyor ve bu uzun sürüyor.
//    [elasticSearchDao requestPhotosForPage:0 andSize:10000 andSortType:SortTypeAlphaAsc];
    
    NSArray *localHashList = [SyncUtil readSyncHashLocally];
    
    [self.assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll | ALAssetsGroupLibrary usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        //TODO Test sil
        if(group && [[group valueForProperty:ALAssetsGroupPropertyName] isEqualToString:@"Test"]) {
            [group enumerateAssetsUsingBlock:^(ALAsset *asset, NSUInteger index, BOOL *stop) {
                if(asset) {
                    NSString *localHash = [asset.defaultRepresentation MD5];
                    if(![localHashList containsObject:localHash]) {
                        [self startUploadForAsset:asset andRemoteHash:nil andLocalHash:localHash];
                        [SyncUtil updateLastSyncDate];
                    }
                }
            }];
        }
    } failureBlock:^(NSError *error) {
    }];
}

- (void) startAutoSync {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(albumChanged:) name:ALAssetsLibraryChangedNotification object:nil];
//    [self startLocationManagerIfNecessary];
}

- (void) stopAutoSync {
    /*
    if(locManager) {
        [locManager stopUpdatingLocation];
        locManager = nil;
    }
     */
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ALAssetsLibraryChangedNotification object:nil];
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
        [SyncUtil cacheSyncHashRemotely:row.hash];
    }

    NSArray *remoteHashList = [SyncUtil readSyncHashRemotely];
    
    NSTimeInterval timeInMiliseconds1 = [[NSDate date] timeIntervalSince1970];
    NSLog(@"Start: %f", timeInMiliseconds1);

    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        [assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll | ALAssetsGroupLibrary usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
            //TODO Test sil
            if(group && [[group valueForProperty:ALAssetsGroupPropertyName] isEqualToString:@"Test"]) {
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
}

- (void) photoListFailCallback:(NSString *) errorMessage {
}

- (void) firstTimeSyncStartFinalized {
    NSTimeInterval timeInMiliseconds2 = [[NSDate date] timeIntervalSince1970];
    NSLog(@"End: %f", timeInMiliseconds2);
    [SyncUtil writeFirstTimeSyncFlag];
    [SyncUtil writeLastSyncDate:[NSDate date]];
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
        
        [self.assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll | ALAssetsGroupLibrary usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
            //TODO Test sil
            if(group && [[group valueForProperty:ALAssetsGroupPropertyName] isEqualToString:@"Test"]) {
                [group enumerateAssetsUsingBlock:^(ALAsset *asset, NSUInteger index, BOOL *stop) {
                    if(asset) {
                        NSString *localHash = [asset.defaultRepresentation MD5];
                        if(![localHashList containsObject:localHash] && [APPDELEGATE.uploadQueue uploadRefForAsset:[asset.defaultRepresentation.url absoluteString]] == nil) {
                            [self startUploadForAsset:asset andRemoteHash:nil andLocalHash:localHash];
                            [SyncUtil updateLastSyncDate];
                            [SyncUtil increaseBadgeCount];
                        }
                    }
                }];
            }
        } failureBlock:^(NSError *error) {
        }];
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

@end
