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

@interface UploadQueue : NSObject <UploadManagerQueueDelegate, NSURLSessionDelegate, NSURLSessionTaskDelegate, TokenManagerWithinProcessDelegate>

@property (nonatomic, strong) NSMutableSet *activeTaskIds;
@property (nonatomic, strong) NSMutableArray *uploadManagers;
@property (nonatomic, strong) NSURLSession *session;

- (NSArray *) uploadRefsForFolder:(NSString *) folderUuid;
- (UploadRef *) uploadRefForAsset:(NSString *) assetUrl;
- (NSArray *) uploadImageRefs;
- (NSArray *) uploadImageRefsForAlbum:(NSString *) albumUuid;
- (void) addNewUploadTask:(UploadManager *) newManager;
- (void) addOnlyNewUploadTask:(UploadManager *) newManager;
- (void) startReadyTasks;
- (void) cancelRemainingUploads;
- (int) totalAutoSyncCount;
- (int) finishedAutoSyncCount;

@end
