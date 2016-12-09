//
//  DownloadManager.m
//  Depo
//
//  Created by Salih GUC on 30/11/2016.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DownloadManager.h"
#import "PhotoAlbum.h"
#import "AppDelegate.h"
#import "SyncUtil.h"
#import "DownloadedFile.h"

@implementation DownloadManager

-(DownloadManager *)initWithDelegate:(id<DownloadManagerDelegate>)delegateOwner
                        downloadType:(enum DownloadType) type
                      loadingMessage:(NSString *)loadingMessage
                      successMessage:(NSString *)successMesage
                         failMessage:(NSString *)failMessage {
    self = [super init];
    if (self) {
        self.delegate = delegateOwner;
        self.downloadType = type;
        self.loadingMessage = loadingMessage;
        self.successMessage = successMesage;
        self.failMessage = failMessage;
    }
    
    return self;
}

-(void)downloadListOfFilesToCameraRoll:(NSArray *)metaFiles {
    fileList = [[NSMutableArray alloc] initWithArray:metaFiles];
    NSArray *syncFiles = [SyncUtil getExistingFilesOfCameraRoll];
    if (syncFiles && syncFiles.count > 0) {
        existingFilesOnAlbum = [[NSMutableArray alloc] initWithArray:syncFiles];
//        downloadingAlbumName = @"";
        [self updateSyncedFilesOfAlbum:@""];
    }else {
        existingFilesOnAlbum = [[NSMutableArray alloc] init];
    }

    [self downloadFilesToCameraRoll];
}


#pragma mark - Album files Fetch

-(void)createAlbum:(NSString *)UUID withName:(NSString *)name withFiles:(NSArray *)metaFiles {
    if (metaFiles && metaFiles.count > 0) {
        fileList = [[NSMutableArray alloc] initWithArray:metaFiles];
    }else {
        fileList = [[NSMutableArray alloc] init];
    }
//    downloadingAlbumName = name;
    self.albumUUID = UUID;
    albumDetailDao = [[AlbumDetailDao alloc] init];
    albumDetailDao.delegate = self;
    albumDetailDao.successMethod = @selector(albumDetailSuccessCallback:);
    albumDetailDao.failMethod = @selector(albumDetailFailCallback:);
    
    NSArray *filesExisting = [SyncUtil getExistingFilesOfAlbum:name];
    if (filesExisting && filesExisting.count > 0) {
        existingFilesOnAlbum = [[NSMutableArray alloc] initWithArray:filesExisting];
        [self updateSyncedFilesOfAlbum:name];
    }else {
        existingFilesOnAlbum = [[NSMutableArray alloc] init];
        [self createAlbumOnSystemLibrary:name];
    }
}

-(void)fetchFilesForAlbum {
    NSLog(@"fetchFilesForAlbum: %@", self.albumUUID);
    albumDownloadListIndex = (int)fileList.count / 20;
    [albumDetailDao requestDetailOfAlbum:self.albumUUID forStart:albumDownloadListIndex andSize:20];
}


- (void) albumDetailSuccessCallback:(PhotoAlbum *) album{
    if (album.content.count == 0) {
        [self.delegate downloadManagerDidFinishDownloading:self error:nil];
        return;
    }
    for (MetaFile *file in album.content) {
        if (![self isFileAlreadyDownloaded:file]) {
            [fileList addObject:file];
        }
    }
    
    [self downloadAlbumPhotosToDevice:album.label];
}

-(BOOL)isFileAlreadyDownloaded:(MetaFile *)file {
    for (MetaFile *fileInTheList in fileList) {
        if ([fileInTheList.uuid isEqualToString:file.uuid]) {
            return YES;
        }
    }
    return NO;
}

- (void) albumDetailFailCallback:(NSString *) errorMessage {
    NSMutableDictionary* details = [NSMutableDictionary dictionary];
    [details setValue:@"Couldn't fetch album files from api" forKey:NSLocalizedDescriptionKey];
    NSError *error = [NSError errorWithDomain:@"Fetching album photos fail" code:400 userInfo:details];
    [self.delegate downloadManagerDidFinishDownloading:self error:error];
}

#pragma mark - Download Photos/Videos To CameraRoll

