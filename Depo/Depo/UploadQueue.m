//
//  UploadQueue.m
//  Depo
//
//  Created by Mahir on 05/01/15.
//  Copyright (c) 2015 com.igones. All rights reserved.
//

#import "UploadQueue.h"
#import "AppConstants.h"
#import "UploadManager.h"
#import "SyncUtil.h"
#import "AppDelegate.h"
#import "MMWormhole.h"
#import "AppUtil.h"
#import "CacheUtil.h"
#import "MPush.h"
#import "FirstUploadFlagDao.h"

@interface UploadQueue() {
    FirstUploadFlagDao *firstUploadFlagDao;
}
@end

@implementation UploadQueue

@synthesize activeTaskIds;
@synthesize uploadManagers;
@synthesize session;

+ (UploadQueue *) sharedInstance {
    static UploadQueue *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[UploadQueue alloc] init];
        
        NSURLSessionConfiguration *configuration;
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
            configuration = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"com.igones.akillidepo.BackgroundUploadSession"];
        } else {
            configuration = [NSURLSessionConfiguration backgroundSessionConfiguration:@"com.igones.akillidepo.BackgroundUploadSession"];
            configuration.timeoutIntervalForResource = GENERAL_TASK_TIMEOUT;
        }
        
//        configuration.HTTPMaximumConnectionsPerHost = 1;
        configuration.sessionSendsLaunchEvents = YES;
        sharedInstance.session = [NSURLSession sessionWithConfiguration:configuration delegate:sharedInstance delegateQueue:[NSOperationQueue mainQueue]];
    });
    
    return sharedInstance;
}

- (id) init {
    if(self = [super init]) {
        self.uploadManagers = [[NSMutableArray alloc] init];
        self.activeTaskIds = [[NSMutableSet alloc] init];

        /*
         Mahir:
         session'ın bir kere oluşturulduğundan emin oluyoruz. Aynı identifier'la farklı bir session oluşturulması engelleniyor.
         */
        /*
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            NSURLSessionConfiguration *configuration;
            if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
                configuration = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"com.igones.akillidepo.BackgroundSession"];
            } else {
                configuration = [NSURLSessionConfiguration backgroundSessionConfiguration:@"com.igones.akillidepo.BackgroundSession"];
            }
            
            configuration.sessionSendsLaunchEvents = YES;
            self.session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:[NSOperationQueue mainQueue]];
        });
         */
    }
    return self;
}

- (NSArray *) uploadRefsForFolder:(NSString *) folderUuid {
    NSMutableArray *result = [[NSMutableArray alloc] init];
    @synchronized(uploadManagers) {
        for(UploadManager *manager in uploadManagers) {
            if(!manager.uploadRef.hasFinished) {
                if(manager.uploadRef.folderUuid == nil && folderUuid == nil) {
                    [result addObject:manager.uploadRef];
                } else if([folderUuid isEqualToString:manager.uploadRef.folderUuid]){
                    [result addObject:manager.uploadRef];
                }
            }
        }
    }
    return result;
}

- (NSArray *) uploadImageRefs {
    NSMutableArray *result = [[NSMutableArray alloc] init];
    @synchronized(uploadManagers) {
        for(UploadManager *manager in uploadManagers) {
            if(!manager.uploadRef.hasFinished) {
                if(manager.uploadRef.contentType == ContentTypePhoto || manager.uploadRef.contentType == ContentTypeVideo) {
                    [result addObject:manager.uploadRef];
                }
            }
        }
    }
    return result;
}

- (UploadRef *) uploadRefForAsset:(NSString *) assetUrl {
    @synchronized(uploadManagers) {
        for(UploadManager *manager in uploadManagers) {
            if([manager.uploadRef.assetUrl isEqualToString:assetUrl]) {
                return manager.uploadRef;
            }
        }
    }
    return nil;
}

- (NSArray *) uploadImageRefsForAlbum:(NSString *) albumUuid {
    NSMutableArray *result = [[NSMutableArray alloc] init];
    @synchronized(uploadManagers) {
        for(UploadManager *manager in uploadManagers) {
            if(!manager.uploadRef.hasFinished && [manager.uploadRef.albumUuid isEqualToString:albumUuid]) {
                if(manager.uploadRef.contentType == ContentTypePhoto || manager.uploadRef.contentType == ContentTypeVideo) {
                    [result addObject:manager.uploadRef];
                }
            }
        }
    }
    return result;
}

