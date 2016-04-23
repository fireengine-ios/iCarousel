//
//  ExtensionUploadManager.h
//  Depo
//
//  Created by Mahir on 17/07/15.
//  Copyright (c) 2015 com.igones. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol ExtensionUploadManagerDelegate <NSObject>

- (void) extensionUploadIsAtPercent:(int) percent;
- (void) extensionUploadHasFinished;
- (void) extensionUploadShouldRelogin;
- (void) extensionUploadHasFailed:(NSError *) error;

@end

@interface ExtensionUploadManager : NSObject <NSURLSessionDelegate, NSURLSessionTaskDelegate>

@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, weak) id<ExtensionUploadManagerDelegate> delegate;

+ (ExtensionUploadManager *) sharedInstance;
- (void) startUploadForImage:(UIImage *) img;
- (void) startUploadForVideoData:(NSData *) videoData;
- (void) startUploadForDoc:(NSData *) docData withContentType:(NSString *) contentType withExt:(NSString *) ext;

@end
