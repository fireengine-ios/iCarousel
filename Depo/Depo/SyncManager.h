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

@protocol SyncManagerQueueCountDelegate <NSObject>
- (void) syncManagerNumberOfImagesInQueue:(int) queueCount;
@end

@protocol SyncManagerInfoDelegate <NSObject>
- (void) syncManagerUnsyncedImageList:(NSArray *) unsyncedAssets;
@end

@interface SyncManager : NSObject

@property (nonatomic, strong) id<SyncManagerQueueCountDelegate> queueCountDelegate;
@property (nonatomic, weak) id<SyncManagerInfoDelegate> infoDelegate;
@property (nonatomic, strong) ALAssetsLibrary *assetsLibrary;
@property (nonatomic, strong) ElasticSearchDao *elasticSearchDao;
@property (nonatomic) BOOL autoSyncIterationInProgress;

+ (SyncManager *) sharedInstance;
- (void) startFirstTimeSync;
- (void) initializeNextAutoSyncPackage;
- (void) manuallyCheckIfAlbumChanged;
- (void) decideAndStartAutoSync;
- (void) remainingQueueCount;
- (void) listOfUnsyncedImages;

@end
