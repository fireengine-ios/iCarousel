//
//  UploadQueue.h
//  Depo
//
//  Created by Mahir on 05/01/15.
//  Copyright (c) 2015 com.igones. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UploadManager.h"
#import "TokenManager.h"
#import "SyncManager.h"

@interface UploadQueue : NSObject <UploadManagerQueueDelegate, NSURLSessionDelegate, NSURLSessionTaskDelegate, TokenManagerWithinProcessDelegate, SyncManagerQueueCountDelegate>

@property (nonatomic, strong) NSMutableSet *activeTaskIds;
@property (nonatomic, strong) NSArray <UploadManager *>*uploadManagers;
@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, copy) void (^backgroundSessionCompletionHandler)(void);

+ (UploadQueue *) sharedInstance;
- (NSArray *) uploadRefsForFolder:(NSString *) folderUuid;
- (UploadRef *) uploadRefForAsset:(NSString *) assetUrl;
- (NSArray *) uploadImageRefs;
- (NSArray *) uploadRefHashes;
- (NSArray *) uploadImageRefsForAlbum:(NSString *) albumUuid;
- (void) addNewUploadTask:(UploadManager *) newManager;
- (void) addOnlyNewUploadTask:(UploadManager *) newManager;
- (void) startReadyTasks;
- (void) cancelAllUploads;
- (void) cancelAllUploadsUpdateReferences:(BOOL) updateReferencesFlag;
- (void) cancelRemainingUploads;
- (void) cancelRemainingUploadsUpdateReferences:(BOOL) updateReferencesFlag;
- (int) totalAutoSyncCount;
- (int) finishedAutoSyncCount;
- (void) manualAutoSyncIterationFinished;
- (int) remainingCount;
- (void) cleanAlreadyFinishedManagers;
- (void) cleanAlreadyFinishedManagersNoReferenceToAutoSync;
- (UploadManager *) activeManager;
- (int) totalUploadCount;
- (int) finishedUploadCount;

@end
