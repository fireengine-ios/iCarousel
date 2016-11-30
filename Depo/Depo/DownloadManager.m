//
//  DownloadManager.m
//  Depo
//
//  Created by Salih GUC on 30/11/2016.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DownloadManager.h"


@implementation DownloadManager


-(DownloadManager *)initWithDelegate:(id<DownloadManagerDelegate>)delegateOwner {
    self = [super init];
    if (self) {
        self.delegate = delegateOwner;
    }
    
    return self;
}

-(void)downloadListOfFilesToCameraRoll:(NSArray *)metaFiles {
    fileList = metaFiles;
    [self downloadFilesToCameraRoll];
}

-(void)createAlbumName:(NSString *)albumName downloadFilesToAlbum:(NSArray *)metaFiles {
    fileList = metaFiles;
    [self createAlbumInPhotoAlbum:albumName];
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
    if (currentDownloadIndex < fileList.count) {
        MetaFile *file = [fileList objectAtIndex:currentDownloadIndex];
        if (file.contentType == ContentTypePhoto) {
            [self savePhotoFileToAlbum:file];
        }else if (file.contentType == ContentTypeVideo) {
            [self saveVideoFileToAlbum:file];
        }
        
        currentDownloadIndex++;
    }else {
        [self.delegate downloadManagerDidFinishDownloading:self error:nil];
    }
}

-(void)savePhotoFileToAlbum:(MetaFile *)file {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [self downloadImageWithURL:[NSURL URLWithString:file.tempDownloadUrl]
                   completionBlock:^(BOOL succeeded, UIImage *image) {
                       if (succeeded) {
                           dispatch_async(dispatch_get_main_queue(), ^{
                               [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                                   PHAssetChangeRequest *request = [PHAssetChangeRequest creationRequestForAssetFromImage:image];
                                   PHObjectPlaceholder *assetPlaceHolder = [request placeholderForCreatedAsset];
                                   PHAssetCollectionChangeRequest *albumChangeRequest = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:albumAssetCollection];
                                   [albumChangeRequest addAssets:@[assetPlaceHolder]];
                               } completionHandler:^(BOOL success, NSError * _Nullable error) {
                                   if (error) {
                                       NSLog(@"Save Image To Album Error: %@", error.description);
                                   }else {
                                       NSLog(@"Save Image To Album Success");
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
                if ([[NSFileManager defaultManager] moveItemAtURL:location toURL:tempURL error:&error]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                            PHAssetChangeRequest *request = [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:tempURL];
                            PHObjectPlaceholder *assetPlaceHolder = [request placeholderForCreatedAsset];
                            PHAssetCollectionChangeRequest *albumChangeRequest = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:albumAssetCollection];
                            [albumChangeRequest addAssets:@[assetPlaceHolder]];
                        } completionHandler:^(BOOL success, NSError * _Nullable error) {
                            [self didFinishSavingVideoFileToAlbum:file videoPath:tempURL.path error:error];
                        }];
                    });
                }else {
        //            NSMutableDictionary* details = [NSMutableDictionary dictionary];
        //            [details setValue:@"Couldn't move downloaded video location to temp file" forKey:NSLocalizedDescriptionKey];
        //            NSError *error = [NSError errorWithDomain:@"Video Location" code:400 userInfo:details];
                    [self didFinishSavingVideoFileToAlbum:file videoPath:tempURL.path error:error];
                  //  [self didFinishSavingFileToAlbum:file error:error];
                }
            }
            else {
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

- (void)didFinishSavingFileToAlbum:(MetaFile *)file error:(NSError *)error {
    [self downloadAlbumPhotosToDevice];
    [self.delegate downloadManager:self didFinishSavingFile:file error:error];
    if(currentDownloadIndex == fileList.count) {
        [self.delegate downloadManagerDidFinishDownloading:self error:nil];
    }
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
        [self downloadAlbumPhotosToDevice];
    }else { // create the album
        __weak DownloadManager *weakSelf = self;
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            PHAssetCollectionChangeRequest *request = [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:albumName];
            albumAssetCollectionPlaceHolder = request.placeholderForCreatedAssetCollection;
            
        } completionHandler:^(BOOL success, NSError * _Nullable error) {
            if (success) {
                PHFetchResult *result = [PHAssetCollection fetchAssetCollectionsWithLocalIdentifiers:@[albumAssetCollectionPlaceHolder.localIdentifier] options:nil];
                albumAssetCollection = (PHAssetCollection *)result.firstObject;
                [weakSelf.delegate downloadManager:self newAlbumCreatedNamed:albumName assetCollection:albumAssetCollection];
                [weakSelf downloadAlbumPhotosToDevice];
            }else {
                [weakSelf.delegate downloadManager:self createAlbumError:error];
            }
        }];
    }
}


@end