//
//  ExtensionUploadManager.h
//  Depo
//
//  Created by Mahir on 17/07/15.
//  Copyright (c) 2015 com.igones. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

@protocol ExtensionUploadManagerDelegate <NSObject>

- (void) extensionUploadIsAtPercent:(int) percent;
- (void) extensionUploadHasFinished;
- (void) extensionUploadShouldRelogin;
- (void) extensionUploadHasFailed:(NSError *) error;

@end

@interface ExtensionUploadManager : NSObject <NSURLSessionDelegate, NSURLSessionTaskDelegate>

@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, weak) id<ExtensionUploadManagerDelegate> delegate;
@property (nonatomic, strong) NSURLSessionTask *currentTask;

+ (ExtensionUploadManager *) sharedInstance;
- (void) startUploadForImage:(UIImage *) img withData:(NSData *) imageData fileName:(NSString *) name;
- (void) startUploadForVideoData:(NSData *)videoData forPath:(NSURL *)path;
//- (void) startUploadForVideoData:(NSData *) videoData withExtension:(NSString *) ext;
- (void) startUploadForDoc:(NSData *) docData withContentType:(NSString *) contentType withExt:(NSString *) ext;
- (void) startUploadForVideoLink:(NSURL *) assetUrl;
- (void) cancelTask;

@end
