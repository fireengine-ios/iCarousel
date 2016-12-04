//
//  ProfilePhotoUploadDao.m
//  Depo
//
//  Created by Mahir Tarlan on 27/06/16.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import "ProfilePhotoUploadDao.h"

@implementation ProfilePhotoUploadDao

- (void) requestUploadForImage:(UIImage *) imageFile {
    NSString *urlStr = PROFILE_IMG_URL;
    NSURL *url = [NSURL URLWithString:urlStr];
    
    NSData *imageData = UIImagePNGRepresentation(imageFile);
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
    request = [self sendPutRequest:request];
    
    [request setHTTPBody:[imageData mutableCopy]];
    
    NSURLSessionDataTask *task = [[DepoHttpManager sharedInstance].urlSession dataTaskWithRequest:request completionHandler:[self createCompletionHandlerWithCompletion:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self requestFailed:response];
            });
        }
        else {
            if (![self checkResponseHasError:response]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self shouldReturnSuccess];
                });
            }
        }
    }]];
    self.currentTask = task;
    [task resume];
}

@end
