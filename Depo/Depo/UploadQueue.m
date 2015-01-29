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
            NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration backgroundSessionConfiguration:@"com.igones.depo.BackgroundSession"];
            configuration.sessionSendsLaunchEvents = YES;
            self.session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
        });
    }
    return self;
}

- (NSArray *) uploadRefsForFolder:(NSString *) folderUuid {
    NSMutableArray *result = [[NSMutableArray alloc] init];
    for(UploadManager *manager in self.uploadManagers) {
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
    for(UploadManager *manager in self.uploadManagers) {
        if(!manager.uploadRef.hasFinished) {
            if(manager.uploadRef.contentType == ContentTypePhoto || manager.uploadRef.contentType == ContentTypeVideo) {
                [result addObject:manager.uploadRef];
            }
        }
    }
    return result;
}

- (UploadRef *) uploadRefForAsset:(NSString *) assetUrl {
    for(UploadManager *manager in self.uploadManagers) {
        if([manager.uploadRef.assetUrl isEqualToString:assetUrl]) {
            return manager.uploadRef;
        }
    }
    return nil;
}

- (NSArray *) uploadImageRefsForAlbum:(NSString *) albumUuid {
    NSMutableArray *result = [[NSMutableArray alloc] init];
    for(UploadManager *manager in self.uploadManagers) {
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
    return nextTask;
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
}

#pragma mark UploadManagerQueueDelegate
- (void) uploadManager:(UploadManager *)manRef didFinishUploadingWithSuccess:(BOOL)success {
    [activeTaskIds removeObject:[manRef uniqueUrl]];
    
    if(success && manRef.uploadRef.localHash != nil) {
        [SyncUtil cacheSyncHashLocally:manRef.uploadRef.localHash];
    }
    if(success && manRef.uploadRef.remoteHash != nil) {
        [SyncUtil cacheSyncHashRemotely:manRef.uploadRef.remoteHash];
    }
    
    if([activeTaskIds count] < MAX_CONCURRENT_UPLOAD_TASKS) {
        UploadManager *nextManager = [self findNextTask];
        if(nextManager != nil) {
            [nextManager startTask];
            [activeTaskIds addObject:[nextManager uniqueUrl]];
        }
    }
}

- (void) uploadManagerIsReadToStartTask:(UploadManager *)manRef {
    if([activeTaskIds count] < MAX_CONCURRENT_UPLOAD_TASKS) {
        for(UploadManager *row in self.uploadManagers) {
            if([[row uniqueUrl] isEqualToString:[manRef uniqueUrl]]) {
                [row startTask];
                [activeTaskIds addObject:[row uniqueUrl]];
                break;
            }
        }
    }
}

- (void) uploadManagerTaskIsInitialized:(UploadManager *)manRef {
    if([activeTaskIds containsObject:[manRef uniqueUrl]]) {
        UploadManager *oldMan = nil;
        for(UploadManager *row in self.uploadManagers) {
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
    UploadManager *currentManager = [self findByTaskId:task.taskIdentifier];
    if(currentManager != nil) {
        [currentManager.delegate uploadManagerDidSendData:(long)totalBytesSent inTotal:(long)totalBytesExpectedToSend];
    }
}

- (void) URLSession:(NSURLSession *) _session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    
    UploadManager *currentManager = [self findByTaskId:task.taskIdentifier];
    if(currentManager != nil) {
        NSHTTPURLResponse *httpResp = (NSHTTPURLResponse*) task.response;
        NSLog(@"STATUS CODE: %d", (int)httpResp.statusCode);
        if (!error && httpResp.statusCode == 201) {
            [currentManager removeTemporaryFile];
            [currentManager notifyUpload];
        } else {
            currentManager.uploadRef.hasFinished = YES;
            [currentManager removeTemporaryFile];
            [currentManager.delegate uploadManagerDidFailUploadingForAsset:currentManager.uploadRef.assetUrl];
            [self uploadManager:currentManager didFinishUploadingWithSuccess:NO];
        }
    }
}

- (void) URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *) _session {
    NSLog(@"URLSessionDidFinishEventsForBackgroundURLSession");
}

- (UploadManager *) findByTaskId:(long) taskId {
    if(self.uploadManagers != nil) {
        for(UploadManager *row in self.uploadManagers) {
            if(row.uploadTask.taskIdentifier == taskId) {
                return row;
            }
        }
    }
    return nil;
}

@end
