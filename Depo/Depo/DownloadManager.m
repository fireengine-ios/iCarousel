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
        [self showLoadingProcessView];
    }
    
    return self;
}

-(void)downloadListOfFilesToCameraRoll:(NSArray *)metaFiles {
    fileList = [[NSMutableArray alloc] initWithArray:metaFiles];
    [self downloadFilesToCameraRoll];
}


#pragma mark - Loading Process View

-(void)showLoadingProcessView {
    CGRect windowFrame = APPDELEGATE.window.frame;
    processView = [[ProcessFooterView alloc] initWithFrame:CGRectMake(0, windowFrame.size.height - 60, windowFrame.size.width, 60) withProcessMessage:self.loadingMessage withFinalMessage:self.successMessage withFailMessage:self.failMessage];
    processView.delegate = self;
    [APPDELEGATE.window addSubview:processView];
    [APPDELEGATE.window bringSubviewToFront:processView];
    
    [processView startLoading];
    [self performSelector:@selector(hideProcessView) withObject:nil afterDelay:2];
}

-(void)hideProcessView {
    processView.hidden = true;
}

-(void)hideLoadingProcessViewWithError:(NSError *)error {
    if (error) {
        [processView showMessageForFailure];
    }else {
        [processView showMessageForSuccess];
    }
}

#pragma mark - Album files Fetch

-(void)createAlbumName:(NSString *)albumName albumUUID:(NSString *)albumUuid {
    fileList = [[NSMutableArray alloc] init];
    downloadingAlbumName = albumName;
    self.albumUUID = albumUuid;
    [self initAlbumDetailDao];
    
    NSArray *syncFiles = [SyncUtil loadDownloadedFilesForAlbum:albumName];
    if (syncFiles && syncFiles.count > 0) {
        syncedFilesOnAlbum = [[NSMutableArray alloc] initWithArray:syncFiles];
        [self updateSyncedFilesOfAlbum];
    }else {
        syncedFilesOnAlbum = [[NSMutableArray alloc] init];
        [self createAlbumInPhotoAlbum:albumName];
    }
}

-(void)createAlbumName:(NSString *)albumName albumUUID:(NSString *)albumUuid downloadFilesToAlbum:(NSArray *)metaFiles {
    if (metaFiles && metaFiles.count > 0) {
        fileList = [[NSMutableArray alloc] initWithArray:metaFiles];
    }else {
        fileList = [[NSMutableArray alloc] init];
    }
    downloadingAlbumName = albumName;
    self.albumUUID = albumUuid;
    [self initAlbumDetailDao];
    
    NSArray *syncFiles = [SyncUtil loadDownloadedFilesForAlbum:albumName];
    if (syncFiles && syncFiles.count > 0) {
        syncedFilesOnAlbum = [[NSMutableArray alloc] initWithArray:syncFiles];
        [self updateSyncedFilesOfAlbum];
    }else {
        syncedFilesOnAlbum = [[NSMutableArray alloc] init];
        [self createAlbumInPhotoAlbum:albumName];
    }
}

-(void)loadSynchedFilesForAlbum:(NSString *)albumName {
    NSArray *syncFiles = [SyncUtil loadDownloadedFilesForAlbum:albumName];
    if (syncFiles && syncFiles.count > 0) {
        syncedFilesOnAlbum = [[NSMutableArray alloc] initWithArray:syncFiles];
         [self updateSyncedFilesOfAlbum];
    }else {
        syncedFilesOnAlbum = [[NSMutableArray alloc] init];
    }
}

-(void)initAlbumDetailDao {
    albumDetailDao = [[AlbumDetailDao alloc] init];
    albumDetailDao.delegate = self;
    albumDetailDao.successMethod = @selector(albumDetailSuccessCallback:);
    albumDetailDao.failMethod = @selector(albumDetailFailCallback:);
}

-(void)fetchFilesForAlbum {
    NSLog(@"fetchFilesForAlbum: %@", self.albumUUID);
    albumDownloadListIndex = (int)fileList.count / 20;
    [albumDetailDao requestDetailOfAlbum:self.albumUUID forStart:albumDownloadListIndex andSize:20];
}


-(void)fetchOtherFilesOfAlbum {
    if (fileList.count < 20) { // album has less than 20 items
        [self.delegate downloadManagerDidFinishDownloading:self error:nil];
        return;
    }else if ((fileList.count % 20) > 0) { // album has 47 items
        [self.delegate downloadManagerDidFinishDownloading:self error:nil];
        return;
    }
    [self fetchFilesForAlbum];
}

- (void) albumDetailSuccessCallback:(PhotoAlbum *) albumWithUpdatedContent {
    if (albumWithUpdatedContent.content.count == 0) {
        [self.delegate downloadManagerDidFinishDownloading:self error:nil];
        return;
    }
    for (MetaFile *file in albumWithUpdatedContent.content) {
        if (![self isFileAlreadyDownloaded:file]) {
            [fileList addObject:file];
        }
    }
    
    [self downloadAlbumPhotosToDevice];
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
            [self savePhotoFileToCameraRoll:file];
        }else if (file.contentType == ContentTypeVideo) {
            [self saveVideoFileToCameraRoll:file];
        }
        
        currentDownloadIndex++;
    }else {
        [self.delegate downloadManagerDidFinishDownloading:self error:nil];
    }
}

