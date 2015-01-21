//
//  UploadQueue.h
//  Depo
//
//  Created by Mahir on 05/01/15.
//  Copyright (c) 2015 com.igones. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UploadManager.h"

@interface UploadQueue : NSObject <UploadManagerQueueDelegate, NSURLSessionDelegate, NSURLSessionTaskDelegate>

@property (nonatomic, strong) NSMutableSet *activeTaskIds;
@property (nonatomic, strong) NSMutableArray *uploadManagers;
@property (nonatomic, strong) NSURLSession *session;

- (NSArray *) uploadRefsForFolder:(NSString *) folderUuid;
- (NSArray *) uploadImageRefs;
- (NSArray *) uploadImageRefsForAlbum:(NSString *) albumUuid;
- (void) addNewUploadTask:(UploadManager *) newManager;

@end
