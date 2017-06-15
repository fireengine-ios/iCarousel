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
@synthesize referenceFolderName;
@synthesize fileUuid;
@synthesize tempUrl;
@synthesize tempThumbnailUrl;
@synthesize assetUrl;
@synthesize urlForUpload;
@synthesize albumUuid;
@synthesize fileData;
@synthesize contentType;
@synthesize hasFinished;
@synthesize hasFinishedWithError;
@synthesize isReady;
@synthesize autoSyncFlag;
@synthesize retryDoneForTokenFlag;
@synthesize taskType;
@synthesize folder;
@synthesize finalFile;
@synthesize initializationDate;
@synthesize localHash;
@synthesize remoteHash;
@synthesize ownerPage;
@synthesize summary;
@synthesize mimeType;

- (void) configureUploadFileForPath:(NSString *) _filePath atFolder:(MetaFile *) _folder withFileName:(NSString *) fileName {

    self.taskType = UploadTaskTypeFile;
    self.filePath = _filePath;
    self.folder = _folder;
    self.isReady = YES;

    NSString *newUuid = [[NSUUID UUID] UUIDString];
    self.urlForUpload = [NSString stringWithFormat:@"%@/%@", APPDELEGATE.session.baseUrl, newUuid];
    self.fileUuid = newUuid;
    self.folderUuid = _folder ? _folder.uuid : folderUuid ? folderUuid : nil;
}

- (void) configureUploadAsset:(NSString *) _assetUrl atFolder:(MetaFile *) _folder {
    
    self.taskType = UploadTaskTypeAsset;
    self.isReady = YES;
    
    self.folder = _folder;
    self.folderUuid = _folder ? _folder.uuid : folderUuid ? folderUuid : nil;
    self.assetUrl = _assetUrl;
    
    NSString *newUuid = [[NSUUID UUID] UUIDString];
    self.fileUuid = newUuid;
}

@end
