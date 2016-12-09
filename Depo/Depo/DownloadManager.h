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
#import "AlbumDetailDao.h"


enum DownloadType {
    DownloadTypeAlbum = 1,
    DownloadTypeListOfFiles
};

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
    NSMutableArray *fileList;
    
    int albumDownloadListIndex;
    NSString *downloadingAlbumName;
    AlbumDetailDao *albumDetailDao;
    NSMutableArray *existingFilesOnAlbum;
}

@property (nonatomic, assign) id<DownloadManagerDelegate> delegate;
@property (nonatomic, assign) enum DownloadType downloadType;
@property (nonatomic, strong) NSString *successMessage;
@property (nonatomic, strong) NSString *failMessage;
@property (nonatomic, strong) NSString *loadingMessage;
@property (nonatomic, strong) NSString *albumUUID;

-(DownloadManager *)initWithDelegate:(id<DownloadManagerDelegate>)delegateOwner
                        downloadType:(enum DownloadType)type
                      loadingMessage:(NSString *)loadingMessage
                      successMessage:(NSString *)successMesage
                         failMessage:(NSString *)failMessage;

-(void)downloadListOfFilesToCameraRoll:(NSArray *)metaFiles;
-(void)createAlbum:(NSString *)UUID withName:(NSString *)name withFiles:(NSArray *)metaFiles;
@end