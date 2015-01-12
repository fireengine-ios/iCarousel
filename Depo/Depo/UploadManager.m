//
//  UploadManager.m
//  Depo
//
//  Created by Mahir on 10/2/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "UploadManager.h"
#import "AppDelegate.h"
#import "AppSession.h"
#import "Util.h"
#import "AppUtil.h"

typedef void (^ALAssetsLibraryAssetForURLResultBlock)(ALAsset *asset);
typedef void (^ALAssetsLibraryAccessFailureBlock)(NSError *error);

@implementation UploadManager

@synthesize delegate;
@synthesize queueDelegate;

@synthesize asset;
@synthesize assetsLibrary;
@synthesize folder;
@synthesize largeimage;
@synthesize uploadRef;
@synthesize initializationDate;
@synthesize taskType;
@synthesize hasFinished;
@synthesize isReady;
@synthesize uploadTask;

- (id) initWithUploadReference:(UploadRef *) ref {
    if(self = [super init]) {
        self.uploadRef = ref;
        self.initializationDate = [NSDate date];
        
        NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration  defaultSessionConfiguration];
        session = [NSURLSession sessionWithConfiguration:sessionConfig delegate:self delegateQueue:nil];
        
        notifyDao = [[UploadNotifyDao alloc] init];
        notifyDao.delegate = self;
        notifyDao.successMethod = @selector(uploadNotifySuccessCallback);
        notifyDao.failMethod = @selector(uploadNotifyFailCallback:);
    }
    return self;
}

- (void) startUploadingFile:(NSString *) filePath atFolder:(MetaFile *) _folder withFileName:(NSString *) fileName {
    self.taskType = UploadTaskTypeFile;
    self.isReady = YES;

    NSString *newUuid = [[NSUUID UUID] UUIDString];
    self.folder = _folder;
    
    self.uploadRef.urlForUpload = [NSString stringWithFormat:@"%@/%@", APPDELEGATE.session.baseUrl, newUuid];
    self.uploadRef.fileUuid = newUuid;
    self.uploadRef.folderUuid = _folder ? _folder.uuid : nil;
    
    self.fileNameRef = fileName;
    self.filePathRef = filePath;
}

- (void) startUploadingData:(NSData *) _dataToUpload atFolder:(MetaFile *) _folder withFileName:(NSString *) fileName {
    self.taskType = UploadTaskTypeData;
    self.isReady = YES;

    self.folder = _folder;
    
    NSString *newUuid = [[NSUUID UUID] UUIDString];
    self.uploadRef.fileUuid = newUuid;

    self.uploadRef.urlForUpload = [NSString stringWithFormat:@"%@/%@", APPDELEGATE.session.baseUrl, newUuid];
    self.uploadRef.folderUuid = _folder ? _folder.uuid : nil;
    
    self.fileNameRef = fileName;
    self.fileDataRef = _dataToUpload;
}

- (void) startUploadingAsset:(NSString *) assetUrl atFolder:(MetaFile *) _folder {
    self.taskType = UploadTaskTypeAsset;

    self.folder = _folder;
    self.assetsLibrary = [[ALAssetsLibrary alloc] init];
    self.uploadRef.folderUuid = _folder ? _folder.uuid : nil;

    NSString *newUuid = [[NSUUID UUID] UUIDString];
    self.uploadRef.fileUuid = newUuid;
    
    [assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        if(group) {
            [group enumerateAssetsUsingBlock:^(ALAsset *_asset, NSUInteger index, BOOL *stop) {
                if(_asset && !asset) {
                    NSURL *_assetUrl = _asset.defaultRepresentation.url;
                    if([[_assetUrl absoluteString] isEqualToString:assetUrl]) {
                        self.asset = _asset;
                        [self triggerAndStartAssetsTask];
                    }
                }
            }];
        }
    } failureBlock:^(NSError *error) {
    }];
}

- (void) triggerAndStartAssetsTask {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSString *randomVal = [NSString stringWithFormat:@"%.0f%d", [[NSDate date] timeIntervalSince1970], arc4random_uniform(99)];
    tempPath = [documentsDirectory stringByAppendingFormat:@"/%@_%@", randomVal, asset.defaultRepresentation.filename];
    NSLog(@"TEMP PATH: %@", tempPath);
    self.uploadRef.tempUrl = tempPath;
    
    if ([[self.asset valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypeVideo]) {
        ALAssetRepresentation *rep = [self.asset defaultRepresentation];
        Byte *buffer = (Byte*)malloc(rep.size);
        NSUInteger buffered = [rep getBytes:buffer fromOffset:0.0 length:rep.size error:nil];
        NSData *videoData = [NSData dataWithBytesNoCopy:buffer length:buffered freeWhenDone:YES];
        [videoData writeToFile:tempPath atomically:YES];
    } else {
        ALAssetOrientation imgOrientation = [[self.asset valueForProperty:@"ALAssetPropertyOrientation"] intValue];
        UIImage *image = [UIImage imageWithCGImage:[asset.defaultRepresentation fullResolutionImage] scale:1.0 orientation:imgOrientation];
        [UIImagePNGRepresentation(image) writeToFile:tempPath atomically:YES];
    }

    [[NSNotificationCenter defaultCenter] postNotificationName:TEMP_IMG_UPLOAD_NOTIFICATION object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:self.uploadRef.fileUuid, TEMP_IMG_UPLOAD_NOTIFICATION_UUID_PARAM, tempPath, TEMP_IMG_UPLOAD_NOTIFICATION_URL_PARAM, nil]];

    self.fileNameRef = asset.defaultRepresentation.filename;
    self.uploadRef.urlForUpload = [NSString stringWithFormat:@"%@/%@", APPDELEGATE.session.baseUrl, self.uploadRef.fileUuid];
    
    self.isReady = YES;
    [queueDelegate uploadManagerIsReadToStartTask:self];
}