- (UploadManager *) findNextTask {
    UploadManager *nextTask = nil;
    @synchronized(uploadManagers) {
        @try {
            for(UploadManager *row in uploadManagers) {
                if(!row.uploadRef.hasFinished && row.uploadRef.isReady && ![activeTaskIds containsObject:[row uniqueUrl]]) {
                    if(nextTask == nil) {
                        nextTask = row;
                    } else {
                        if([row.uploadRef.initializationDate compare:nextTask.uploadRef.initializationDate] == NSOrderedAscending) {
                            nextTask = row;
                        }
                    }
                }
            }
        }
        @catch (NSException *exception) {
        }
        @finally {
        }
    }
    return nextTask;
}

- (int) remainingCount {
    int count = 0;
    @synchronized(uploadManagers) {
        @try {
            for(UploadManager *row in uploadManagers) {
                if(!row.uploadRef.hasFinished && row.uploadRef.isReady) {
                    count++;
                }
            }
        }
        @catch (NSException *exception) {
        }
        @finally {
        }
    }
    return count;
}

- (void) cancelAllUploads {
    [[UploadQueue sharedInstance] cancelAllUploadsUpdateReferences:YES];
}

- (void) cancelAllUploadsUpdateReferences:(BOOL) updateReferencesFlag {
    [self cancelRemainingUploadsUpdateReferences:updateReferencesFlag];
    @synchronized(uploadManagers) {
        @try {
            for(UploadManager *row in uploadManagers) {
                if(row.uploadTask) {
                    [row.uploadTask cancel];
                }
            }
        }
        @catch (NSException *exception) {
        }
        @finally {
            [self.uploadManagers removeAllObjects];
            [self.activeTaskIds removeAllObjects];
        }

        [self.session getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
            if(uploadTasks) {
                for(NSURLSessionUploadTask *task in uploadTasks) {
                    [task cancel];
                }
            }
            if(updateReferencesFlag) {
                [[NSNotificationCenter defaultCenter] postNotificationName:AUTO_SYNC_QUEUE_CHANGED_NOTIFICATION object:nil userInfo:nil];
                [self updateGroupUserDefaults];
            }
        }];
    }
}

- (void) cancelRemainingUploads {
    [[UploadQueue sharedInstance] cancelRemainingUploadsUpdateReferences:YES];
}

- (void) cancelRemainingUploadsUpdateReferences:(BOOL) updateReferencesFlag {
    NSMutableArray *cleanArray = [[NSMutableArray alloc] init];
    @synchronized(uploadManagers) {
        @try {
            for(UploadManager *row in uploadManagers) {
                if(!row.uploadRef.autoSyncFlag || [activeTaskIds containsObject:[row uniqueUrl]]) {
                    [cleanArray addObject:row];
                }
            }
        }
        @catch (NSException *exception) {
        }
        @finally {
        }
        self.uploadManagers = cleanArray;
    }
    [SyncUtil unlockAutoSyncBlockInProgress];
    if(updateReferencesFlag) {
        [[NSNotificationCenter defaultCenter] postNotificationName:AUTO_SYNC_QUEUE_CHANGED_NOTIFICATION object:nil userInfo:nil];
        [self updateGroupUserDefaults];
    }
}

- (void) addOnlyNewUploadTask:(UploadManager *) newManager {
    @synchronized(uploadManagers) {
        [uploadManagers addObject:newManager];
    }
}

- (void) startReadyTasks {
    while([activeTaskIds count] < MAX_CONCURRENT_UPLOAD_TASKS) {
        UploadManager *nextManager = [self findNextTask];
        if(nextManager != nil) {
            nextManager.queueDelegate = self;
            [activeTaskIds addObject:[nextManager uniqueUrl]];
            [nextManager startTask];
        }
    }
}

- (void) manualAutoSyncIterationFinished {
    [self updateGroupUserDefaults];
}

