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

@implementation UploadQueue

@synthesize activeTaskIds;
@synthesize uploadManagers;
@synthesize session;

- (id) init {
    if(self = [super init]) {
        self.uploadManagers = [[NSMutableArray alloc] init];
        self.activeTaskIds = [[NSMutableSet alloc] init];

        /*
         Mahir:
         session'ın bir kere oluşturulduğundan emin oluyoruz. Aynı identifier'la farklı bir session oluşturulması engelleniyor.
         */
        
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            NSURLSessionConfiguration *configuration;
            if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
                configuration = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"com.igones.depo.BackgroundSession"];
            } else {
                configuration = [NSURLSessionConfiguration backgroundSessionConfiguration:@"com.igones.depo.BackgroundSession"];
            }
            
            configuration.sessionSendsLaunchEvents = YES;
            self.session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
        });
    }
    return self;
}

- (NSArray *) uploadRefsForFolder:(NSString *) folderUuid {
    NSMutableArray *result = [[NSMutableArray alloc] init];
    for(UploadManager *manager in [self.uploadManagers copy]) {
        if(!manager.uploadRef.hasFinished) {
            if(manager.uploadRef.folderUuid == nil && folderUuid == nil) {
                [result addObject:manager.uploadRef];
            } else if([folderUuid isEqualToString:manager.uploadRef.folderUuid]){
                [result addObject:manager.uploadRef];
            }
        }
    }
    return result;
}

- (NSArray *) uploadImageRefs {
    NSMutableArray *result = [[NSMutableArray alloc] init];
    for(UploadManager *manager in [self.uploadManagers copy]) {
        if(!manager.uploadRef.hasFinished) {
            if(manager.uploadRef.contentType == ContentTypePhoto || manager.uploadRef.contentType == ContentTypeVideo) {
                [result addObject:manager.uploadRef];
            }
        }
    }
    return result;
}

- (UploadRef *) uploadRefForAsset:(NSString *) assetUrl {
    for(UploadManager *manager in [self.uploadManagers copy]) {
        if([manager.uploadRef.assetUrl isEqualToString:assetUrl]) {
            return manager.uploadRef;
        }
    }
    return nil;
}

- (NSArray *) uploadImageRefsForAlbum:(NSString *) albumUuid {
    NSMutableArray *result = [[NSMutableArray alloc] init];
    for(UploadManager *manager in [self.uploadManagers copy]) {
        if(!manager.uploadRef.hasFinished && [manager.uploadRef.albumUuid isEqualToString:albumUuid]) {
            if(manager.uploadRef.contentType == ContentTypePhoto || manager.uploadRef.contentType == ContentTypeVideo) {
                [result addObject:manager.uploadRef];
            }
        }
    }
    return result;
}