- (void) startTask {
    if(self.taskType == UploadTaskTypeAsset) {
        uploadTask = [session uploadTaskWithRequest:[self prepareRequestWithFileName:self.fileNameRef] fromFile:[NSURL fileURLWithPath:self.uploadRef.tempUrl] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            NSHTTPURLResponse *httpResp = (NSHTTPURLResponse*) response;
            if (!error && httpResp.statusCode == 201) {
                [self removeTemporaryFile];
                [notifyDao requestNotifyUploadForFile:self.uploadRef.fileUuid atParentFolder:self.folder?self.folder.uuid:@""];
            } else {
                [self removeTemporaryFile];
                [delegate uploadManagerDidFailUploadingForAsset:self.asset];
                hasFinished = YES;
            }
        }];
        [uploadTask resume];
    } else if(self.taskType == UploadTaskTypeFile) {
        uploadTask = [session uploadTaskWithRequest:[self prepareRequestWithFileName:self.fileNameRef] fromFile:[NSURL fileURLWithPath:self.filePathRef] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            NSHTTPURLResponse *httpResp = (NSHTTPURLResponse*) response;
            if (!error && httpResp.statusCode == 201) {
                [notifyDao requestNotifyUploadForFile:self.uploadRef.fileUuid atParentFolder:self.folder?self.folder.uuid : @""];
            } else {
                [delegate uploadManagerDidFailUploadingAsData];
                hasFinished = YES;
            }
        }];
        [uploadTask resume];
    } else {
        uploadTask = [session uploadTaskWithRequest:[self prepareRequestWithFileName:self.fileNameRef] fromData:self.fileDataRef completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            NSHTTPURLResponse *httpResp = (NSHTTPURLResponse*) response;
            if (!error && httpResp.statusCode == 201) {
                [notifyDao requestNotifyUploadForFile:self.uploadRef.fileUuid atParentFolder:self.folder?self.folder.uuid:@""];
            } else {
                [delegate uploadManagerDidFailUploadingAsData];
                hasFinished = YES;
            }
        }];
        [uploadTask resume];
    }
}

- (void) removeTemporaryFile {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:tempPath error:nil];
    [delegate uploadManagerDidFailUploadingForAsset:self.asset];
}

- (NSMutableURLRequest *) prepareRequestWithFileName:(NSString *) fileName {
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:self.uploadRef.urlForUpload]];
    
    [request setHTTPMethod:@"PUT"];
    [request setValue:APPDELEGATE.session.authToken forHTTPHeaderField:@"X-Auth-Token"];
    [request setValue:@"false" forHTTPHeaderField:@"X-Object-Meta-Favourite"];
    [request setValue:@"1" forHTTPHeaderField:@"x-meta-strategy"];
    if(self.folder) {
        [request setValue:self.folder.uuid forHTTPHeaderField:@"X-Object-Meta-Parent-Uuid"];
    } else {
        [request setValue:@"" forHTTPHeaderField:@"X-Object-Meta-Parent-Uuid"];
    }
    [request setValue:fileName forHTTPHeaderField:@"X-Object-Meta-File-Name"];
    if ([[self.asset valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypeVideo]) {
        [request addValue:@"video/mp4" forHTTPHeaderField:@"Content-Type"];
    } else {
        [request addValue:@"image/png" forHTTPHeaderField:@"Content-Type"];
    }
    return request;
}

- (void) uploadNotifySuccessCallback {
    hasFinished = YES;
    [delegate uploadManagerDidFinishUploadingForAsset:self.asset];
    [queueDelegate uploadManager:self didFinishUploadingWithSuccess:YES];

    self.fileDataRef = nil;
    self.fileNameRef = nil;
    self.filePathRef = nil;
}

- (void) uploadNotifyFailCallback:(NSString *) errorMessage {
    hasFinished = YES;
    [delegate uploadManagerDidFailUploadingForAsset:self.asset];
    [queueDelegate uploadManager:self didFinishUploadingWithSuccess:NO];

    self.fileDataRef = nil;
    self.fileNameRef = nil;
    self.filePathRef = nil;
}

- (void) URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didSendBodyData:(int64_t)bytesSent totalBytesSent:(int64_t)totalBytesSent totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend {
    [delegate uploadManagerDidSendData:(long)totalBytesSent inTotal:(long)totalBytesExpectedToSend];
}

@end