-(void)downloadFilesToCameraRoll {
    if (currentDownloadIndex < fileList.count) {
        MetaFile *file = [fileList objectAtIndex:currentDownloadIndex];
        if (file.contentType == ContentTypePhoto) {
            [self savePhotoFileToCameraRoll:file withAlbumName:@""];
        }else if (file.contentType == ContentTypeVideo) {
            [self saveVideoFileToCameraRoll:file withAlbumName:@""];
        }
        
        currentDownloadIndex++;
    }else {
        [self.delegate downloadManagerDidFinishDownloading:self error:nil];
    }
}

- (void)didFinishSavingFileToCameraRoll:(MetaFile *)file error:(NSError *)error {
    [self downloadFilesToCameraRoll];
    [self.delegate downloadManager:self didFinishSavingFile:file error:error];
   /* if(currentDownloadIndex == fileList.count) {
        [self.delegate downloadManagerDidFinishDownloading:self error:nil];
    }*/
}

-(void)didFinishSavingVideoFileToCameraRoll:(MetaFile *)file videoPath:(NSString *)videoPath error:(NSError *)error {
    @try {
        NSError *error = nil;
        [[NSFileManager defaultManager] removeItemAtPath:videoPath error:&error];
    }
    @catch (NSException *exception) {}
    @finally {
        [self didFinishSavingFileToCameraRoll:file error:error];
    }
}



-(void)savePhotoFileToCameraRoll:(MetaFile *)file  withAlbumName:(NSString*) albumName{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [self downloadImageWithURL:[NSURL URLWithString:file.tempDownloadUrl]
                   completionBlock:^(BOOL succeeded, UIImage *image) {
                       if (succeeded) {
                           __weak DownloadManager *weakSelf = self;
                           __block NSString *localizedAssetIdentifier = @"";
                           dispatch_async(dispatch_get_main_queue(), ^{
                               [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                                   PHAssetChangeRequest *changeRequest = [PHAssetChangeRequest creationRequestForAssetFromImage:image];
                                   PHObjectPlaceholder *assetPlaceHolder = [changeRequest placeholderForCreatedAsset];
                                   localizedAssetIdentifier = assetPlaceHolder.localIdentifier;
                               } completionHandler:^(BOOL success, NSError *error) {
                                   if (success) {
                                       [weakSelf saveFileToCameraRoll:file localizedIdentifier:localizedAssetIdentifier];
                                       NSLog(@"Save Image To CameraRoll Success");
                                   }
                                   else {
                                       NSLog(@"Save Image To Album Error: %@", error.description);
                                   }
                                   [self didFinishSavingFileToCameraRoll:file error:error];
                               }];
                           });
                       }else {
                           NSLog(@"downloadVideoWithURL Failed");
                           NSMutableDictionary* details = [NSMutableDictionary dictionary];
                           [details setValue:@"Couldn't download photo from Server" forKey:NSLocalizedDescriptionKey];
                           NSError *error = [NSError errorWithDomain:@"Download Photo" code:400 userInfo:details];
                           [self didFinishSavingFileToAlbum:file error:error withAlbumName:albumName];
                           //  [self image:nil didFinishSavingWithError:[[NSError alloc] init]];
                       }
                   }];
    });
}

