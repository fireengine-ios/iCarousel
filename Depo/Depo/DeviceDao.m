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
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setDelegate:self];
    [self sendGetRequest:request];
}

- (void)requestFinished:(ASIHTTPRequest *)request {
    NSError *error = [request error];
    
    if (!error) {
        NSMutableArray *result = [[NSMutableArray alloc] init];
        NSString *responseStr = [request responseString];
        SBJSON *jsonParser = [SBJSON new];
        NSArray *mainArray = [jsonParser objectWithString:responseStr];
        if (mainArray != nil && ![mainArray isKindOfClass:[NSNull class]]) {
            for (NSDictionary *deviceDict in mainArray) {
                Device *device = [self parseDevice:deviceDict];
                if (device != nil)
                    [result addObject:device];
            }
            [self shouldReturnSuccessWithObject:result];
        } else
            [self shouldReturnFailWithMessage:GENERAL_ERROR_MESSAGE];
    } else
        [self shouldReturnFailWithMessage:GENERAL_ERROR_MESSAGE];
}

@end