- (void) addNewUploadTask:(UploadManager *) newManager {
    @synchronized(uploadManagers) {
        if(![uploadManagers containsObject:newManager]) {
            newManager.queueDelegate = self;
            [uploadManagers addObject:newManager];

            if(newManager.uploadRef.autoSyncFlag) {
                [SyncUtil lockAutoSyncBlockInProgress];
            }

            if(newManager.uploadRef.isReady) {
                if([activeTaskIds count] < MAX_CONCURRENT_UPLOAD_TASKS) {
                    [activeTaskIds addObject:[newManager uniqueUrl]];
                    [newManager startTask];
                }
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:AUTO_SYNC_QUEUE_CHANGED_NOTIFICATION object:nil userInfo:nil];
        }
        /*
        if([uploadManagers containsObject:newManager]) {
            UploadManager *managerToRemove = nil;
            for(UploadManager *row in uploadManagers) {
                if([row.uploadRef.localHash isEqualToString:newManager.uploadRef.localHash]) {
                    managerToRemove = row;
                    break;
                }
            }
            if(managerToRemove != nil) {
                newManager.delegate = managerToRemove.delegate;
                [uploadManagers removeObject:managerToRemove];
            }
        }
        [uploadManagers addObject:newManager];
         */
    }
    /*
    newManager.queueDelegate = self;
    if(newManager.uploadRef.isReady) {
        if([activeTaskIds count] < MAX_CONCURRENT_UPLOAD_TASKS) {
            [activeTaskIds addObject:[newManager uniqueUrl]];
            [newManager startTask];
        }
    }
     */

//    [self updateGroupUserDefaults];
}

#pragma mark UploadManagerQueueDelegate
- (void) uploadManager:(UploadManager *)manRef didFinishUploadingWithSuccess:(BOOL)success {
    [activeTaskIds removeObject:[manRef uniqueUrl]];
    NSString *log = [NSString stringWithFormat:@"Calling didFinishUploadingWithSuccess : %@ for task: %@ and active task id count is %d", success ? @"YES" : @"NO", [manRef uniqueUrl], (int)[activeTaskIds count]];
    IGLog(log);
    if([activeTaskIds count] < MAX_CONCURRENT_UPLOAD_TASKS) {
        UploadManager *nextManager = [self findNextTask];
        if(nextManager != nil) {
            nextManager.queueDelegate = self;
            [activeTaskIds addObject:[nextManager uniqueUrl]];
            [nextManager startTask];
        } else {
            //TODO test et
            [[NSNotificationCenter defaultCenter] postNotificationName:AUTO_SYNC_QUEUE_FINISHED_NOTIFICATION object:nil userInfo:nil];
            [SyncUtil unlockAutoSyncBlockInProgress];
            if(![SyncUtil readFirstTimeSyncFinishedFlag]) {
                [[SyncManager sharedInstance] initializeNextAutoSyncPackage];
            }
        }
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:AUTO_SYNC_QUEUE_CHANGED_NOTIFICATION object:nil userInfo:nil];
    [self updateGroupUserDefaults];

    [MPush hitEvent:@"photo_uploaded"];
    
    if(![AppUtil readFirstUploadFlag]) {
        firstUploadFlagDao = [[FirstUploadFlagDao alloc] init];
        [firstUploadFlagDao requestSendFirstUploadFlag];
        [AppUtil writeFirstUploadFlag];
    }

    [[UIApplication sharedApplication] endBackgroundTask:manRef.bgTaskI];
    manRef.bgTaskI = UIBackgroundTaskInvalid;
}

- (void) uploadManagerIsReadToStartTask:(UploadManager *)manRef {
    if([activeTaskIds count] < MAX_CONCURRENT_UPLOAD_TASKS) {
        @synchronized(uploadManagers) {
            for(UploadManager *row in uploadManagers) {
                if([[row uniqueUrl] isEqualToString:[manRef uniqueUrl]]) {
                    [activeTaskIds addObject:[row uniqueUrl]];
                    [row startTask];
                    break;
                }
            }
        }
    }
}

- (void) uploadManagerTaskIsInitialized:(UploadManager *)manRef {
    if([activeTaskIds containsObject:[manRef uniqueUrl]]) {
        UploadManager *oldMan = nil;
        @synchronized(uploadManagers) {
            for(UploadManager *row in uploadManagers) {
                if([[row uniqueUrl] isEqualToString:[manRef uniqueUrl]]) {
                    oldMan = row;
                    break;
                }
            }
            manRef.queueDelegate = self;
            [self.uploadManagers removeObject:oldMan];
            [self.uploadManagers addObject:manRef];
        }
    }
}

- (void) removeUploadManagerReferenceAfterFail:(UploadManager *)manToRemove {
    @synchronized(uploadManagers) {
        UploadManager *rowToDelete = nil;
        for(UploadManager *row in uploadManagers) {
            if([[row uniqueUrl] isEqualToString:[manToRemove uniqueUrl]]) {
                rowToDelete = row;
                break;
            }
        }
        if(rowToDelete != nil) {
            [self.uploadManagers removeObject:rowToDelete];
        }
    }
}

