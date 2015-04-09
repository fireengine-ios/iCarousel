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
#import "UploadQueue.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "CurioSDK.h"

typedef void (^ALAssetsLibraryAssetForURLResultBlock)(ALAsset *asset);
typedef void (^ALAssetsLibraryAccessFailureBlock)(NSError *error);

@implementation UploadManager

@synthesize delegate;
@synthesize queueDelegate;
@synthesize uploadTask;
@synthesize uploadRef;
@synthesize assetsLibrary;
@synthesize asset;
@synthesize notifyDao;
@synthesize albumAddPhotosDao;
@synthesize bgTaskI;

- (id) initWithUploadInfo:(UploadRef *) ref {
    if(self = [super init]) {
        self.uploadRef = ref;
        self.uploadRef.initializationDate = [NSDate date];
    }
    return self;
}

- (void) configureUploadFileForPath:(NSString *) filePath atFolder:(MetaFile *) _folder withFileName:(NSString *) fileName {
    [self.uploadRef configureUploadFileForPath:filePath atFolder:_folder withFileName:fileName];
}

- (void) configureUploadAsset:(NSString *) assetUrl atFolder:(MetaFile *) _folder {
    [self.uploadRef configureUploadAsset:assetUrl atFolder:_folder];
}

- (void) startTask {
    bgTaskI = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [[UIApplication sharedApplication] endBackgroundTask:bgTaskI];
    }];
    
    dispatch_queue_t uploadQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
    dispatch_async(uploadQueue, ^{
        if(self.uploadRef.taskType == UploadTaskTypeAsset) {
            [self triggerAndStartAssetsTask];
        } else if(self.uploadRef.taskType == UploadTaskTypeFile) {
            self.uploadTask = [APPDELEGATE.uploadQueue.session uploadTaskWithRequest:[self prepareRequestSetVideo:NO] fromFile:[NSURL fileURLWithPath:self.uploadRef.filePath]];
            [uploadTask resume];
            
            [[CurioSDK shared] sendEvent:@"upload_started" eventValue:[NSString stringWithFormat:@"file type: %@", @"image"]];
        } else {
            self.uploadTask = [APPDELEGATE.uploadQueue.session uploadTaskWithRequest:[self prepareRequestSetVideo:NO] fromData:self.uploadRef.fileData];
            [uploadTask resume];
            
            [[CurioSDK shared] sendEvent:@"upload_started" eventValue:[NSString stringWithFormat:@"file type: %@", @"image"]];
        }
    });
}

- (void) triggerAndStartAssetsTask {
    self.asset = nil;
    
    @try {
        self.assetsLibrary = [[ALAssetsLibrary alloc] init];
        [assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll | ALAssetsGroupLibrary usingBlock:^(ALAssetsGroup *group, BOOL *outerStop) {
            if(group) {
                [group enumerateAssetsUsingBlock:^(ALAsset *_asset, NSUInteger index, BOOL *innerStop) {
                    if(_asset && !self.asset) {
                        NSURL *_assetUrl = _asset.defaultRepresentation.url;
                        if([[_assetUrl absoluteString] isEqualToString:self.uploadRef.assetUrl]) {
                            self.asset = _asset;
                            [self continueAssetUpload];
                            return;
                        }
                    }
                }];
            }
        } failureBlock:^(NSError *error) {
        }];
    }
    @catch (NSException *exception) {
    }
    @finally {
    }
}