- (void)didFinishSavingFileToCameraRoll:(MetaFile *)file error:(NSError *)error {
    [self downloadFilesToCameraRoll];
    [self.delegate downloadManager:self didFinishSavingFile:file error:error];
    if(currentDownloadIndex == fileList.count) {
        [self.delegate downloadManagerDidFinishDownloading:self error:nil];
    }
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



-(void)savePhotoFileToCameraRoll:(MetaFile *)file {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [self downloadImageWithURL:[NSURL URLWithString:file.tempDownloadUrl]
                   completionBlock:^(BOOL succeeded, UIImage *image) {
                       if (succeeded) {
                           dispatch_async(dispatch_get_main_queue(), ^{
                               
                           /*    if ([self isPhotoExistInCameraRoll:file]) {
                                   [self didFinishSavingFileToCameraRoll:file error:nil];
                                   return;
                               }
                               */
                               [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                                   PHAssetChangeRequest *changeRequest = [PHAssetChangeRequest creationRequestForAssetFromImage:image];
                               } completionHandler:^(BOOL success, NSError *error) {
                                   if (success) {
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
                           [self didFinishSavingFileToAlbum:file error:error];
                           //  [self image:nil didFinishSavingWithError:[[NSError alloc] init]];
                       }
                   }];
    });
}

-(void)saveVideoFileToCameraRoll:(MetaFile *)file {
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
            [self didFinishSavingFileToAlbum:file error:error];
            // [self showErrorAlertWithMessage:NSLocalizedString(@"DownloadVideoFailMessage", @"")];
        }
        else {
            NSURL *documentsURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory
                                                                          inDomains:NSUserDomainMask] firstObject];
            NSURL *tempURL = [documentsURL URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", [sourceURL lastPathComponent], contentType]];
            if (location) {
                if ([[NSFileManager defaultManager] moveItemAtURL:location toURL:tempURL error:nil]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                            PHAssetChangeRequest *request = [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:tempURL];
                        } completionHandler:^(BOOL success, NSError * _Nullable error) {
                            [self didFinishSavingVideoFileToAlbum:file videoPath:tempURL.path error:error];
                        }];
                    });
                }
            }
            else {
                [self didFinishSavingVideoFileToAlbum:file videoPath:tempURL.path error:error];
                NSMutableDictionary* details = [NSMutableDictionary dictionary];
                [details setValue:@"Couldn't find downloaded video location" forKey:NSLocalizedDescriptionKey];
                NSError *error = [NSError errorWithDomain:@"Video Location" code:400 userInfo:details];
                [self didFinishSavingFileToAlbum:file error:error];
                
                //[self showErrorAlertWithMessage:NSLocalizedString(@"DownloadVideoFailMessage", @"")];
            }
        }
    }];
    [downloadTask resume];
}

#pragma mark - Download Photos/Videos To Album

-(void)downloadAlbumPhotosToDevice {
    NSLog(@"downloadAlbumPhotosToDevice - currentDownloadIndex: %d", currentDownloadIndex);
    if (currentDownloadIndex < fileList.count) {
        MetaFile *file = [fileList objectAtIndex:currentDownloadIndex];
        if ([self isFileAlreadySyncedToAlbum:file.uuid]) {
            currentDownloadIndex++;
            [self downloadAlbumPhotosToDevice];
        }else if (file.contentType == ContentTypePhoto) {
            [self savePhotoFileToAlbum:file];
            currentDownloadIndex++;
        }else if (file.contentType == ContentTypeVideo) {
            [self saveVideoFileToAlbum:file];
            currentDownloadIndex++;
        }
    }else if(currentDownloadIndex == fileList.count) {
        NSLog(@"[self fetchOtherFilesOfAlbum]");
        [self fetchOtherFilesOfAlbum];
    }else {
        [self.delegate downloadManagerDidFinishDownloading:self error:nil];
    }
}

-(void)savePhotoFileToAlbum:(MetaFile *)file {
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
                                       [weakSelf saveFileToSynchedFiles:file localizedIdentifier:localizedAssetIdentifier];
                                       NSLog(@"Save Image To Album Success uuid:%@", file.uuid);
                                   }
                                   [self didFinishSavingFileToAlbum:file error:error];
                               }];
                           });
                       }else {
                           NSLog(@"downloadImageWithURL Failed");
                           NSMutableDictionary* details = [NSMutableDictionary dictionary];
                           [details setValue:@"Couldn't download photo from Server" forKey:NSLocalizedDescriptionKey];
                           NSError *error = [NSError errorWithDomain:@"Download Photo" code:400 userInfo:details];
                           [self didFinishSavingFileToAlbum:file error:error];
                       }
                   }];
    });
}

