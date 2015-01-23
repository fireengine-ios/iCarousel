//
//  UploadManager.h
//  Depo
//
//  Created by Mahir on 10/2/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "MetaFile.h"
#import "UploadRef.h"
#import "UploadNotifyDao.h"
#import "AlbumAddPhotosDao.h"

@protocol UploadManagerDelegate <NSObject>
- (void) uploadManagerDidSendData:(long) sentBytes inTotal:(long) totalBytes;
- (void) uploadManagerDidFinishUploadingForAsset:(NSString *) assetUrl;
- (void) uploadManagerDidFailUploadingForAsset:(NSString *) assetUrl;
- (void) uploadManagerDidFinishUploadingAsData;
- (void) uploadManagerDidFailUploadingAsData;
@end

@class UploadManager;

@protocol UploadManagerQueueDelegate <NSObject>
- (void) uploadManager:(UploadManager *) manRef didFinishUploadingWithSuccess:(BOOL) success;
- (void) uploadManagerIsReadToStartTask:(UploadManager *) manRef;
- (void) uploadManagerTaskIsInitialized:(UploadManager *) manRef;
@end

@interface UploadManager : NSObject

@property (nonatomic, strong) id<UploadManagerDelegate> delegate;
@property (nonatomic, strong) id<UploadManagerQueueDelegate> queueDelegate;

@property (nonatomic, strong) NSURLSessionUploadTask *uploadTask;
@property (nonatomic, strong) UploadRef *uploadRef;

@property (nonatomic, strong) ALAssetsLibrary *assetsLibrary;
@property (nonatomic, strong) ALAsset *asset;

@property (nonatomic, strong) UploadNotifyDao *notifyDao;
@property (nonatomic, strong) AlbumAddPhotosDao *albumAddPhotosDao;


- (id) initWithUploadInfo:(UploadRef *) ref;

- (void) configureUploadFileForPath:(NSString *) filePath atFolder:(MetaFile *) _folder withFileName:(NSString *) fileName;
- (void) configureUploadData:(NSData *) _dataToUpload atFolder:(MetaFile *) _folder withFileName:(NSString *) fileName;
- (void) configureUploadAsset:(NSString *) assetUrl atFolder:(MetaFile *) _folder;

- (void) startTask;
- (void) removeTemporaryFile;
- (NSString *) uniqueUrl;
- (void) notifyUpload;

@end
