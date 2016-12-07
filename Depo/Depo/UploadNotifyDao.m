//
//  UploadNotifyDao.m
//  Depo
//
//  Created by Mahir on 10/2/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "UploadNotifyDao.h"

@implementation UploadNotifyDao

- (void) requestNotifyUploadForFile:(NSString *) fileUuid atParentFolder:(NSString *) parentUuid {
    [self requestNotifyUploadForFile:fileUuid atParentFolder:parentUuid withReferenceAlbumName:nil];
}

- (void) requestNotifyUploadForFile:(NSString *) fileUuid atParentFolder:(NSString *) parentUuid withReferenceAlbumName:(NSString *) refAlbumName {
    
    NSString *urlStr = [NSString stringWithFormat:UPLOAD_NOTIFY_URL, parentUuid, fileUuid];
	NSURL *url = [NSURL URLWithString:urlStr];

    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    request = [self sendGetRequest:request];
    
    NSURLSessionDataTask *task = [[DepoHttpManager sharedInstance].urlSession dataTaskWithRequest:request completionHandler:[self createCompletionHandlerWithCompletion:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self requestFailed:response];
            });
        }
        else {
            if (![self checkResponseHasError:response]) {
                NSDictionary *mainDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
                if (mainDict) {
                    MetaFile *finalFile = [self parseFile:mainDict];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self shouldReturnSuccessWithObject:finalFile];
                    });
                }
                else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self shouldReturnFailWithMessage:GENERAL_ERROR_MESSAGE];
                    });
                }
            }
            else {
                [self requestFailed:response];
            }
        }
    }]];
    self.currentTask = task;
    [task resume];
}



@end