- (void) URLSession:(NSURLSession *) _session task:(NSURLSessionTask *)task didSendBodyData:(int64_t)bytesSent totalBytesSent:(int64_t)totalBytesSent totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend {
    UploadManager *currentManager = [self findByTaskId:task.taskIdentifier];
    NSLog(@"BYTES SENT FOR TASK: %ld", task.taskIdentifier);
    if(currentManager != nil) {
        [currentManager.delegate uploadManagerDidSendData:(long)totalBytesSent inTotal:(long)totalBytesExpectedToSend];
        if(currentManager.headerDelegate) {
            [currentManager.headerDelegate uploadManagerDidSendData:(long)totalBytesSent inTotal:(long)totalBytesExpectedToSend];
        }
        // mahir: bir kere paket yollanmışsa tekrar invalid token'a düşme ihtimaline karşı flag tekrar NO'ya çekiliyor.
        if(currentManager.uploadRef.retryDoneForTokenFlag) {
            currentManager.uploadRef.retryDoneForTokenFlag = NO;
        }
    }
}

- (void) URLSession:(NSURLSession *) _session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    UploadManager *currentManager = [self findByTaskId:task.taskIdentifier];
    NSHTTPURLResponse *httpResp = (NSHTTPURLResponse*) task.response;
    
    if (!error && httpResp.statusCode == 201) {
        if(currentManager != nil) {
            if(currentManager.uploadRef.summary != nil) {
                [SyncUtil cacheSyncFileSummary:currentManager.uploadRef.summary];
            }
            [currentManager removeTemporaryFile];
            currentManager.uploadRef.hasFinished = YES;
            [currentManager notifyUpload];
        } else {
            //TODO: tek dosya uploadu oldugu icin upload bitiminde documents folder altindaki temp dosyalarinin hepsini temizliyoruz. Eger paralel upload sayisi 1'den fazla olursa bu kismin silinmesi gerekiyor.
            [APPDELEGATE removeAllMediaFiles];
        }
    } else {
        BOOL shouldDeleteHash = YES;
        if(httpResp.statusCode == 0 && error != nil && ([error code] == -1 || [error code] == -997)) {
            shouldDeleteHash = NO;
        }
        if(httpResp.statusCode == 401 || httpResp.statusCode == 403) {
            if(currentManager != nil) {
                if(!currentManager.uploadRef.retryDoneForTokenFlag) {
                    //TODO aynı anda tek upload işlemine göre tasarlandı. Eğer aynı anda birden fazla upload yapılacaksa
                    //token requesti tek yapılacak şekilde (synchronized) düzenleme yapmak gerekir.
                    currentManager.uploadRef.retryDoneForTokenFlag = YES;
                    APPDELEGATE.tokenManager.processDelegate = self;
                    [APPDELEGATE.tokenManager requestTokenWithinProcess:task.taskIdentifier];
                } else {
                    currentManager.uploadRef.hasFinished = YES;
                    currentManager.uploadRef.hasFinishedWithError = YES;
                    [currentManager removeTemporaryFile];
                    if(shouldDeleteHash) {
                        [SyncUtil removeLocalHash:task.taskDescription];
                    }
                    [currentManager.delegate uploadManagerLoginRequiredForAsset:currentManager.uploadRef.assetUrl];
                    if(currentManager.headerDelegate) {
                        [currentManager.headerDelegate uploadManagerLoginRequiredForAsset:currentManager.uploadRef.assetUrl];
                    }
                    [self uploadManager:currentManager didFinishUploadingWithSuccess:NO];
                }
            } else {
                if(shouldDeleteHash) {
                    [SyncUtil removeLocalHash:task.taskDescription];
                }
                //TODO: tek dosya uploadu oldugu icin upload bitiminde documents folder altindaki temp dosyalarinin hepsini temizliyoruz. Eger paralel upload sayisi 1'den fazla olursa bu kismin silinmesi gerekiyor.
                [APPDELEGATE removeAllMediaFiles];
            }
        } else if(httpResp.statusCode == 413) {
            [SyncUtil write413Lock:YES];
            if(shouldDeleteHash) {
                [SyncUtil removeLocalHash:task.taskDescription];
            }
            
            if(currentManager != nil) {
                currentManager.uploadRef.hasFinished = YES;
                currentManager.uploadRef.hasFinishedWithError = YES;
                [currentManager removeTemporaryFile];
                [currentManager.delegate uploadManagerQuotaExceedForAsset:currentManager.uploadRef.assetUrl];
                if(currentManager.headerDelegate) {
                    [currentManager.headerDelegate uploadManagerQuotaExceedForAsset:currentManager.uploadRef.assetUrl];
                }
                [self uploadManager:currentManager didFinishUploadingWithSuccess:NO];
            } else {
                //TODO: tek dosya uploadu oldugu icin upload bitiminde documents folder altindaki temp dosyalarinin hepsini temizliyoruz. Eger paralel upload sayisi 1'den fazla olursa bu kismin silinmesi gerekiyor.
                [APPDELEGATE removeAllMediaFiles];
            }
        } else {
            if(shouldDeleteHash) {
                [SyncUtil removeLocalHash:task.taskDescription];
            }
            
            if(currentManager != nil) {
                currentManager.uploadRef.hasFinished = YES;
                currentManager.uploadRef.hasFinishedWithError = YES;
                [currentManager removeTemporaryFile];
                [currentManager.delegate uploadManagerDidFailUploadingForAsset:currentManager.uploadRef.assetUrl];
                if(currentManager.headerDelegate) {
                    [currentManager.headerDelegate uploadManagerDidFailUploadingForAsset:currentManager.uploadRef.assetUrl];
                }
                [self uploadManager:currentManager didFinishUploadingWithSuccess:NO];
            } else {
                //TODO: tek dosya uploadu oldugu icin upload bitiminde documents folder altindaki temp dosyalarinin hepsini temizliyoruz. Eger paralel upload sayisi 1'den fazla olursa bu kismin silinmesi gerekiyor.
                [APPDELEGATE removeAllMediaFiles];
            }
        }
        //cancel the task if suspended or running in case of error
        if(task.state == NSURLSessionTaskStateRunning || task.state == NSURLSessionTaskStateSuspended) {
            [task cancel];
        }
    }
}