- (void) continueAssetUpload {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSString *randomVal = [NSString stringWithFormat:@"%.0f%d", [[NSDate date] timeIntervalSince1970], arc4random_uniform(99)];
    NSString *tempPath = [documentsDirectory stringByAppendingFormat:@"/%@_%@", randomVal, self.asset.defaultRepresentation.filename];
    NSString *tempThumbnailPath = [documentsDirectory stringByAppendingFormat:@"/thumb_%@_%@", randomVal, self.asset.defaultRepresentation.filename];

    self.uploadRef.tempUrl = tempPath;
    self.uploadRef.tempThumbnailUrl = tempThumbnailPath;
    
    NSString *fileType = @"image";
    BOOL writeSuccess = YES;
    
    if ([[self.asset valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypeVideo]) {
//        @autoreleasepool {
            ALAssetRepresentation *rep = [self.asset defaultRepresentation];
            unsigned long dataSize = (unsigned long)[rep size];
            Byte *buffer = (Byte *) malloc(dataSize);
            NSUInteger buffered = [rep getBytes:buffer fromOffset:0.0 length:rep.size error:nil];
            NSData *videoData = [NSData dataWithBytesNoCopy:buffer length:buffered freeWhenDone:YES];
            writeSuccess = [videoData writeToFile:tempPath atomically:YES];
//        }
        fileType = @"video";
    } else {
        UIImageOrientation orientation = UIImageOrientationUp;
        NSNumber* orientationValue = [self.asset valueForProperty:@"ALAssetPropertyOrientation"];
        if (orientationValue != nil) {
            orientation = [orientationValue intValue];
        }
        
        @autoreleasepool {
            ALAssetRepresentation *rep = [asset defaultRepresentation];
            
            NSMutableData *imgData = [NSMutableData data];
            
            NSError *error;
            long long bufferOffset = 0ll;
            NSInteger bufferSize = 10000;
            long long bytesRemaining = [rep size];
            uint8_t buffer[bufferSize];
            NSUInteger bytesRead;
            while (bytesRemaining > 0) {
                bytesRead = [rep getBytes:buffer fromOffset:bufferOffset length:bufferSize error:&error];
                if (bytesRead == 0) {
                    NSLog(@"error reading asset representation: %@", error);
                    return;
                }
                bytesRemaining -= bytesRead;
                bufferOffset   += bytesRead;
                [imgData appendBytes:buffer length:bytesRead];
            }
            writeSuccess = [imgData writeToFile:tempPath atomically:YES];
        }

        @autoreleasepool {
            UIImage *thumbImage = [UIImage imageWithCGImage:self.asset.thumbnail];
            [UIImagePNGRepresentation(thumbImage) writeToFile:tempThumbnailPath atomically:YES];
        }
    }
    
    if(writeSuccess) {
        [[NSNotificationCenter defaultCenter] postNotificationName:TEMP_IMG_UPLOAD_NOTIFICATION object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:self.uploadRef.fileUuid, TEMP_IMG_UPLOAD_NOTIFICATION_UUID_PARAM, tempThumbnailPath, TEMP_IMG_UPLOAD_NOTIFICATION_URL_PARAM, nil]];
        
        self.uploadRef.fileName = self.asset.defaultRepresentation.filename;
        self.uploadRef.urlForUpload = [NSString stringWithFormat:@"%@/%@", APPDELEGATE.session.baseUrl, self.uploadRef.fileUuid];
        
        self.uploadTask = [APPDELEGATE.uploadQueue.session uploadTaskWithRequest:[self prepareRequestSetVideo:[[self.asset valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypeVideo]] fromFile:[NSURL fileURLWithPath:self.uploadRef.tempUrl]];
        [uploadTask resume];
        
        [[CurioSDK shared] sendEvent:@"upload_started" eventValue:[NSString stringWithFormat:@"file type: %@", fileType]];

        //    [queueDelegate uploadManagerTaskIsInitialized:self];
    } else {
        self.uploadRef.hasFinished = YES;
        [delegate uploadManagerDidFailUploadingForAsset:self.uploadRef.assetUrl];
        [queueDelegate uploadManager:self didFinishUploadingWithSuccess:NO];
    }
}

- (void) removeTemporaryFile {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:self.uploadRef.tempUrl error:nil];
    [fileManager removeItemAtPath:self.uploadRef.tempThumbnailUrl error:nil];
}

