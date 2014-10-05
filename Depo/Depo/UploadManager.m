//
//  UploadManager.m
//  Depo
//
//  Created by Mahir on 10/2/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "UploadManager.h"
#import "AppDelegate.h"
#import "AppSession.h"
#import "Util.h"

typedef void (^ALAssetsLibraryAssetForURLResultBlock)(ALAsset *asset);
typedef void (^ALAssetsLibraryAccessFailureBlock)(NSError *error);

@implementation UploadManager

@synthesize delegate;
@synthesize asset;
@synthesize assetsLibrary;
@synthesize urlForUpload;
@synthesize folder;
@synthesize largeimage;

- (id) initWithAssetsLibrary:(ALAssetsLibrary *) assetsLib {
    if(self = [super init]) {
        self.assetsLibrary = assetsLib;

        NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration  defaultSessionConfiguration];
        session = [NSURLSession sessionWithConfiguration:sessionConfig delegate:self delegateQueue:nil];

        notifyDao = [[UploadNotifyDao alloc] init];
        notifyDao.delegate = self;
        notifyDao.successMethod = @selector(uploadNotifySuccessCallback);
        notifyDao.failMethod = @selector(uploadNotifyFailCallback:);
    }
    return self;
}

- (void) startUploadingFile:(NSString *) filePath atFolder:(MetaFile *) _folder withFileName:(NSString *) fileName {
    self.folder = _folder;
    self.urlForUpload = [NSString stringWithFormat:@"%@/%@", APPDELEGATE.session.baseUrl, fileName];

    NSLog(@"File Path To Upload: %@", filePath);
    
    uploadTask = [session uploadTaskWithRequest:[self prepareRequest] fromFile:[NSURL fileURLWithPath:filePath] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSLog(@"At uploadTask completion handler");
        NSHTTPURLResponse *httpResp = (NSHTTPURLResponse*) response;
        if (!error && httpResp.statusCode == 201) {
            [notifyDao requestNotifyUploadForFile:self.folder ? [NSString stringWithFormat:@"%@/%@", self.folder.name, fileName] : [NSString stringWithFormat:@"/%@", fileName]];
        } else {
            NSLog(@"uploadTask completion handler failed, status:%d", httpResp.statusCode);
            [delegate uploadManagerDidFailUploadingAsData];
        }
    }];
    [uploadTask resume];
}

- (void) startUploadingData:(NSData *) _dataToUpload atFolder:(MetaFile *) _folder withFileName:(NSString *) fileName {
    self.folder = _folder;
    self.urlForUpload = [NSString stringWithFormat:@"%@/%@", APPDELEGATE.session.baseUrl, fileName];
    
    uploadTask = [session uploadTaskWithRequest:[self prepareRequest] fromData:_dataToUpload completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSLog(@"At uploadTask completion handler");
        NSHTTPURLResponse *httpResp = (NSHTTPURLResponse*) response;
        if (!error && httpResp.statusCode == 201) {
            [notifyDao requestNotifyUploadForFile:self.folder ? [NSString stringWithFormat:@"%@/%@", self.folder.name, fileName] : [NSString stringWithFormat:@"/%@", fileName]];
        } else {
            NSLog(@"uploadTask completion handler failed, status:%d", httpResp.statusCode);
            [delegate uploadManagerDidFailUploadingAsData];
        }
    }];
    [uploadTask resume];
}

- (void) startUploadingAsset:(ALAsset *) _asset atFolder:(MetaFile *) _folder {
    self.folder = _folder;
    self.asset = _asset;
    self.urlForUpload = [NSString stringWithFormat:@"%@/%@", APPDELEGATE.session.baseUrl, asset.defaultRepresentation.filename];
    
    [self findLargeImage];
    /*
    [uploadTask addObserver:self forKeyPath:@"countOfBytesSent" options:NSKeyValueObservingOptionNew task:^(id obj, NSDictionary *change) {
        NSURLSessionUploadTask *observedTask = obj;
        CGFloat fractionCompleted = roundf(100*((CGFloat)observedTask.countOfBytesSent)/((CGFloat)imageData.length))/100.0f;
        NSLog(@"fractionCompleted: %.2f", fractionCompleted);
    }];
     */
    
}

- (void) triggerAndStartTask {
    uploadTask = [session uploadTaskWithRequest:[self prepareRequest] fromFile:asset.defaultRepresentation.url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSLog(@"At uploadTask completion handler for: %@", asset.defaultRepresentation.url);
        NSHTTPURLResponse *httpResp = (NSHTTPURLResponse*) response;
        if (!error && httpResp.statusCode == 201) {
            [notifyDao requestNotifyUploadForFile:self.folder ? [NSString stringWithFormat:@"%@/%@", self.folder.name, asset.defaultRepresentation.filename] : [NSString stringWithFormat:@"/%@", asset.defaultRepresentation.filename]];
        } else {
            NSLog(@"uploadTask completion handler failed, status:%d", httpResp.statusCode);
            [delegate uploadManagerDidFailUploadingForAsset:self.asset];
        }
    }];
    [uploadTask resume];
}

- (NSMutableURLRequest *) prepareRequest {
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:self.urlForUpload]];
    NSLog(@"UPLOAD URL: %@", self.urlForUpload);
    
    [request setHTTPMethod:@"PUT"];
    [request setValue:APPDELEGATE.session.authToken forHTTPHeaderField:@"X-Auth-Token"];
    [request setValue:@"false" forHTTPHeaderField:@"X-Object-Meta-Favourite"];
    [request setValue:@"1" forHTTPHeaderField:@"x-meta-strategy"];
    return request;
}

- (void) uploadNotifySuccessCallback {
    [delegate uploadManagerDidFinishUploadingForAsset:self.asset];
}

- (void) uploadNotifyFailCallback:(NSString *) errorMessage {
    [delegate uploadManagerDidFailUploadingForAsset:self.asset];
}

- (void) findLargeImage {
    ALAssetsLibraryAssetForURLResultBlock resultblock = ^(ALAsset *myasset) {
        ALAssetRepresentation *rep = [myasset defaultRepresentation];
        CGImageRef iref = [rep fullResolutionImage];
        if (iref) {
            largeimage = [UIImage imageWithCGImage:iref];
            [self triggerAndStartTask];
        }
    };
    
    ALAssetsLibraryAccessFailureBlock failureblock  = ^(NSError *myerror) {
        NSLog(@"cant get image - %@",[myerror localizedDescription]);
    };
    
    NSURL *asseturl = self.asset.defaultRepresentation.url;
    [assetsLibrary assetForURL:asseturl resultBlock:resultblock failureBlock:failureblock];
}

- (void) URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didSendBodyData:(int64_t)bytesSent totalBytesSent:(int64_t)totalBytesSent totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend {
    NSLog(@"upload manager didSendBodyData:%d", (int)totalBytesSent);
}

@end
