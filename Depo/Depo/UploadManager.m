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
#import "SyncUtil.h"
#import "MPush.h"
#import "ReachabilityManager.h"
#import "Reachability.h"

static const NSUInteger BufferSize = 1024*1024;

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
    NSString *bgTaskName = [NSString stringWithFormat:@"BG_TASK_%@", (self.uploadRef.taskType == UploadTaskTypeAsset) ? self.uploadRef.assetUrl : @""];
    bgTaskI = [[UIApplication sharedApplication] beginBackgroundTaskWithName:bgTaskName expirationHandler:^{
        
        self.uploadRef.hasFinished = YES;
        [delegate uploadManagerDidFailUploadingForAsset:self.uploadRef.assetUrl];
        [queueDelegate uploadManager:self didFinishUploadingWithSuccess:NO];
        if(self.uploadRef.autoSyncFlag) {
            [SyncUtil increaseAutoSyncIndex];
        }

        //TODO: uygulama suspenddeyken loc update geldiğinde tekrar background'a geliyor ama active olmuyor. O yüzden AutoSyncBlockInProgress unlock olmuyor. Background task expire olursa bu flag'i unlock etmenin en iyi yeri burası görünüyor. Netleştirip aşağıdaki satırı açabiliriz
        //[SyncUtil unlockAutoSyncBlockInProgress];
        
        [[UIApplication sharedApplication] endBackgroundTask:bgTaskI];
        bgTaskI = UIBackgroundTaskInvalid;
    }];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NetworkStatus networkStatus = [[[ReachabilityManager currentManager] reachability] currentReachabilityStatus];

        if(self.uploadRef.taskType == UploadTaskTypeAsset) {
            [self triggerAndStartAssetsTask];
        } else if(self.uploadRef.taskType == UploadTaskTypeFile) {
            self.uploadTask = [[UploadQueue sharedInstance].session uploadTaskWithRequest:[self prepareRequestSetVideo:NO] fromFile:[NSURL fileURLWithPath:self.uploadRef.filePath]];
            self.uploadTask.taskDescription = self.uploadRef.localHash;
            [uploadTask resume];
            
            [[CurioSDK shared] sendEvent:@"UploadStarted" eventValue:[NSString stringWithFormat:@"file type: %@", @"image"]];
            [MPush hitTag:@"photo_upload" withValue:(networkStatus == ReachableViaWWAN) ? @"3G" : @"Wifi"];
        } else {
            self.uploadTask = [[UploadQueue sharedInstance].session uploadTaskWithRequest:[self prepareRequestSetVideo:NO] fromData:self.uploadRef.fileData];
            self.uploadTask.taskDescription = self.uploadRef.localHash;
            [uploadTask resume];
            
            [[CurioSDK shared] sendEvent:@"UploadStarted" eventValue:[NSString stringWithFormat:@"file type: %@", @"image"]];
            [MPush hitTag:@"photo_upload" withValue:(networkStatus == ReachableViaWWAN) ? @"3G" : @"Wifi"];
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
                    if(_asset) {
                        if(self.asset == nil) {
                            NSURL *_assetUrl = _asset.defaultRepresentation.url;
                            if([[_assetUrl absoluteString] isEqualToString:self.uploadRef.assetUrl]) {
                                self.asset = _asset;
                                [self checkActiveTasksPreResume];
                                return;
                            }
                        }
                    }
                }];
            } else {
                if(self.asset == nil) {
                    IGLog(@"Asset is deleted from phone gallery. Returning didFinishUploadingWithSuccess:NO");
                    //fail case. queueda olan bir asset icin dosya galeriden silinmis
                    self.uploadRef.hasFinished = YES;
                    [delegate uploadManagerDidFailUploadingForAsset:self.uploadRef.assetUrl];
                    [queueDelegate uploadManager:self didFinishUploadingWithSuccess:NO];
                    if(self.uploadRef.autoSyncFlag) {
                        [SyncUtil increaseAutoSyncIndex];
                    }
                }
            }
        } failureBlock:^(NSError *error) {
        }];
    }
    @catch (NSException *exception) {
    }
    @finally {
    }
}

- (void) checkActiveTasksPreResume {
    [[UploadQueue sharedInstance].session getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
        BOOL continueUpload = YES;
        for(NSURLSessionUploadTask *task in uploadTasks) {
            if(task.taskDescription != nil && self.uploadRef.localHash != nil && [task.taskDescription isEqualToString:self.uploadRef.localHash]) {
                continueUpload = NO;
                break;
            }
        }
        if(continueUpload) {
            [self continueAssetUpload];
        } else {
            self.uploadRef.hasFinished = YES;
            [delegate uploadManagerDidFailUploadingForAsset:self.uploadRef.assetUrl];
            [queueDelegate uploadManager:self didFinishUploadingWithSuccess:NO];
            [SyncUtil increaseAutoSyncIndex];
        }
    }];
}

