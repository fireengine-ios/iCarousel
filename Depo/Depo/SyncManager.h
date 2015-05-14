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

@interface SyncManager : NSObject

@property (nonatomic, strong) ALAssetsLibrary *assetsLibrary;
@property (nonatomic, strong) ElasticSearchDao *elasticSearchDao;
@property (nonatomic) BOOL autoSyncIterationInProgress;

+ (SyncManager *) sharedInstance;
- (void) startFirstTimeSync;
- (void) initializeNextAutoSyncPackage;
- (void) manuallyCheckIfAlbumChanged;
- (void) decideAndStartAutoSync;

@end
