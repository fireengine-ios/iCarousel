//
//  UploadRef.m
//  Depo
//
//  Created by Mahir on 10/6/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "UploadRef.h"
#import "MetaFile.h"
#import "AppDelegate.h"
#import "AppSession.h"

@implementation UploadRef

@synthesize fileName;
@synthesize filePath;
@synthesize folderUuid;
@synthesize fileUuid;
@synthesize tempUrl;
@synthesize tempThumbnailUrl;
@synthesize assetUrl;
@synthesize urlForUpload;
@synthesize albumUuid;
@synthesize fileData;
@synthesize contentType;
@synthesize hasFinished;
@synthesize isReady;
@synthesize taskType;
@synthesize folder;
@synthesize initializationDate;
@synthesize localHash;
@synthesize remoteHash;

- (void) configureUploadFileForPath:(NSString *) _filePath atFolder:(MetaFile *) _folder withFileName:(NSString *) fileName {

    self.taskType = UploadTaskTypeFile;
    self.filePath = _filePath;
    self.folder = _folder;
    self.isReady = YES;

    NSString *newUuid = [[NSUUID UUID] UUIDString];
    self.urlForUpload = [NSString stringWithFormat:@"%@/%@", APPDELEGATE.session.baseUrl, newUuid];
    self.fileUuid = newUuid;
    self.folderUuid = _folder ? _folder.uuid : nil;
}

- (void) configureUploadData:(NSData *) _dataToUpload atFolder:(MetaFile *) _folder withFileName:(NSString *) fileName {
    
    self.taskType = UploadTaskTypeData;
    self.isReady = YES;
    
    self.folder = _folder;
    self.fileData = _dataToUpload;
    
    NSString *newUuid = [[NSUUID UUID] UUIDString];
    self.fileUuid = newUuid;
    
    self.urlForUpload = [NSString stringWithFormat:@"%@/%@", APPDELEGATE.session.baseUrl, newUuid];
    self.folderUuid = _folder ? _folder.uuid : nil;
}

- (void) configureUploadAsset:(NSString *) _assetUrl atFolder:(MetaFile *) _folder {
    
    self.taskType = UploadTaskTypeAsset;
    self.isReady = YES;
    
    self.folder = _folder;
    self.folderUuid = _folder ? _folder.uuid : nil;
    self.assetUrl = _assetUrl;
    
    NSString *newUuid = [[NSUUID UUID] UUIDString];
    self.fileUuid = newUuid;
}

@end
