//
//  RenameAlbumDao.m
//  Depo
//
//  Created by Mahir on 13.11.2014.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "RenameAlbumDao.h"
#import "PhotoAlbum.h"

@implementation RenameAlbumDao

@synthesize nameRef;

- (void) requestRenameAlbum:(NSString *) albumUuid withNewName:(NSString *) newName {
    self.nameRef = newName;
    
    NSString *urlStr = [NSString stringWithFormat:RENAME_ALBUM_URL, albumUuid, newName];
    NSURL *url = [NSURL URLWithString:[urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
//    NSLog(@"RENAME ALBUM URL: %@", [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]);
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    request = [self sendPutRequest:request];
    NSURLSessionDataTask *task = [[DepoHttpManager sharedInstance].urlSession dataTaskWithRequest:request completionHandler:[self createCompletionHandlerWithCompletion:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self requestFailed:response];
            });
        }
        else {
            if (![self checkResponseHasError:response]) {
                [self requestFinished:data];
            }
        }
    }]];
    self.currentTask = task;
    [task resume];
}

- (void)requestFinished:(NSData *) data {
//    NSError *error = [request error];
    PhotoAlbum *finalAlbum = [[PhotoAlbum alloc] init];
    finalAlbum.label = self.nameRef;
    finalAlbum.lastModifiedDate = [NSDate date];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self shouldReturnSuccessWithObject:finalAlbum];
    });
//    
//    if (!error) {
//        NSString *responseEnc = [request responseString];
////        NSLog(@"RENAME ALBUM Response: %@", responseEnc);
//        
  
//    } else {
//        [self shouldReturnFailWithMessage:GENERAL_ERROR_MESSAGE];
//    }
    
}

@end