- (void) URLSession:(NSURLSession *)session didBecomeInvalidWithError:(NSError *)error {
}

- (void) URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task needNewBodyStream:(void (^)(NSInputStream *))completionHandler {
}

- (void) URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task willPerformHTTPRedirection:(NSHTTPURLResponse *)response newRequest:(NSURLRequest *)request completionHandler:(void (^)(NSURLRequest *))completionHandler {
}


- (void) URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *) _session {
    
    if([UIApplication sharedApplication].applicationState != UIApplicationStateActive) {
        [SyncManager sharedInstance].queueCountDelegate = self;
        [[SyncManager sharedInstance] remainingQueueCount];
    }
}

- (UploadManager *) findByTaskId:(long) taskId {
    @synchronized(uploadManagers) {
        if(self.uploadManagers != nil) {
            for(UploadManager *row in uploadManagers) {
                if(row.uploadTask.taskIdentifier == taskId) {
                    return row;
                }
            }
        }
        return nil;
    }
}

#pragma mark TokenManagerWithinProcessDelegate methods

- (void) tokenManagerWithinProcessDidFailReceivingTokenFor:(int) taskId {
    UploadManager *currentManager = [self findByTaskId:taskId];
    if(currentManager != nil) {
        currentManager.uploadRef.hasFinished = YES;
        [currentManager removeTemporaryFile];
        [currentManager.delegate uploadManagerLoginRequiredForAsset:currentManager.uploadRef.assetUrl];
        if(currentManager.headerDelegate) {
            [currentManager.headerDelegate uploadManagerLoginRequiredForAsset:currentManager.uploadRef.assetUrl];
        }
        [self uploadManager:currentManager didFinishUploadingWithSuccess:NO];
    }
}

- (void) tokenManagerWithinProcessDidReceiveTokenFor:(int) taskId {
    UploadManager *currentManager = [self findByTaskId:taskId];
    if(currentManager != nil) {
        [currentManager startTask];
    }
}

- (void) cleanAlreadyFinishedManagers {
    @synchronized(uploadManagers) {
        NSMutableArray *itemsToRemove = [[NSMutableArray alloc] init];
        for(UploadManager *row in uploadManagers) {
            if(row.uploadRef.autoSyncFlag && row.uploadRef.hasFinished) {
                [itemsToRemove addObject:row];
            }
        }
        [uploadManagers removeObjectsInArray:itemsToRemove];
    }
}

