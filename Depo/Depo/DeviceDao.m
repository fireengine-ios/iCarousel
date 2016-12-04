//
//  DeviceDao.m
//  Depo
//
//  Created by Salih Topcu on 12.01.2015.
//  Copyright (c) 2015 com.igones. All rights reserved.
//

#import "DeviceDao.h"
#import "AppUtil.h"

@implementation DeviceDao

- (void) requestConnectedDevices {
    NSURL *url = [NSURL URLWithString:GET_CONNECTED_DEVICES];
    NSURLSessionDataTask *task = [[DepoHttpManager sharedInstance].urlSession dataTaskWithRequest:[self sendGetRequest:[NSMutableURLRequest requestWithURL:url]] completionHandler:[self createCompletionHandlerWithCompletion:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self requestFailed:response];
            });
        } else {
            NSArray *mainArray = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            NSMutableArray *result = [[NSMutableArray alloc] init];
            if(mainArray != nil && ![mainArray isKindOfClass:[NSNull class]]) {
                for(NSDictionary *dict in mainArray) {
                    Device *device = [self parseDevice:dict];
                    if (device != nil) {
                        [result addObject:device];
                    }
                    
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (![self checkResponseHasError:response]) {
                        [self shouldReturnSuccessWithObject:result];
                    }
                });
            }
            else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self shouldReturnFailWithMessage:GENERAL_ERROR_MESSAGE];
                });
            }
        }
    }]];
    self.currentTask = task;
    [task resume];
}

@end