- (void) continueAssetUpload {
    if(self.uploadRef.autoSyncFlag) {
        if([SyncUtil localHashListContainsHash:self.uploadRef.localHash]){
            self.uploadRef.hasFinished = YES;
            [delegate uploadManagerDidFailUploadingForAsset:self.uploadRef.assetUrl];
            [queueDelegate uploadManager:self didFinishUploadingWithSuccess:NO];
            [SyncUtil increaseAutoSyncIndex];
            return;
        }
    }

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSString *randomVal = [NSString stringWithFormat:@"%.0f%d", [[NSDate date] timeIntervalSince1970], arc4random_uniform(99)];
    NSString *tempPath = [documentsDirectory stringByAppendingFormat:@"/DEPO_UPLOAD_FILE%@_%@", randomVal, self.asset.defaultRepresentation.filename];
    NSString *tempThumbnailPath = [documentsDirectory stringByAppendingFormat:@"/DEPO_UPLOAD_FILEthumb_%@_%@", randomVal, self.asset.defaultRepresentation.filename];

    self.uploadRef.tempUrl = tempPath;
    self.uploadRef.tempThumbnailUrl = tempThumbnailPath;
    
    NSString *fileType = @"image";
    NSString *dataMD5Hash = nil;
    BOOL shouldStartProcess = YES;
    
    if ([[self.asset valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypeVideo]) {
        NSURL *tempUrl = [NSURL fileURLWithPath:tempPath];
        [[NSFileManager defaultManager] createFileAtPath:tempPath contents:nil attributes:nil];
        NSFileHandle *handle = [NSFileHandle fileHandleForWritingToURL:tempUrl error:nil];
        if (!handle) {
            shouldStartProcess = NO;
        }
        
        ALAssetRepresentation *rep = [self.asset defaultRepresentation];
        uint8_t *buffer = calloc(BufferSize, sizeof(*buffer));
        NSUInteger offset = 0, bytesRead = 0;
        
        do {
            @try {
                bytesRead = [rep getBytes:buffer fromOffset:offset length:BufferSize error:nil];
                [handle writeData:[NSData dataWithBytesNoCopy:buffer length:bytesRead freeWhenDone:NO]];
                offset += bytesRead;
            } @catch (NSException *exception) {
                free(buffer);
                shouldStartProcess = NO;
            }
        } while (bytesRead > 0);
        
        free(buffer);
        
        /*
        @autoreleasepool {
            ALAssetRepresentation *rep = [asset defaultRepresentation];
            
            NSMutableData *videoData = [NSMutableData data];
            
            NSError *error;
            long long bufferOffset = 0ll;
            NSInteger bufferSize = 10000;
            long long bytesRemaining = [rep size];
            uint8_t buffer[bufferSize];
            NSUInteger bytesRead;
            while (bytesRemaining > 0) {
                bytesRead = [rep getBytes:buffer fromOffset:bufferOffset length:bufferSize error:&error];
                if (bytesRead == 0) {
                    return;
                }
                bytesRemaining -= bytesRead;
                bufferOffset   += bytesRead;
                [videoData appendBytes:buffer length:bytesRead];
            }
            shouldStartProcess = [videoData writeToFile:tempPath atomically:YES];
            dataMD5Hash = [SyncUtil md5String:videoData];
        }
         */
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
                    return;
                }
                bytesRemaining -= bytesRead;
                bufferOffset   += bytesRead;
                [imgData appendBytes:buffer length:bytesRead];
            }
            shouldStartProcess = [imgData writeToFile:tempPath atomically:YES];
            dataMD5Hash = [SyncUtil md5String:imgData];
        }

        @autoreleasepool {
            UIImage *thumbImage = [UIImage imageWithCGImage:self.asset.thumbnail];
            [UIImagePNGRepresentation(thumbImage) writeToFile:tempThumbnailPath atomically:YES];
        }
    }
    
    if(shouldStartProcess) {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSDictionary *attributesDict = [fileManager attributesOfItemAtPath:self.uploadRef.tempUrl error:NULL];
        long long fileSize = [attributesDict fileSize];
        shouldStartProcess = (fileSize > 0);
    }
    
    if(shouldStartProcess) {
        [[NSNotificationCenter defaultCenter] postNotificationName:TEMP_IMG_UPLOAD_NOTIFICATION object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:self.uploadRef.fileUuid, TEMP_IMG_UPLOAD_NOTIFICATION_UUID_PARAM, tempThumbnailPath, TEMP_IMG_UPLOAD_NOTIFICATION_URL_PARAM, nil]];
        
        self.uploadRef.fileName = self.asset.defaultRepresentation.filename;
        self.uploadRef.urlForUpload = [NSString stringWithFormat:@"%@/%@", APPDELEGATE.session.baseUrl, self.uploadRef.fileUuid];
        
        NSMutableURLRequest *uploadRequest = [self prepareRequestSetVideo:[[self.asset valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypeVideo]];
        if(dataMD5Hash != nil) {
            [uploadRequest setValue:dataMD5Hash forHTTPHeaderField:@"ETag"];
        }
        self.uploadTask = [[UploadQueue sharedInstance].session uploadTaskWithRequest:uploadRequest fromFile:[NSURL fileURLWithPath:self.uploadRef.tempUrl]];
        self.uploadTask.taskDescription = self.uploadRef.localHash;
        if(self.uploadRef.autoSyncFlag) {
            [SyncUtil cacheSyncHashLocally:self.uploadRef.localHash];
            [SyncUtil increaseAutoSyncIndex];
        }
        [uploadTask resume];
        
        NetworkStatus networkStatus = [[[ReachabilityManager currentManager] reachability] currentReachabilityStatus];
        [[CurioSDK shared] sendEvent:@"UploadStarted" eventValue:[NSString stringWithFormat:@"file type: %@", fileType]];
        [MPush hitTag:@"photo_upload" withValue:(networkStatus==ReachableViaWWAN)?@"3G":@"Wifi"];

        //    [queueDelegate uploadManagerTaskIsInitialized:self];
    } else {
        self.uploadRef.hasFinished = YES;
        [delegate uploadManagerDidFailUploadingForAsset:self.uploadRef.assetUrl];
        [queueDelegate uploadManager:self didFinishUploadingWithSuccess:NO];
        if(self.uploadRef.autoSyncFlag) {
            [SyncUtil increaseAutoSyncIndex];
        }
    }
}