- (int) totalAutoSyncCount {
    @synchronized(uploadManagers) {
        int count = 0;
        @try {
            for(UploadManager *row in uploadManagers) {
                if(row.uploadRef.autoSyncFlag) {
                    count++;
                }
            }
        }
        @catch (NSException *exception) {
        }
        @finally {
        }
        return count;
    }
}

- (int) totalUploadCount {
    @synchronized(uploadManagers) {
        int count = 0;
        @try {
            for(UploadManager *row in uploadManagers) {
                if(!row.uploadRef.hasFinished) {
                    count++;
                }
            }
        }
        @catch (NSException *exception) {
        }
        @finally {
        }
        return count;
    }
}

- (int) finishedAutoSyncCount {
    @synchronized(uploadManagers) {
        int count = 0;
        @try {
            for(UploadManager *row in uploadManagers) {
                if(row.uploadRef.hasFinished && row.uploadRef.autoSyncFlag) {
                    count++;
                }
            }
        }
        @catch (NSException *exception) {
        }
        @finally {
        }
        return count;
    }
}

- (int) finishedUploadCount {
    @synchronized(uploadManagers) {
        int count = 0;
        @try {
            for(UploadManager *row in uploadManagers) {
                if(row.uploadRef.hasFinished) {
                    count++;
                }
            }
        }
        @catch (NSException *exception) {
        }
        @finally {
        }
        return count;
    }
}

//Mahir: this method saves into the group nsuserdefaults the values needed for the Today Extension
- (void) updateGroupUserDefaults {
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        int totalAutoSyncCount = [self totalAutoSyncCount];
        int finishedAutoSyncCount = [self finishedAutoSyncCount];
        
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"dd.MM.yyyy HH:mm"];
        NSString *lastSyncDateInReadableFormat = [NSString stringWithFormat:NSLocalizedString(@"LastSyncFormatForWidget", @""), [dateFormat stringFromDate:[SyncUtil readLastSyncDate]]];
        
        NSUserDefaults *sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:GROUP_NAME_SUITE_NSUSERDEFAULTS];
        [sharedDefaults setInteger:totalAutoSyncCount forKey:@"totalAutoSyncCount"];
        [sharedDefaults setInteger:finishedAutoSyncCount forKey:@"finishedAutoSyncCount"];
        [sharedDefaults setValue:lastSyncDateInReadableFormat forKey:@"lastSyncDate"];
        [sharedDefaults synchronize];
        
        [APPDELEGATE.wormhole passMessageObject:@{@"totalCount":[NSNumber numberWithInt: totalAutoSyncCount]} identifier:EXTENSION_WORMHOLE_TOTAL_COUNT_IDENTIFIER];
        [APPDELEGATE.wormhole passMessageObject:@{@"finishedCount":[NSNumber numberWithInt: finishedAutoSyncCount]} identifier:EXTENSION_WORMHOLE_FINISHED_COUNT_IDENTIFIER];

        /* package 6 bünyesinde kaldırıldı */
//        int activeSyncCount = totalAutoSyncCount - finishedAutoSyncCount;
//        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:activeSyncCount > AUTO_SYNC_ASSET_COUNT ? AUTO_SYNC_ASSET_COUNT : activeSyncCount];
    });
}

#pragma mark SyncManagerUploadQueueDelegate methods
- (void) syncManagerNumberOfImagesInQueue:(int)queueCount {
    if(queueCount == 0) {
        //all the tasks in the url session has finalized and no more task waiting in queue
        EnableOption photoSyncFlag = (EnableOption)[CacheUtil readCachedSettingSyncPhotosVideos];
        if(photoSyncFlag == EnableOptionAuto || photoSyncFlag == EnableOptionOn) {
            [AppUtil sendLocalNotificationForDate:[NSDate date] withMessage:NSLocalizedString(@"LocalNotificationAutoUploadsFinished", @"")];
        } else {
            [AppUtil sendLocalNotificationForDate:[NSDate date] withMessage:NSLocalizedString(@"LocalNotificationManualUploadsFinished", @"")];
        }
        
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    }

    [[UploadQueue sharedInstance] cancelAllUploadsUpdateReferences:NO];
    
    if (self.backgroundSessionCompletionHandler) {
        
        void (^completionHandler)() = self.backgroundSessionCompletionHandler;
        self.backgroundSessionCompletionHandler = nil;
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            completionHandler();
        }];
    }
}

- (UploadManager *) activeManager {
    for(UploadManager *row in self.uploadManagers) {
        if([activeTaskIds containsObject:[row uniqueUrl]]) {
            return row;
        }
    }
    return nil;
}

@end