- (NSMutableURLRequest *) prepareRequestSetVideo:(BOOL) isVideo {
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:self.uploadRef.urlForUpload]];
    
    [request setHTTPMethod:@"PUT"];
    [request setValue:APPDELEGATE.session.authToken forHTTPHeaderField:@"X-Auth-Token"];
    [request setValue:@"false" forHTTPHeaderField:@"X-Object-Meta-Favourite"];
    [request setValue:[Util getWorkaroundUUID] forHTTPHeaderField:@"X-Object-Meta-Device-UUID"];
    [request setValue:@"1" forHTTPHeaderField:@"x-meta-strategy"];
    [request setValue:@"100-continue" forHTTPHeaderField:@"Expect"];
    if(self.uploadRef.folder) {
        [request setValue:self.uploadRef.folder.uuid forHTTPHeaderField:@"X-Object-Meta-Parent-Uuid"];
    } else {
        [request setValue:@"" forHTTPHeaderField:@"X-Object-Meta-Parent-Uuid"];
    }
    [request setValue:self.uploadRef.fileName forHTTPHeaderField:@"X-Object-Meta-File-Name"];
    if(self.uploadRef.mimeType != nil) {
        [request addValue:self.uploadRef.mimeType forHTTPHeaderField:@"Content-Type"];
    } else {
        if (isVideo) {
            [request addValue:@"video/mp4" forHTTPHeaderField:@"Content-Type"];
        } else {
            [request addValue:@"image/png" forHTTPHeaderField:@"Content-Type"];
        }
    }
    if(self.uploadRef.localHash != nil) {
        [request setValue:self.uploadRef.localHash forHTTPHeaderField:@"X-Object-Meta-Ios-Metadata-Hash"];
    }
    if(self.uploadRef.autoSyncFlag || self.uploadRef.ownerPage == UploadStarterPagePhotos) {
        NSLog(@"X-Object-Meta-Special-Folder SET for img: %@", self.uploadRef.fileName);
        [request setValue:@"MOBILE_UPLOAD" forHTTPHeaderField:@"X-Object-Meta-Special-Folder"];
    } else {
        NSLog(@"X-Object-Meta-Special-Folder NOT SET for img: %@", self.uploadRef.fileName);
    }

    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSDictionary *attributesDict = [fileManager attributesOfItemAtPath:self.uploadRef.tempUrl error:NULL];
    long long fileSize = [attributesDict fileSize];
    NSString *postLength = [NSString stringWithFormat:@"%lld", fileSize];
    NSLog(@"CONTENT_LENGTH: %@", postLength);
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    
    return request;
}

- (NSString *) uniqueUrl {
    if(self.uploadRef.assetUrl != nil) {
        return self.uploadRef.assetUrl;
    }
    return self.uploadRef.tempUrl;
}

- (void) notifyUpload {
    notifyDao = [[UploadNotifyDao alloc] init];
    notifyDao.delegate = self;
    notifyDao.successMethod = @selector(uploadNotifySuccessCallback:);
    notifyDao.failMethod = @selector(uploadNotifyFailCallback:);

    [notifyDao requestNotifyUploadForFile:self.uploadRef.fileUuid atParentFolder:self.uploadRef.folder?self.uploadRef.folder.uuid:@""];
}

- (void) uploadNotifySuccessCallback:(MetaFile *) finalFile {
    self.uploadRef.finalFile = finalFile;
    
    if(self.uploadRef.albumUuid != nil) {
        [self notifyAlbum];
    } else {
        self.uploadRef.hasFinished = YES;
        [delegate uploadManagerDidFinishUploadingForAsset:self.uploadRef.assetUrl withFinalFile:self.uploadRef.finalFile];
        [queueDelegate uploadManager:self didFinishUploadingWithSuccess:YES];
    }
}

- (void) uploadNotifyFailCallback:(NSString *) errorMessage {
    self.uploadRef.hasFinished = YES;
    [delegate uploadManagerDidFailUploadingForAsset:self.uploadRef.assetUrl];
    [queueDelegate uploadManager:self didFinishUploadingWithSuccess:NO];
}

- (void) notifyAlbum {
    albumAddPhotosDao = [[AlbumAddPhotosDao alloc] init];
    albumAddPhotosDao.delegate = self;
    albumAddPhotosDao.successMethod = @selector(notifyAlbumSuccessCallback);
    albumAddPhotosDao.failMethod = @selector(notifyAlbumFailCallback:);

    [albumAddPhotosDao requestAddPhotos:@[self.uploadRef.fileUuid] toAlbum:self.uploadRef.albumUuid];
}

- (void) notifyAlbumSuccessCallback {
    self.uploadRef.hasFinished = YES;
    [delegate uploadManagerDidFinishUploadingForAsset:self.uploadRef.assetUrl withFinalFile:self.uploadRef.finalFile];
    [queueDelegate uploadManager:self didFinishUploadingWithSuccess:YES];
}

- (void) notifyAlbumFailCallback:(NSString *) errorMessage {
    self.uploadRef.hasFinished = YES;
    [delegate uploadManagerDidFinishUploadingForAsset:self.uploadRef.assetUrl withFinalFile:self.uploadRef.finalFile];
    [queueDelegate uploadManager:self didFinishUploadingWithSuccess:NO];
}

@end
