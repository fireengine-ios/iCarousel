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
#import "AppUtil.h"

typedef void (^ALAssetsLibraryAssetForURLResultBlock)(ALAsset *asset);
typedef void (^ALAssetsLibraryAccessFailureBlock)(NSError *error);

@implementation UploadManager

@synthesize delegate;
@synthesize asset;
@synthesize assetsLibrary;
@synthesize urlForUpload;
@synthesize folder;
@synthesize largeimage;
@synthesize uploadRef;
@synthesize hasFinished;

- (id) init {
    if(self = [super init]) {
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

    uploadTask = [session uploadTaskWithRequest:[self prepareRequest] fromFile:[NSURL fileURLWithPath:filePath] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSHTTPURLResponse *httpResp = (NSHTTPURLResponse*) response;
        if (!error && httpResp.statusCode == 201) {
            [notifyDao requestNotifyUploadForFile:self.folder ? [NSString stringWithFormat:@"%@/%@", self.folder.name, fileName] : [NSString stringWithFormat:@"/%@", fileName]];
        } else {
            [delegate uploadManagerDidFailUploadingAsData];
            hasFinished = YES;
        }
    }];
    [uploadTask resume];
}

- (void) startUploadingData:(NSData *) _dataToUpload atFolder:(MetaFile *) _folder withFileName:(NSString *) fileName {
    self.folder = _folder;
    self.urlForUpload = [NSString stringWithFormat:@"%@/%@", APPDELEGATE.session.baseUrl, fileName];
    
    uploadTask = [session uploadTaskWithRequest:[self prepareRequest] fromData:_dataToUpload completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSHTTPURLResponse *httpResp = (NSHTTPURLResponse*) response;
        if (!error && httpResp.statusCode == 201) {
            [notifyDao requestNotifyUploadForFile:self.folder ? [NSString stringWithFormat:@"%@/%@", self.folder.name, fileName] : [NSString stringWithFormat:@"/%@", fileName]];
        } else {
            [delegate uploadManagerDidFailUploadingAsData];
            hasFinished = YES;
        }
    }];
    [uploadTask resume];
}

- (void) startUploadingAsset:(NSString *) assetUrl atFolder:(MetaFile *) _folder {
    self.folder = _folder;
    self.assetsLibrary = [[ALAssetsLibrary alloc] init];
    
    [assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        if(group) {
            [group enumerateAssetsUsingBlock:^(ALAsset *_asset, NSUInteger index, BOOL *stop) {
                if(_asset && !asset) {
                    NSURL *_assetUrl = _asset.defaultRepresentation.url;
                    if([[_assetUrl absoluteString] isEqualToString:assetUrl]) {
                        self.asset = _asset;
                        [self triggerAndStartAssetsTask];
                    }
                }
            }];
        }
    } failureBlock:^(NSError *error) {
    }];
}

- (void) triggerAndStartAssetsTask {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    tempPath = [documentsDirectory stringByAppendingFormat:@"/%@", asset.defaultRepresentation.filename];
    
    UIImage *image = [UIImage imageWithCGImage:[asset.defaultRepresentation fullResolutionImage]];
    [UIImagePNGRepresentation(image) writeToFile:tempPath atomically:YES];

    self.urlForUpload = [NSString stringWithFormat:@"%@%@%@", APPDELEGATE.session.baseUrl, self.folder ? [AppUtil enrichFileFolderName:self.folder.name] : @"/", asset.defaultRepresentation.filename];
    
    uploadTask = [session uploadTaskWithRequest:[self prepareRequest] fromFile:[NSURL fileURLWithPath:tempPath] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSHTTPURLResponse *httpResp = (NSHTTPURLResponse*) response;
        if (!error && httpResp.statusCode == 201) {
            [self removeTemporaryFile];
            [notifyDao requestNotifyUploadForFile:self.folder ? [NSString stringWithFormat:@"%@%@", [AppUtil enrichFileFolderName:self.folder.name], asset.defaultRepresentation.filename] : [NSString stringWithFormat:@"/%@", asset.defaultRepresentation.filename]];
        } else {
            [self removeTemporaryFile];
            [delegate uploadManagerDidFailUploadingForAsset:self.asset];
            hasFinished = YES;
        }
    }];
    [uploadTask resume];
}

- (void) removeTemporaryFile {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:tempPath error:nil];
    [delegate uploadManagerDidFailUploadingForAsset:self.asset];
}

- (NSMutableURLRequest *) prepareRequest {
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:self.urlForUpload]];
    
    [request setHTTPMethod:@"PUT"];
    [request setValue:APPDELEGATE.session.authToken forHTTPHeaderField:@"X-Auth-Token"];
    [request setValue:@"false" forHTTPHeaderField:@"X-Object-Meta-Favourite"];
    [request setValue:@"1" forHTTPHeaderField:@"x-meta-strategy"];
    [request addValue:@"image/png" forHTTPHeaderField:@"Content-Type"];
    return request;
}

- (void) uploadNotifySuccessCallback {
    [delegate uploadManagerDidFinishUploadingForAsset:self.asset];
    hasFinished = YES;
}

- (void) uploadNotifyFailCallback:(NSString *) errorMessage {
    [delegate uploadManagerDidFailUploadingForAsset:self.asset];
    hasFinished = YES;
}

- (void) URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didSendBodyData:(int64_t)bytesSent totalBytesSent:(int64_t)totalBytesSent totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend {
    [delegate uploadManagerDidSendData:(long)totalBytesSent inTotal:(long)totalBytesExpectedToSend];
}

@end
