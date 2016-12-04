//
//  VideofyCreateDao.m
//  Depo
//
//  Created by Mahir Tarlan on 28/06/16.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import "VideofyCreateDao.h"

@implementation VideofyCreateDao

- (void) requestVideofyCreateForStory:(Story *) story {
    NSURL *url = [NSURL URLWithString:VIDEOFY_CREATE_URL];
    
    NSMutableArray *uuidList = [[NSMutableArray alloc] init];
    for(MetaFile *file in story.fileList) {
        [uuidList addObject:file.uuid];
    }
    NSMutableDictionary *info = [[NSMutableDictionary alloc] init];
    [info setObject:uuidList forKey:@"imageUUIDs"];
    [info setObject:story.title forKey:@"name"];
    if(story.musicFileUuid != nil) {
        [info setObject:story.musicFileUuid forKey:@"audioUUID"];
    } else if(story.musicFileId != nil) {
        [info setObject:story.musicFileId forKey:@"audioId"];
    }
    
    NSData *postData = [NSJSONSerialization dataWithJSONObject:info options:NSJSONWritingPrettyPrinted error:nil];

    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    
    request = [self sendPostRequest:request];
    [request setHTTPBody:[postData mutableCopy]];
    
    NSURLSessionDataTask *task = [[DepoHttpManager sharedInstance].urlSession dataTaskWithRequest:request completionHandler:[self createCompletionHandlerWithCompletion:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self requestFailed:response];
            });
        }
        else {
            if (![self checkResponseHasError:response]) {
                NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
                if(dict != nil && [dict isKindOfClass:[NSDictionary class]]) {
                    NSString *status = [dict objectForKey:@"status"];
                    if(status != nil && [status isEqualToString:@"OK"]) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self shouldReturnSuccess];
                        });
                    } else {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self shouldReturnFailWithMessage:GENERAL_ERROR_MESSAGE];
                        });
                    }
                }
                else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self shouldReturnFailWithMessage:GENERAL_ERROR_MESSAGE];
                    });
                }
            }
        }
    }]];
    self.currentTask = task;
    [task resume];
}

@end