-(void)saveVideoFileToAlbum:(MetaFile *)file {
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
            [self didFinishSavingFileToAlbum:file error:error];
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
                                [weakSelf saveFileToSynchedFiles:file localizedIdentifier:localizedAssetIdentifier];
                                NSLog(@"Save Video To Album Success uuid:%@", file.uuid);
                            }
                            [self didFinishSavingVideoFileToAlbum:file videoPath:tempURL.path error:error];
                        }];
                    });
                }else {
                    [self didFinishSavingVideoFileToAlbum:file videoPath:tempURL.path error:error];
                }
            }
            else {
                NSMutableDictionary* details = [NSMutableDictionary dictionary];
                [details setValue:@"Couldn't find downloaded video location" forKey:NSLocalizedDescriptionKey];
                NSError *error = [NSError errorWithDomain:@"Video Location" code:400 userInfo:details];
                [self didFinishSavingFileToAlbum:file error:error];
            }
        }
    }];
    [downloadTask resume];
}





- (void)didFinishSavingFileToAlbum:(MetaFile *)file error:(NSError *)error {
    [self.delegate downloadManager:self didFinishSavingFile:file error:error];
    [self downloadAlbumPhotosToDevice];
}

-(void)didFinishSavingVideoFileToAlbum:(MetaFile *)file videoPath:(NSString *)videoPath error:(NSError *)error {
    @try {
        NSError *error = nil;
        [[NSFileManager defaultManager] removeItemAtPath:videoPath error:&error];
    }
    @catch (NSException *exception) {}
    @finally {
        
        [self didFinishSavingFileToAlbum:file error:error];
    }
}


#pragma mark - Downloaded File Sync

-(BOOL)isFileAlreadySyncedToAlbum:(NSString *)fileUUID {
    for (DownloadedFile *file in syncedFilesOnAlbum) {
        if ([file.fileUUID isEqualToString:fileUUID]) {
            return YES;
        }
    }
    return NO;
}

-(void)saveFileToSynchedFiles:(MetaFile *)file localizedIdentifier:(NSString *)localizedIdentifier {
    DownloadedFile *downloadedFile = [[DownloadedFile alloc] initWithFileUUID:file.uuid
                                                              localIdentifier:localizedIdentifier
                                                                  inAlbumName:downloadingAlbumName];
    [syncedFilesOnAlbum addObject:downloadedFile];
    [SyncUtil updateLoadedFiles:syncedFilesOnAlbum inAlbum:downloadingAlbumName];
}

-(void)updateSyncedFilesOfAlbum {
    PHFetchResult *userAlbums = [PHAssetCollection fetchAssetCollectionsWithLocalIdentifiers:@[downloadingAlbumName] options:nil];
    if (userAlbums.count == 0) {
        [SyncUtil removeAlbumFromSync:downloadingAlbumName];
        [self createAlbumInPhotoAlbum:downloadingAlbumName];
    }else {
        [userAlbums enumerateObjectsUsingBlock:^(PHAssetCollection *collection, NSUInteger idx, BOOL *stop) {
            PHFetchResult<PHAsset *> *assets = [PHAsset fetchAssetsInAssetCollection:collection options:nil];
            [assets enumerateObjectsUsingBlock:^(PHAsset * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                DownloadedFile *file = [self getAssetLocalIdentifierFileInSyncedList:obj.localIdentifier];
                if (file) {
                    [syncedFilesOnAlbum removeObject:file];
                }
            }];
            [self createAlbumInPhotoAlbum:downloadingAlbumName];
        }];
    }
    
}

-(DownloadedFile *)getAssetLocalIdentifierFileInSyncedList:(NSString *)localIdentifier {
    for (DownloadedFile *file in syncedFilesOnAlbum) {
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

-(void)createAlbumInPhotoAlbum:(NSString *)albumName {
    currentDownloadIndex = 0;
    
    PHFetchOptions *options = [[PHFetchOptions alloc] init];
    options.predicate = [NSPredicate predicateWithFormat:@"title = %@", albumName];
    PHFetchResult *collection = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum
                                                                         subtype:PHAssetCollectionSubtypeAny options:options];
    if (collection.firstObject) { // Album already exist.
        albumAssetCollection = (PHAssetCollection *)collection.firstObject;
        [self.delegate downloadManager:self albumAlreadyExistNamed:albumName assetCollection:albumAssetCollection];
        if (fileList.count == 0) {
            [self fetchFilesForAlbum];
        }else {
            [self downloadAlbumPhotosToDevice];
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
                    [weakSelf downloadAlbumPhotosToDevice];
                }
            }else {
                [weakSelf.delegate downloadManager:self createAlbumError:error];
            }
        }];
    }
}


#pragma mark - Process Footer Delegate

-(void)processFooterShouldDismissWithButtonKey:(NSString *)postButtonKeyVal {
    [self.delegate downloadManagerDidFinishDownloading:self error:nil];
}

@end