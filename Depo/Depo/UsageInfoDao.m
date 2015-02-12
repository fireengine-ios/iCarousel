//
//  UsageInfoDao.m
//  Depo
//
//  Created by Mahir on 08/01/15.
//  Copyright (c) 2015 com.igones. All rights reserved.
//

#import "UsageInfoDao.h"
#import "Usage.h"

@implementation UsageInfoDao

- (void) requestUsageInfo {
    NSURL *url = [NSURL URLWithString:USAGE_INFO_URL];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setDelegate:self];
    [self sendGetRequest:request];
}

- (void)requestFinished:(ASIHTTPRequest *)request {
    NSError *error = [request error];
    
    if (!error) {
        NSString *responseEnc = [request responseString];
        
        NSLog(@"Usage Response: %@", responseEnc);
        
        SBJSON *jsonParser = [SBJSON new];
        NSDictionary *mainDict = [jsonParser objectWithString:responseEnc];
        
        Usage *result = [[Usage alloc] init];
        
        if(mainDict != nil && ![mainDict isKindOfClass:[NSNull class]]) {
            NSString *totalStorage = [mainDict objectForKey:@"Quota-Bytes"];
            NSString *usedStorage = [mainDict objectForKey:@"Bytes-Used"];
            NSNumber *imageUsage = [mainDict objectForKey:@"imageUsage"];
            NSNumber *othersUsage = [mainDict objectForKey:@"othersUsage"];
            NSNumber *audioUsage = [mainDict objectForKey:@"audioUsage"];
            NSNumber *videoUsage = [mainDict objectForKey:@"videoUsage"];
            
            if(totalStorage != nil && ![totalStorage isKindOfClass:[NSNull class]]) {
                result.totalStorage = [totalStorage longLongValue];
            }
            if(imageUsage != nil && ![imageUsage isKindOfClass:[NSNull class]]) {
                result.imageUsage = [imageUsage longLongValue];
            }
            if(othersUsage != nil && ![othersUsage isKindOfClass:[NSNull class]]) {
                result.otherUsage = [othersUsage longLongValue];
            }
            if(audioUsage != nil && ![audioUsage isKindOfClass:[NSNull class]]) {
                result.musicUsage = [audioUsage longLongValue];
            }
            if(videoUsage != nil && ![videoUsage isKindOfClass:[NSNull class]]) {
                result.videoUsage = [videoUsage longLongValue];
            }
            if(usedStorage != nil && ![usedStorage isKindOfClass:[NSNull class]]) {
                result.usedStorage = [usedStorage longLongValue];
            }
            if(result.totalStorage > 0) {
                result.remainingStorage = result.totalStorage - result.usedStorage;
            }
        }
        
        [self shouldReturnSuccessWithObject:result];
    } else {
        [self shouldReturnFailWithMessage:GENERAL_ERROR_MESSAGE];
    }
    
}

@end
