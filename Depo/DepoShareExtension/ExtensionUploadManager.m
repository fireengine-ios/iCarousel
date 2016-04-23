//
//  ExtensionUploadManager.m
//  Depo
//
//  Created by Mahir on 17/07/15.
//  Copyright (c) 2015 com.igones. All rights reserved.
//

#import "ExtensionUploadManager.h"
#import "Util.h"
#import <CommonCrypto/CommonDigest.h>
#import "SharedUtil.h"
#import "ExifContainer.h"
#import "UIImage+Exif.h"

@implementation ExtensionUploadManager

@synthesize session;
@synthesize delegate;

+ (ExtensionUploadManager *) sharedInstance {
    static ExtensionUploadManager *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[ExtensionUploadManager alloc] init];
        
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        configuration.HTTPMaximumConnectionsPerHost = 1;
        /*
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
            configuration = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"com.igones.akillidepo.ext.BackgroundUploadSession"];
        } else {
            configuration = [NSURLSessionConfiguration backgroundSessionConfiguration:@"com.igones.akillidepo.ext.BackgroundUploadSession"];
        }
         */
        
//        configuration.sessionSendsLaunchEvents = YES;
        sharedInstance.session = [NSURLSession sessionWithConfiguration:configuration delegate:sharedInstance delegateQueue:nil];
    });
    
    return sharedInstance;
}

- (void) startUploadForVideoData:(NSData *) videoData {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSString *randomVal = [NSString stringWithFormat:@"%.0f%d", [[NSDate date] timeIntervalSince1970], arc4random_uniform(99)];
    NSString *tempVideoName = [NSString stringWithFormat:@"/%@_EXT.mpeg", randomVal];
    NSString *tempPath = [documentsDirectory stringByAppendingString:tempVideoName];
    
    BOOL shouldContinueUpload = YES;
    @autoreleasepool {
        shouldContinueUpload = [videoData writeToFile:tempPath atomically:YES];
    }

    NSString *newUuid = [[NSUUID UUID] UUIDString];
    NSString *urlForUpload = [NSString stringWithFormat:@"%@/%@", [SharedUtil readSharedBaseUrl], newUuid];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlForUpload]];
    
    [request setTimeoutInterval:1200.0f];
    [request setHTTPMethod:@"PUT"];
    [request setValue:[SharedUtil readSharedToken] forHTTPHeaderField:@"X-Auth-Token"];
    [request setValue:@"false" forHTTPHeaderField:@"X-Object-Meta-Favourite"];
    [request setValue:[Util getWorkaroundUUID] forHTTPHeaderField:@"X-Object-Meta-Device-UUID"];
    [request setValue:@"1" forHTTPHeaderField:@"x-meta-strategy"];
    [request setValue:@"100-continue" forHTTPHeaderField:@"Expect"];
    [request setValue:@"" forHTTPHeaderField:@"X-Object-Meta-Parent-Uuid"];
    [request setValue:tempVideoName forHTTPHeaderField:@"X-Object-Meta-File-Name"];
    [request addValue:@"video/mp4" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"MOBILE_UPLOAD" forHTTPHeaderField:@"X-Object-Meta-Special-Folder"];
    
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[videoData length]];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];

    NSURLSessionUploadTask *uploadTask = [[ExtensionUploadManager sharedInstance].session uploadTaskWithRequest:request fromFile:[NSURL fileURLWithPath:tempPath]];
    uploadTask.taskDescription = tempPath;
    [uploadTask resume];
}

- (void) startUploadForDoc:(NSData *) docData withContentType:(NSString *) contentType withExt:(NSString *) ext {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSString *randomVal = [NSString stringWithFormat:@"%.0f%d", [[NSDate date] timeIntervalSince1970], arc4random_uniform(99)];
    NSString *tempName = [NSString stringWithFormat:@"/%@_EXT.%@", randomVal, ext];
    NSString *tempPath = [documentsDirectory stringByAppendingString:tempName];
    
    BOOL shouldContinueUpload = YES;
    @autoreleasepool {
        shouldContinueUpload = [docData writeToFile:tempPath atomically:YES];
    }
    
    NSString *newUuid = [[NSUUID UUID] UUIDString];
    NSString *urlForUpload = [NSString stringWithFormat:@"%@/%@", [SharedUtil readSharedBaseUrl], newUuid];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlForUpload]];
    
    [request setTimeoutInterval:1200.0f];
    [request setHTTPMethod:@"PUT"];
    [request setValue:[SharedUtil readSharedToken] forHTTPHeaderField:@"X-Auth-Token"];
    [request setValue:@"false" forHTTPHeaderField:@"X-Object-Meta-Favourite"];
    [request setValue:[Util getWorkaroundUUID] forHTTPHeaderField:@"X-Object-Meta-Device-UUID"];
    [request setValue:@"1" forHTTPHeaderField:@"x-meta-strategy"];
    [request setValue:@"100-continue" forHTTPHeaderField:@"Expect"];
    [request setValue:@"" forHTTPHeaderField:@"X-Object-Meta-Parent-Uuid"];
    [request setValue:tempName forHTTPHeaderField:@"X-Object-Meta-File-Name"];
    [request addValue:contentType forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"MOBILE_UPLOAD" forHTTPHeaderField:@"X-Object-Meta-Special-Folder"];
    
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[docData length]];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    
    NSURLSessionUploadTask *uploadTask = [[ExtensionUploadManager sharedInstance].session uploadTaskWithRequest:request fromFile:[NSURL fileURLWithPath:tempPath]];
    uploadTask.taskDescription = tempPath;
    [uploadTask resume];
}

