//
//  SyncManager.h
//  Depo
//
//  Created by Mahir on 24.12.2014.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "ElasticSearchDao.h"
#import <CoreLocation/CoreLocation.h>

@interface SyncManager : NSObject <CLLocationManagerDelegate>

@property (nonatomic, strong) ALAssetsLibrary *assetsLibrary;
@property (nonatomic, strong) ElasticSearchDao *elasticSearchDao;
@property (nonatomic, strong) CLLocationManager *locManager;
@property (nonatomic) BOOL autoSyncIterationInProgress;

- (void) startFirstTimeSync;
- (void) initializeNextAutoSyncPackage;
- (void) manuallyCheckIfAlbumChanged;
- (void) decideAndStartAutoSync;

@end