-(void)saveVideoFileToCameraRoll:(MetaFile *)file  withAlbumName:(NSString*) albumName{
    NSURL *sourceURL = [NSURL URLWithString:file.tempDownloadUrl];
    NSString *contentType = @"mp4";
    NSArray *contentTypeComponents = [file.name componentsSeparatedByString:@"."];
    if(contentTypeComponents != nil && [contentTypeComponents count] > 0) {
        contentType = [contentTypeComponents objectAtIndex:[contentTypeComponents count]-1];
    }
    
    NSURLSessionTask *downloadTask = [[NSURLSession sharedSession] downloadTaskWithURL:sourceURL completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
        if (error) {
            NSMutableDictionary* details = [NSMutableDictionary dictionary];
            [details setValue:@"Couldn't download video from Server" forKey:NSLocalizedDescriptionKey];
            NSError *error = [NSError errorWithDomain:@"Download Video" code:400 userInfo:details];
            [self didFinishSavingFileToAlbum:file error:error withAlbumName:albumName];
            // [self showErrorAlertWithMessage:NSLocalizedString(@"DownloadVideoFailMessage", @"")];
        }
        else {
            NSURL *documentsURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory
                                                                          inDomains:NSUserDomainMask] firstObject];
            NSURL *tempURL = [documentsURL URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", [sourceURL lastPathComponent], contentType]];
            if (location) {
                //__weak DownloadManager *weakSelf = self;
                //__block NSString *localizedAssetIdentifier = @"";
                if ([[NSFileManager defaultManager] moveItemAtURL:location toURL:tempURL error:nil]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                            PHAssetChangeRequest *request = [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:tempURL];
                           /* PHObjectPlaceholder *assetPlaceHolder = [request placeholderForCreatedAsset];
                            PHAssetCollectionChangeRequest *albumChangeRequest = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:albumAssetCollection];
                            
                            localizedAssetIdentifier = assetPlaceHolder.localIdentifier; */
                        } completionHandler:^(BOOL success, NSError * _Nullable error) {
                            if (error) {
                                NSLog(@"Save Image To Album Error: %@", error.description);
                            }else {
                               // [weakSelf saveFileToCameraRoll:file localizedIdentifier:localizedAssetIdentifier];
                                NSLog(@"Save Image To Album Success uuid:%@", file.uuid);
                            }
                            [self didFinishSavingVideoFileToAlbum:file videoPath:tempURL.path  withAlbumName:albumName error:error];
                        }];
                    });
                }
            }
            else {
                [self didFinishSavingVideoFileToAlbum:file videoPath:tempURL.path withAlbumName:albumName error:error];
                NSMutableDictionary* details = [NSMutableDictionary dictionary];
                [details setValue:@"Couldn't find downloaded video location" forKey:NSLocalizedDescriptionKey];
                NSError *error = [NSError errorWithDomain:@"Video Location" code:400 userInfo:details];
                [self didFinishSavingFileToAlbum:file error:error withAlbumName:albumName];
                
                //[self showErrorAlertWithMessage:NSLocalizedString(@"DownloadVideoFailMessage", @"")];
            }
        }
    }];
    [downloadTask resume];
}

#pragma mark - Download Photos/Videos To Album

-(void)downloadAlbumPhotosToDevice:(NSString*)albumName {
    NSLog(@"downloadAlbumPhotosToDevice - currentDownloadIndex: %d", currentDownloadIndex);
    if (currentDownloadIndex < fileList.count) {
        MetaFile *file = [fileList objectAtIndex:currentDownloadIndex];
        if ([self isFileAlreadySyncedToAlbum:file.uuid]) {
            currentDownloadIndex++;
            [self downloadAlbumPhotosToDevice:albumName];
        }else if (file.contentType == ContentTypePhoto) {
            [self savePhotoFileToAlbum:file withAlbumName:albumName];
            currentDownloadIndex++;
        }else if (file.contentType == ContentTypeVideo) {
            [self saveVideoFileToAlbum:file withAlbumName:albumName];
            currentDownloadIndex++;
        }
    }
    else if(currentDownloadIndex == fileList.count) {
        NSLog(@"[self fetchOtherFilesOfAlbum]");
        if (fileList.count < 20 || (fileList.count % 20) > 0) { // album has less than 20 items or album has 47 items
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                [self.delegate downloadManagerDidFinishDownloading:self error:nil];
            });
        }
        else {
            [self fetchFilesForAlbum];
        }
    }
    else {
        [self.delegate downloadManagerDidFinishDownloading:self error:nil];
    }
}

