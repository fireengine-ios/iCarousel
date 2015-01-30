//
//  UploadRef.h
//  Depo
//
//  Created by Mahir on 10/6/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppConstants.h"

@class MetaFile;

@interface UploadRef : NSObject

@property (nonatomic, strong) NSString *fileName;
@property (nonatomic, strong) NSString *filePath;
@property (nonatomic, strong) NSString *folderUuid;
@property (nonatomic, strong) NSString *fileUuid;
@property (nonatomic, strong) NSString *tempUrl;
@property (nonatomic, strong) NSString *tempThumbnailUrl;
@property (nonatomic, strong) NSString *assetUrl;
@property (nonatomic, strong) NSString *urlForUpload;
@property (nonatomic, strong) NSString *albumUuid;
@property (nonatomic, strong) NSData *fileData;
@property (nonatomic) ContentType contentType;
@property (nonatomic) BOOL hasFinished;
@property (nonatomic) BOOL isReady;
@property (nonatomic) UploadTaskType taskType;
@property (nonatomic, strong) MetaFile *folder;
@property (nonatomic, strong) NSDate *initializationDate;
@property (nonatomic, strong) NSString *localHash;
@property (nonatomic, strong) NSString *remoteHash;

- (void) configureUploadFileForPath:(NSString *) _filePath atFolder:(MetaFile *) _folder withFileName:(NSString *) fileName;
- (void) configureUploadData:(NSData *) _dataToUpload atFolder:(MetaFile *) _folder withFileName:(NSString *) fileName;
- (void) configureUploadAsset:(NSString *) _assetUrl atFolder:(MetaFile *) _folder;

@end