- (void) startUploadForImage:(UIImage *) img {
    ExifContainer *container = [[ExifContainer alloc] init];
    [container addCreationDate:[NSDate date]];
    
    NSData *data = [img addExif:container];

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSString *randomVal = [NSString stringWithFormat:@"%.0f%d", [[NSDate date] timeIntervalSince1970], arc4random_uniform(99)];
    NSString *tempImgName = [NSString stringWithFormat:@"/%@_EXT.jpeg", randomVal];
    NSString *tempPath = [documentsDirectory stringByAppendingString:tempImgName];
    
    BOOL shouldContinueUpload = YES;
    @autoreleasepool {
        shouldContinueUpload = [data writeToFile:tempPath atomically:YES];
    }
    
    if(shouldContinueUpload) {
        NSString *newUuid = [[NSUUID UUID] UUIDString];
        NSString *urlForUpload = [NSString stringWithFormat:@"%@/%@", [SharedUtil readSharedBaseUrl], newUuid];
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlForUpload]];
        
        [request setTimeoutInterval:1200.0f];
        [request setHTTPMethod:@"PUT"];
        [request setValue:[SharedUtil readSharedToken] forHTTPHeaderField:@"X-Auth-Token"];
        [request setValue:@"false" forHTTPHeaderField:@"X-Object-Meta-Favourite"];
        [request setValue:[Util getWorkaroundUUID] forHTTPHeaderField:@"X-Object-Meta-Device-UUID"];
        [request setValue:@"1" forHTTPHeaderField:@"x-meta-strategy"];
        [request setValue:@"100-continue" forHTTPHeaderField:@"Expect"];
        [request setValue:@"" forHTTPHeaderField:@"X-Object-Meta-Parent-Uuid"];
        [request setValue:tempImgName forHTTPHeaderField:@"X-Object-Meta-File-Name"];
        [request addValue:@"image/jpeg" forHTTPHeaderField:@"Content-Type"];
        [request setValue:@"MOBILE_UPLOAD" forHTTPHeaderField:@"X-Object-Meta-Special-Folder"];
        
        NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[data length]];
        [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
        
        NSURLSessionUploadTask *uploadTask = [[ExtensionUploadManager sharedInstance].session uploadTaskWithRequest:request fromFile:[NSURL fileURLWithPath:tempPath]];
        uploadTask.taskDescription = tempPath;
        [uploadTask resume];
    }
}

- (NSString *) md5String:(NSData *) data {
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5([data bytes], [data length], result);
    NSString *imageHash = [NSString stringWithFormat:
                           @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
                           result[0], result[1], result[2], result[3],
                           result[4], result[5], result[6], result[7],
                           result[8], result[9], result[10], result[11],
                           result[12], result[13], result[14], result[15]
                           ];
    return imageHash;
}

- (void) URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    NSLog(@"Task completed: %@", error);
    if(task.taskDescription) {
        @try {
            NSFileManager *fileManager = [NSFileManager defaultManager];
            [fileManager removeItemAtPath:task.description error:nil];
        }
        @catch (NSException *exception) {
        }
        @finally {
        }
    }

    NSHTTPURLResponse *httpResp = (NSHTTPURLResponse*) task.response;
    int statusCode = (int) httpResp.statusCode;
    
    if(error) {
        [delegate extensionUploadHasFailed:error];
    } else {
        if(statusCode == 201) {
            [delegate extensionUploadHasFinished];
        } else if(statusCode == 401 || statusCode == 403) {
            [delegate extensionUploadShouldRelogin];
        }
    }
}

- (void) URLSession:(NSURLSession *)session didBecomeInvalidWithError:(NSError *)error {
    NSLog(@"didBecomeInvalidWithError");
}

- (void) URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task needNewBodyStream:(void (^)(NSInputStream *))completionHandler {
    NSLog(@"needNewBodyStream");
}

- (void) URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task willPerformHTTPRedirection:(NSHTTPURLResponse *)response newRequest:(NSURLRequest *)request completionHandler:(void (^)(NSURLRequest *))completionHandler {
    NSLog(@"willPerformHTTPRedirection");
}

- (void) URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *) _session {
    NSLog(@"URLSessionDidFinishEventsForBackgroundURLSession");
}

- (void) URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didSendBodyData:(int64_t)bytesSent totalBytesSent:(int64_t)totalBytesSent totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend {
    int progressPercentage = (int) totalBytesSent*100/totalBytesExpectedToSend;
    [delegate extensionUploadIsAtPercent:progressPercentage];

}

@end