-(void)savePhotoFileToAlbum:(MetaFile *)file withAlbumName:(NSString*)albumName{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [self downloadImageWithURL:[NSURL URLWithString:file.tempDownloadUrl]
                   completionBlock:^(BOOL succeeded, UIImage *image) {
                       if (succeeded) {
                           __weak DownloadManager *weakSelf = self;
                           __block NSString *localizedAssetIdentifier = @"";
                           dispatch_async(dispatch_get_main_queue(), ^{
                               [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                                   PHAssetChangeRequest *request = [PHAssetChangeRequest creationRequestForAssetFromImage:image];
                                   PHObjectPlaceholder *assetPlaceHolder = [request placeholderForCreatedAsset];
                                   PHAssetCollectionChangeRequest *albumChangeRequest = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:albumAssetCollection];
                                  
                                   localizedAssetIdentifier = assetPlaceHolder.localIdentifier;
                                   [albumChangeRequest addAssets:@[assetPlaceHolder]];
                               } completionHandler:^(BOOL success, NSError * _Nullable error) {
                                   if (error) {
                                       NSLog(@"Save Image To Album Error: %@", error.description);
                                   }else {
                                       [weakSelf saveFileToSyncedFiles:file localizedIdentifier:localizedAssetIdentifier withName:albumName];
                                       NSLog(@"Save Image To Album Success uuid:%@", file.uuid);
                                   }
                                   [self didFinishSavingFileToAlbum:file error:error withAlbumName:albumName];
                               }];
                           });
                       }else {
                           NSLog(@"downloadImageWithURL Failed");
                           NSMutableDictionary* details = [NSMutableDictionary dictionary];
                           [details setValue:@"Couldn't download photo from Server" forKey:NSLocalizedDescriptionKey];
                           NSError *error = [NSError errorWithDomain:@"Download Photo" code:400 userInfo:details];
                           [self didFinishSavingFileToAlbum:file error:error withAlbumName:albumName];
                       }
                   }];
    });
}

-(void)saveVideoFileToAlbum:(MetaFile *)file withAlbumName:(NSString*)albumName{
    NSURL *sourceURL = [NSURL URLWithString:file.tempDownloadUrl];
    NSString *contentType = @"mp4";
    NSArray *contentTypeComponents = [file.name componentsSeparatedByString:@"."];
    if(contentTypeComponents != nil && [contentTypeComponents count] > 0) {
        contentType = [contentTypeComponents objectAtIndex:[contentTypeComponents count]-1];
    }
    
    NSURLSessionTask *downloadTask = [[NSURLSession sharedSession] downloadTaskWithURL:sourceURL completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
        if (error) {
            NSMutableDictionary* details = [NSMutableDictionary dictionary];
            [details setValue:@"Couldn't download video from Server" forKey:NSLocalizedDescriptionKey];
            NSError *error = [NSError errorWithDomain:@"Download Video" code:400 userInfo:details];
            [self didFinishSavingFileToAlbum:file error:error withAlbumName:albumName];
           // [self showErrorAlertWithMessage:NSLocalizedString(@"DownloadVideoFailMessage", @"")];
        }
        else {
            NSURL *documentsURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory
                                                                          inDomains:NSUserDomainMask] firstObject];
            NSURL *tempURL = [documentsURL URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", [sourceURL lastPathComponent], contentType]];
            if (location) {
                NSError *error;
                __weak DownloadManager *weakSelf = self;
                __block NSString *localizedAssetIdentifier = @"";
                if ([[NSFileManager defaultManager] moveItemAtURL:location toURL:tempURL error:&error]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                            PHAssetChangeRequest *request = [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:tempURL];
                            PHObjectPlaceholder *assetPlaceHolder = [request placeholderForCreatedAsset];
                            PHAssetCollectionChangeRequest *albumChangeRequest = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:albumAssetCollection];
                            localizedAssetIdentifier = assetPlaceHolder.localIdentifier;
                            [albumChangeRequest addAssets:@[assetPlaceHolder]];
                        } completionHandler:^(BOOL success, NSError * _Nullable error) {
                            if (error) {
                                NSLog(@"Save Video To Album Error: %@", error.description);
                            }else {
                                [weakSelf saveFileToSyncedFiles:file localizedIdentifier:localizedAssetIdentifier withName:albumName];
                                NSLog(@"Save Video To Album Success uuid:%@", file.uuid);
                            }
                            [self didFinishSavingVideoFileToAlbum:file videoPath:tempURL.path withAlbumName:albumName error:error];
                        }];
                    });
                }else {
                    [self didFinishSavingVideoFileToAlbum:file videoPath:tempURL.path withAlbumName:albumName error:error];
                }
            }
            else {
                NSMutableDictionary* details = [NSMutableDictionary dictionary];
                [details setValue:@"Couldn't find downloaded video location" forKey:NSLocalizedDescriptionKey];
                NSError *error = [NSError errorWithDomain:@"Video Location" code:400 userInfo:details];
                [self didFinishSavingFileToAlbum:file error:error withAlbumName:albumName];
            }
        }
    }];
    [downloadTask resume];
}