- (UploadManager *) findNextTask {
    UploadManager *nextTask = nil;
    @try {
        for(UploadManager *row in [uploadManagers copy]) {
            if(!row.uploadRef.hasFinished && row.uploadRef.isReady && ![activeTaskIds containsObject:[row uniqueUrl]]) {
                NSLog(@"UPLOAD NAME: %@, TASK_ID:%d", row.uploadRef.fileName, row.uploadTask.taskIdentifier);
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
    return nextTask;
}

- (int) remainingCount {
    int count = 0;
    @try {
        for(UploadManager *row in [uploadManagers copy]) {
            if(!row.uploadRef.hasFinished && row.uploadRef.isReady) {
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

- (void) cancelRemainingUploads {
    NSMutableArray *cleanArray = [[NSMutableArray alloc] init];
    @try {
        for(UploadManager *row in [uploadManagers copy]) {
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
    [[NSNotificationCenter defaultCenter] postNotificationName:AUTO_SYNC_QUEUE_CHANGED_NOTIFICATION object:nil userInfo:nil];
}

- (void) addOnlyNewUploadTask:(UploadManager *) newManager {
    [uploadManagers addObject:newManager];
}

- (void) startReadyTasks {
    while([activeTaskIds count] < MAX_CONCURRENT_UPLOAD_TASKS) {
        UploadManager *nextManager = [self findNextTask];
        nextManager.queueDelegate = self;
        if(nextManager != nil) {
            [activeTaskIds addObject:[nextManager uniqueUrl]];
            [nextManager startTask];
        }
    }
}

- (void) addNewUploadTask:(UploadManager *) newManager {
    [uploadManagers addObject:newManager];
    newManager.queueDelegate = self;
    if(newManager.uploadRef.isReady) {
        if([activeTaskIds count] < MAX_CONCURRENT_UPLOAD_TASKS) {
            [activeTaskIds addObject:[newManager uniqueUrl]];
            [newManager startTask];
        }
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:AUTO_SYNC_QUEUE_CHANGED_NOTIFICATION object:nil userInfo:nil];
}

#pragma mark UploadManagerQueueDelegate
- (void) uploadManager:(UploadManager *)manRef didFinishUploadingWithSuccess:(BOOL)success {
    [activeTaskIds removeObject:[manRef uniqueUrl]];
    NSLog(@"!!!!!!!! AT didFinishUploadingWithSuccess. Remaining list count: %d", [self remainingCount]);
    
    if([activeTaskIds count] < MAX_CONCURRENT_UPLOAD_TASKS) {
        NSLog(@"!!!!!!!! empty slot present");
        UploadManager *nextManager = [self findNextTask];
        nextManager.queueDelegate = self;
        if(nextManager != nil) {
            NSLog(@"!!!!!!!! Next manager started");
            [activeTaskIds addObject:[nextManager uniqueUrl]];
            [nextManager startTask];
        }
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:AUTO_SYNC_QUEUE_CHANGED_NOTIFICATION object:nil userInfo:nil];
}

- (void) uploadManagerIsReadToStartTask:(UploadManager *)manRef {
    if([activeTaskIds count] < MAX_CONCURRENT_UPLOAD_TASKS) {
        for(UploadManager *row in [self.uploadManagers copy]) {
            if([[row uniqueUrl] isEqualToString:[manRef uniqueUrl]]) {
                [activeTaskIds addObject:[row uniqueUrl]];
                [row startTask];
                break;
            }
        }
    }
}

- (void) uploadManagerTaskIsInitialized:(UploadManager *)manRef {
    if([activeTaskIds containsObject:[manRef uniqueUrl]]) {
        UploadManager *oldMan = nil;
        for(UploadManager *row in [self.uploadManagers copy]) {
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

- (void) URLSession:(NSURLSession *) _session task:(NSURLSessionTask *)task didSendBodyData:(int64_t)bytesSent totalBytesSent:(int64_t)totalBytesSent totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend {
    NSLog(@"BYTES SENT: %lld, total bytes sent: %lld", bytesSent, totalBytesSent);
    UploadManager *currentManager = [self findByTaskId:task.taskIdentifier];
    if(currentManager != nil) {
        [currentManager.delegate uploadManagerDidSendData:(long)totalBytesSent inTotal:(long)totalBytesExpectedToSend];
    }
}

- (void) URLSession:(NSURLSession *) _session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    
    UploadManager *currentManager = [self findByTaskId:task.taskIdentifier];
    if(currentManager != nil) {
        NSHTTPURLResponse *httpResp = (NSHTTPURLResponse*) task.response;
        if (!error && httpResp.statusCode == 201) {
            if(currentManager.uploadRef.localHash != nil) {
                [SyncUtil cacheSyncHashLocally:currentManager.uploadRef.localHash];
            }
            if(currentManager.uploadRef.remoteHash != nil) {
                [SyncUtil cacheSyncHashRemotely:currentManager.uploadRef.remoteHash];
            }
            if(currentManager.uploadRef.summary != nil) {
                [SyncUtil cacheSyncFileSummary:currentManager.uploadRef.summary];
            }
            [currentManager removeTemporaryFile];
            [currentManager notifyUpload];
        } else {
            if(httpResp.statusCode == 403) {
                if(!currentManager.uploadRef.retryDoneForTokenFlag) {
                    //TODO aynı anda tek upload işlemine göre tasarlandı. Eğer aynı anda birden fazla upload yapılacaksa
                    //token requesti tek yapılacak şekilde (synchronized) düzenleme yapmak gerekir.
                    currentManager.uploadRef.retryDoneForTokenFlag = YES;
                    APPDELEGATE.tokenManager.processDelegate = self;
                    [APPDELEGATE.tokenManager requestTokenWithinProcess:task.taskIdentifier];
                } else {
                    currentManager.uploadRef.hasFinished = YES;
                    [currentManager removeTemporaryFile];
                    [currentManager.delegate uploadManagerLoginRequiredForAsset:currentManager.uploadRef.assetUrl];
                    [self uploadManager:currentManager didFinishUploadingWithSuccess:NO];
                }
            } else if(httpResp.statusCode == 413) {
                currentManager.uploadRef.hasFinished = YES;
                [currentManager removeTemporaryFile];
                [currentManager.delegate uploadManagerQuotaExceedForAsset:currentManager.uploadRef.assetUrl];
                [self uploadManager:currentManager didFinishUploadingWithSuccess:NO];
            } else {
                currentManager.uploadRef.hasFinished = YES;
                [currentManager removeTemporaryFile];
                [currentManager.delegate uploadManagerDidFailUploadingForAsset:currentManager.uploadRef.assetUrl];
                [self uploadManager:currentManager didFinishUploadingWithSuccess:NO];
            }
        }
    }
}

- (void) URLSession:(NSURLSession *)session didBecomeInvalidWithError:(NSError *)error {
    NSLog(@"URLSession:didBecomeInvalidWithError:");
}

- (void) URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task needNewBodyStream:(void (^)(NSInputStream *))completionHandler {
    NSLog(@"URLSession:task:needNewBodyStream:");
}

- (void) URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task willPerformHTTPRedirection:(NSHTTPURLResponse *)response newRequest:(NSURLRequest *)request completionHandler:(void (^)(NSURLRequest *))completionHandler {
    NSLog(@"URLSession:task:willPerformHTTPRedirection:");
}


- (void) URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *) _session {
    NSLog(@"URLSessionDidFinishEventsForBackgroundURLSession");
}

- (UploadManager *) findByTaskId:(long) taskId {
    if(self.uploadManagers != nil) {
        for(UploadManager *row in [self.uploadManagers copy]) {
            if(row.uploadTask.taskIdentifier == taskId) {
                return row;
            }
        }
    }
    return nil;
}

#pragma mark TokenManagerWithinProcessDelegate methods

- (void) tokenManagerWithinProcessDidFailReceivingTokenFor:(int) taskId {
    UploadManager *currentManager = [self findByTaskId:taskId];
    if(currentManager != nil) {
        currentManager.uploadRef.hasFinished = YES;
        [currentManager removeTemporaryFile];
        [currentManager.delegate uploadManagerLoginRequiredForAsset:currentManager.uploadRef.assetUrl];
        [self uploadManager:currentManager didFinishUploadingWithSuccess:NO];
    }
}

- (void) tokenManagerWithinProcessDidReceiveTokenFor:(int) taskId {
    UploadManager *currentManager = [self findByTaskId:taskId];
    if(currentManager != nil) {
        //TODO check
        [currentManager startTask];
    }
}

- (int) totalAutoSyncCount {
    int count = 0;
    @try {
        for(UploadManager *row in [uploadManagers copy]) {
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

- (int) finishedAutoSyncCount {
    int count = 0;
    @try {
        for(UploadManager *row in [uploadManagers copy]) {
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

@end
