//
//  UploadQueue.h
//  Depo
//
//  Created by Mahir on 05/01/15.
//  Copyright (c) 2015 com.igones. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UploadManager.h"

@interface UploadQueue : NSObject <UploadManagerQueueDelegate>

@property (nonatomic, strong) NSMutableSet *activeTaskIds;
@property (nonatomic, strong) NSMutableArray *uploadManagers;

- (NSArray *) uploadRefsForFolder:(NSString *) folderUuid;
- (NSArray *) uploadImageRefs;
- (NSArray *) uploadImageRefsForAlbum:(NSString *) albumUuid;
- (void) addNewUploadTask:(UploadManager *) newManager;

@end