- (void)didFinishSavingFileToAlbum:(MetaFile *)file error:(NSError *)error withAlbumName:(NSString*) albumName{
    [self.delegate downloadManager:self didFinishSavingFile:file error:error];
    [self downloadAlbumPhotosToDevice:albumName];
}

-(void)didFinishSavingVideoFileToAlbum:(MetaFile *)file videoPath:(NSString *)videoPath  withAlbumName:(NSString*) albumName error:(NSError *)error {
    @try {
        NSError *error = nil;
        [[NSFileManager defaultManager] removeItemAtPath:videoPath error:&error];
    }
    @catch (NSException *exception) {}
    @finally {
        
        [self didFinishSavingFileToAlbum:file error:error withAlbumName:albumName];
    }
}


#pragma mark - Downloaded File Sync

-(BOOL)isFileAlreadySyncedToAlbum:(NSString *)fileUUID {
    for (DownloadedFile *file in existingFilesOnAlbum) {
        if ([file.fileUUID isEqualToString:fileUUID]) {
            return YES;
        }
    }
    return NO;
}

-(void)saveFileToSyncedFiles:(MetaFile *)file localizedIdentifier:(NSString *)localizedIdentifier withName:(NSString*)albumName{
    DownloadedFile *downloadedFile = [[DownloadedFile alloc] initWithFileUUID:file.uuid
                                                              localIdentifier:localizedIdentifier
                                                                  inAlbumName:albumName];
    [existingFilesOnAlbum addObject:downloadedFile];
    [SyncUtil updateLoadedFiles:existingFilesOnAlbum inAlbum:albumName];
    [self insertFileToAutosyncCache:file localizedIdentifier:localizedIdentifier];
}

-(void)saveFileToCameraRoll:(MetaFile *)file localizedIdentifier:(NSString *)localizedIdentifier {
    DownloadedFile *downloadedFile = [[DownloadedFile alloc] initWithFileUUID:file.uuid
                                                              localIdentifier:localizedIdentifier
                                                                  inAlbumName:@"-1CameraRoll"];
    [existingFilesOnAlbum addObject:downloadedFile];
    [SyncUtil updateLoadedFilesInCameraRoll:existingFilesOnAlbum];
    [self insertFileToAutosyncCache:file localizedIdentifier:localizedIdentifier];
}

-(void)insertFileToAutosyncCache:(MetaFile *)file localizedIdentifier:(NSString *)localizedIdentifier {
    NSArray *seperateds = [localizedIdentifier componentsSeparatedByString:@"/"];
    PHFetchOptions *options = [[PHFetchOptions alloc] init];
    options.predicate = [NSPredicate predicateWithFormat:@"localIdentifier=%@", seperateds[0]];
    PHFetchResult<PHAsset *> *assets = [PHAsset fetchAssetsInAssetCollection:albumAssetCollection options:options];
    [assets enumerateObjectsUsingBlock:^(PHAsset * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        
        [[PHImageManager defaultManager]
         requestImageDataForAsset:obj
         options:nil
         resultHandler:^(NSData *imageData, NSString *dataUTI,
                         UIImageOrientation orientation,
                         NSDictionary *info)
         {
             NSString *normalizedIdentifier = [NSString stringWithFormat:@"assets-library://asset/asset.JPG?id=%@&ext=JPG", seperateds[0]];
             if ([info objectForKey:@"PHImageFileURLKey"]) {
                 NSURL *fileURL = [info objectForKey:@"PHImageFileURLKey"];
                 NSArray *paths = [fileURL.absoluteString componentsSeparatedByString:@"."];
                 NSString *ext = [paths lastObject];
                 normalizedIdentifier = [normalizedIdentifier stringByReplacingOccurrencesOfString:@"JPG" withString:ext];
             }
             NSString *localHash = [SyncUtil md5StringOfString:normalizedIdentifier];
             NSLog(@"saved file localHash: %@ - identifier: %@", localHash, normalizedIdentifier);
             [SyncUtil cacheSyncHashLocally:localHash];
             [SyncUtil increaseAutoSyncIndex];
         }];
    }];

}

