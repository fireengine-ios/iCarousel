//
//  CoverPhotoDao.m
//  Depo
//
//  Created by RDC Partner on 19/12/2016.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import "CoverPhotoDao.h"
#import "PhotoAlbum.h"

@implementation CoverPhotoDao

- (void) requestSetCoverPhoto:(NSString *)albumUuid coverPhoto:(NSString *)coverPhotoUuid {
    NSString *coverPhotoUrl = [NSString stringWithFormat:ALBUM_SET_COVER_PHOTO_URL, albumUuid, coverPhotoUuid];
    NSURL *url = [NSURL URLWithString:coverPhotoUrl];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    request = [self sendPutRequest:request];
    
    NSURLSessionDataTask *task = [[DepoHttpManager sharedInstance].urlSession dataTaskWithRequest:request completionHandler:[self createCompletionHandlerWithCompletion:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self requestFailed:response];
            });
        }
        else {
            NSLog(@"Change Cover Photo Response = %@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
            if (![self checkResponseHasError:response]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self shouldReturnSuccess];
                });
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
