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

@implementation UploadQueue

@synthesize activeTaskIds;
@synthesize uploadManagers;

- (id) init {
    if(self = [super init]) {
        self.uploadManagers = [[NSMutableArray alloc] init];
        self.activeTaskIds = [[NSMutableSet alloc] init];
    }
    return self;
}

- (NSArray *) uploadRefsForFolder:(NSString *) folderUuid {
    NSMutableArray *result = [[NSMutableArray alloc] init];
    for(UploadManager *manager in self.uploadManagers) {
        if(!manager.hasFinished) {
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
        if(!manager.hasFinished) {
            if(manager.uploadRef.contentType == ContentTypePhoto || manager.uploadRef.contentType == ContentTypeVideo) {
                [result addObject:manager.uploadRef];
            }
        }
    }
    return result;
}

- (NSArray *) uploadImageRefsForAlbum:(NSString *) albumUuid {
    NSMutableArray *result = [[NSMutableArray alloc] init];
    for(UploadManager *manager in self.uploadManagers) {
        if(!manager.hasFinished && [manager.uploadRef.albumUuid isEqualToString:albumUuid]) {
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
        if(!row.hasFinished && row.isReady && ![activeTaskIds containsObject:row.uploadRef.tempUrl]) {
            if(nextTask == nil) {
                nextTask = row;
            } else {
                if([row.initializationDate compare:nextTask.initializationDate] == NSOrderedAscending) {
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
    if(newManager.isReady) {
        [newManager startTask];
        [activeTaskIds addObject:newManager.uploadRef.tempUrl];
    }
}

#pragma mark UploadManagerQueueDelegate
- (void) uploadManager:(UploadManager *)manRef didFinishUploadingWithSuccess:(BOOL)success {
    [activeTaskIds removeObject:manRef.uploadRef.tempUrl];
    
    if([activeTaskIds count] < MAX_CONCURRENT_UPLOAD_TASKS) {
        UploadManager *nextManager = [self findNextTask];
        if(nextManager != nil) {
            [nextManager startTask];
            [activeTaskIds addObject:nextManager.uploadRef.tempUrl];
        }
    }
}

- (void) uploadManagerIsReadToStartTask:(UploadManager *)manRef {
    if([activeTaskIds count] < MAX_CONCURRENT_UPLOAD_TASKS) {
        for(UploadManager *row in self.uploadManagers) {
            if([row.uploadRef.tempUrl isEqualToString:manRef.uploadRef.tempUrl]) {
                [row startTask];
                [activeTaskIds addObject:row.uploadRef.tempUrl];
                break;
            }
        }
    }
}

@end