-(void)updateSyncedFilesOfAlbum:(NSString*)name {
    PHFetchOptions *fetchOptions = [[PHFetchOptions alloc] init];
    fetchOptions.predicate = [NSPredicate predicateWithFormat:@"title=%@", name];
    PHFetchResult *userAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAny options:fetchOptions];
    if (userAlbums.count == 0) {
        [existingFilesOnAlbum removeAllObjects];
        [SyncUtil removeAlbumFromSync:name];
        [self createAlbumOnSystemLibrary:name];
    }else {
        [userAlbums enumerateObjectsUsingBlock:^(PHAssetCollection *collection, NSUInteger idx, BOOL *stop) {
            PHFetchResult<PHAsset *> *assets = [PHAsset fetchAssetsInAssetCollection:collection options:nil];
            NSMutableArray *files = [NSMutableArray array];
            [assets enumerateObjectsUsingBlock:^(PHAsset * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                DownloadedFile *file = [self getAssetLocalIdentifierFileInSyncedList:obj.localIdentifier];
                if (file) {
                    [files addObject:file];
                   // [syncedFilesOnAlbum removeObject:file];
                }
            }];
            existingFilesOnAlbum = files;
            [SyncUtil updateLoadedFiles:existingFilesOnAlbum inAlbum:name];
            [self createAlbumOnSystemLibrary:name];
        }];
    }
    
}

-(DownloadedFile *)getAssetLocalIdentifierFileInSyncedList:(NSString *)localIdentifier {
    for (DownloadedFile *file in existingFilesOnAlbum) {
        if ([file.fileLocalIdentifier isEqualToString:localIdentifier]) {
            return file;
        }
    }
    return nil;
}

#pragma mark - Download Image From Server

- (void)downloadImageWithURL:(NSURL *)url completionBlock:(void (^)(BOOL succeeded, UIImage *image))completionBlock {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               if ( !error )
                               {
                                   UIImage *image = [[UIImage alloc] initWithData:data];
                                   completionBlock(YES, image);
                               } else{
                                   completionBlock(NO, nil);
                               }
                           }];
}


#pragma mark - Create Album

-(void)createAlbumOnSystemLibrary:(NSString *)albumName {
    currentDownloadIndex = 0;
    
    PHFetchOptions *options = [[PHFetchOptions alloc] init];
    options.predicate = [NSPredicate predicateWithFormat:@"title = %@", albumName];
    PHFetchResult *collection = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum
                                                                         subtype:PHAssetCollectionSubtypeAny options:options];
    if (collection.firstObject) { // Album already exists.
        albumAssetCollection = (PHAssetCollection *)collection.firstObject;
        [self.delegate downloadManager:self albumAlreadyExistNamed:albumName assetCollection:albumAssetCollection];
        if (fileList.count == 0) {
            [self fetchFilesForAlbum];
        }else {
            [self downloadAlbumPhotosToDevice:albumName];
        }
    }else { // create the album
        __weak DownloadManager *weakSelf = self;
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            PHAssetCollectionChangeRequest *request = [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:albumName];
            albumAssetCollectionPlaceHolder = request.placeholderForCreatedAssetCollection;
            
        } completionHandler:^(BOOL success, NSError * _Nullable error) {
            if (success) {
                PHFetchResult *result = [PHAssetCollection fetchAssetCollectionsWithLocalIdentifiers:@[albumAssetCollectionPlaceHolder.localIdentifier] options:nil];
                albumAssetCollection = (PHAssetCollection *)result.firstObject;
                
                [SyncUtil createAlbumToSync:albumName];
                [weakSelf.delegate downloadManager:self newAlbumCreatedNamed:albumName assetCollection:albumAssetCollection];
                if (fileList.count == 0) {
                    [self fetchFilesForAlbum];
                }else {
                    [weakSelf downloadAlbumPhotosToDevice:albumName];
                }
            }else {
                [weakSelf.delegate downloadManager:self createAlbumError:error];
            }
        }];
    }
}
@end