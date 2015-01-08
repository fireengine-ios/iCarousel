//
//  UploadManager.h
//  Depo
//
//  Created by Mahir on 10/2/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "UploadNotifyDao.h"
#import "MetaFile.h"
#import "UploadRef.h"

@protocol UploadManagerDelegate <NSObject>
- (void) uploadManagerDidSendData:(long) sentBytes inTotal:(long) totalBytes;
- (void) uploadManagerDidFinishUploadingForAsset:(ALAsset *) assetToUpload;
- (void) uploadManagerDidFailUploadingForAsset:(ALAsset *) assetToUpload;
- (void) uploadManagerDidFinishUploadingAsData;
- (void) uploadManagerDidFailUploadingAsData;
@end

@class UploadManager;

@protocol UploadManagerQueueDelegate <NSObject>
- (void) uploadManager:(UploadManager *) manRef didFinishUploadingWithSuccess:(BOOL) success;
- (void) uploadManagerIsReadToStartTask:(UploadManager *) manRef;
@end

@interface UploadManager : NSObject <NSURLSessionDelegate, NSURLSessionTaskDelegate> {
    UploadNotifyDao *notifyDao;
    NSURLSession *session;
    NSString *tempPath;
}

@property (nonatomic, strong) id<UploadManagerDelegate> delegate;
@property (nonatomic, strong) id<UploadManagerQueueDelegate> queueDelegate;
@property (nonatomic, strong) ALAsset *asset;
@property (nonatomic, strong) ALAssetsLibrary *assetsLibrary;
@property (nonatomic, strong) MetaFile *folder;
@property (nonatomic, strong) UIImage *largeimage;
@property (nonatomic, strong) UploadRef *uploadRef;
@property (nonatomic, strong) NSDate *initializationDate;
@property (nonatomic) UploadTaskType taskType;
@property (nonatomic, strong) NSURLSessionUploadTask *uploadTask;
@property (nonatomic) BOOL hasFinished;
@property (nonatomic) BOOL isReady;

@property (nonatomic, strong) NSString *fileNameRef;
@property (nonatomic, strong) NSString *filePathRef;
@property (nonatomic, strong) NSData *fileDataRef;

- (id) initWithUploadReference:(UploadRef *) ref;
- (void) startUploadingAsset:(NSString *) assetUrl atFolder:(MetaFile *) _folder;
- (void) startUploadingData:(NSData *) _dataToUpload atFolder:(MetaFile *) _folder withFileName:(NSString *) fileName;
- (void) startUploadingFile:(NSString *) filePath atFolder:(MetaFile *) _folder withFileName:(NSString *) fileName;
- (void) startTask;

@end