- (void) removeTemporaryFile {
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        [fileManager removeItemAtPath:self.uploadRef.tempUrl error:nil];
        [fileManager removeItemAtPath:self.uploadRef.tempThumbnailUrl error:nil];
        NSLog(@"Removed From File Path");
    });
}

- (NSMutableURLRequest *) prepareRequestSetVideo:(BOOL) isVideo {
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:self.uploadRef.urlForUpload]];
    
    [request setTimeoutInterval:GENERAL_TASK_TIMEOUT];
    [request setHTTPMethod:@"PUT"];
    [request setValue:APPDELEGATE.session.authToken forHTTPHeaderField:@"X-Auth-Token"];
    [request setValue:@"false" forHTTPHeaderField:@"X-Object-Meta-Favourite"];
    [request setValue:[Util getWorkaroundUUID] forHTTPHeaderField:@"X-Object-Meta-Device-UUID"];
    [request setValue:@"1" forHTTPHeaderField:@"x-meta-strategy"];
    [request setValue:@"100-continue" forHTTPHeaderField:@"Expect"];

    if(self.uploadRef.referenceFolderName != nil && !isVideo) {
        NSString *utf8Str = [self.uploadRef.referenceFolderName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [request setValue:utf8Str forHTTPHeaderField:@"X-Object-Meta-Album-Label"];
    }

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
        [request setValue:@"MOBILE_UPLOAD" forHTTPHeaderField:@"X-Object-Meta-Special-Folder"];
    }

    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSDictionary *attributesDict = [fileManager attributesOfItemAtPath:self.uploadRef.tempUrl error:NULL];
    long long fileSize = [attributesDict fileSize];
    NSString *postLength = [NSString stringWithFormat:@"%lld", fileSize];
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

    [notifyDao requestNotifyUploadForFile:self.uploadRef.fileUuid atParentFolder:self.uploadRef.folder?self.uploadRef.folder.uuid:@"" withReferenceAlbumName:self.uploadRef.referenceFolderName];
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

- (NSUInteger) hash {
    return [self.uploadRef.localHash hash];
}

- (BOOL) isEqual:(id)other {
    if (other == self)
        return YES;
    if (!other || ![other isKindOfClass:[self class]])
        return NO;
    if(self.uploadRef == nil || ((UploadManager *)other).uploadRef == nil)
        return NO;
    return (self.uploadRef.autoSyncFlag && ((UploadManager *)other).uploadRef.autoSyncFlag && [self.uploadRef.localHash isEqualToString:((UploadManager *)other).uploadRef.localHash]);
}

@end
