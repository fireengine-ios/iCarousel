//
//  DownloadManager.h
//  Depo
//
//  Created by Salih GUC on 30/11/2016.
//  Copyright © 2016 com.igones. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <Photos/Photos.h>
#import "MetaFile.h"

@class DownloadManager;
@protocol DownloadManagerDelegate
-(void)downloadManager:(DownloadManager *)manager albumAlreadyExistNamed:(NSString *)albumName assetCollection:(PHAssetCollection *)assetCollection;
-(void)downloadManager:(DownloadManager *)manager newAlbumCreatedNamed:(NSString *)albumName assetCollection:(PHAssetCollection *)assetCollection;
-(void)downloadManager:(DownloadManager *)manager createAlbumError:(NSError *)error;
-(void)downloadManager:(DownloadManager *)manager didFinishSavingFile:(MetaFile *)file error:(NSError *)error;
-(void)downloadManagerDidFinishDownloading:(DownloadManager *)manager error:(NSError *)error;
@end

@interface DownloadManager : NSObject {
    PHAssetCollection *albumAssetCollection;
    PHObjectPlaceholder *albumAssetCollectionPlaceHolder;
    int currentDownloadIndex;
    NSArray *fileList;
}

@property (nonatomic, assign) id<DownloadManagerDelegate> delegate;

-(DownloadManager *)initWithDelegate:(id<DownloadManagerDelegate>)delegateOwner;

-(void)downloadListOfFilesToCameraRoll:(NSArray *)metaFiles;

-(void)createAlbumName:(NSString *)albumName downloadFilesToAlbum:(NSArray *)metaFiles;
@end