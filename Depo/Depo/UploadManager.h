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

@protocol UploadManagerDelegate <NSObject>
- (void) uploadManagerDidSendData:(int) bytes forAsset:(ALAsset *) assetToUpload;
- (void) uploadManagerDidFinishUploadingForAsset:(ALAsset *) assetToUpload;
- (void) uploadManagerDidFailUploadingForAsset:(ALAsset *) assetToUpload;
- (void) uploadManagerDidFinishUploadingAsData;
- (void) uploadManagerDidFailUploadingAsData;
@end

@interface UploadManager : NSObject <NSURLSessionDelegate, NSURLSessionTaskDelegate> {
    NSURLSessionUploadTask *uploadTask;
    UploadNotifyDao *notifyDao;
    NSURLSession *session;
}

@property (nonatomic, strong) id<UploadManagerDelegate> delegate;
@property (nonatomic, strong) ALAsset *asset;
@property (nonatomic, strong) ALAssetsLibrary *assetsLibrary;
@property (nonatomic, strong) NSString *urlForUpload;
@property (nonatomic, strong) MetaFile *folder;
@property (nonatomic, strong) UIImage *largeimage;

- (id) initWithAssetsLibrary:(ALAssetsLibrary *) assetsLib;
- (void) startUploadingAsset:(ALAsset *) _asset atFolder:(MetaFile *) _folder;
- (void) startUploadingData:(NSData *) _dataToUpload atFolder:(MetaFile *) _folder withFileName:(NSString *) fileName;
- (void) startUploadingFile:(NSString *) filePath atFolder:(MetaFile *) _folder withFileName:(NSString *) fileName;

@end
