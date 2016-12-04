//
//  UsageInfoDao.m
//  Depo
//
//  Created by Mahir on 08/01/15.
//  Copyright (c) 2015 com.igones. All rights reserved.
//

#import "QuotaInfoDao.h"
#import "Quota.h"

@implementation QuotaInfoDao

- (void) requestQuotaInfo {
    NSURL *url = [NSURL URLWithString:QUOTA_INFO_URL];
    
    IGLog(@"QuotaInfoDao [GET] calling requestQuotaInfo");

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
                    Quota *result = [[Quota alloc] init];

                    NSNumber *quotaBytes = [mainDict objectForKey:@"quotaBytes"];
                    NSNumber *quotaCount = [mainDict objectForKey:@"quotaCount"];
                    NSNumber *bytesUsed = [mainDict objectForKey:@"bytesUsed"];
                    NSNumber *quotaExceeded = [mainDict objectForKey:@"quotaExceeded"];
                    NSNumber *objectCount = [mainDict objectForKey:@"objectCount"];
                    
                    if(quotaBytes != nil && ![quotaBytes isKindOfClass:[NSNull class]]) {
                        result.quotaBytes = [quotaBytes longLongValue];
                    }
                    if(quotaCount != nil && ![quotaCount isKindOfClass:[NSNull class]]) {
                        result.quotaCount = [quotaCount longLongValue];
                    }
                    if(bytesUsed != nil && ![bytesUsed isKindOfClass:[NSNull class]]) {
                        result.bytesUsed = [bytesUsed longLongValue];
                    }
                    
                    if(objectCount != nil && ![objectCount isKindOfClass:[NSNull class]]) {
                        result.objectCount = [objectCount intValue];
                    }
                    if(quotaExceeded != nil && ![quotaExceeded isKindOfClass:[NSNull class]]) {
                        result.quotaExceeded = [quotaExceeded boolValue];
                    }
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self shouldReturnSuccessWithObject:result];
                    });
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

/*
- (void)requestFinished:(ASIHTTPRequest *)request {
    NSError *error = [request error];
    
    if (!error) {
        NSString *responseEnc = [request responseString];
        
        IGLog(@"QuotaInfoDao request successfully finished");
        
        //        NSLog(@"Usage Response: %@", responseEnc);
        
        SBJSON *jsonParser = [SBJSON new];
        NSDictionary *mainDict = [jsonParser objectWithString:responseEnc];
        
        Quota *result = [[Quota alloc] init];
        
        if(mainDict != nil && ![mainDict isKindOfClass:[NSNull class]]) {
            NSNumber *quotaBytes = [mainDict objectForKey:@"quotaBytes"];
            NSNumber *quotaCount = [mainDict objectForKey:@"quotaCount"];
            NSNumber *bytesUsed = [mainDict objectForKey:@"bytesUsed"];
            NSNumber *quotaExceeded = [mainDict objectForKey:@"quotaExceeded"];
            NSNumber *objectCount = [mainDict objectForKey:@"objectCount"];
            
            if(quotaBytes != nil && ![quotaBytes isKindOfClass:[NSNull class]]) {
                result.quotaBytes = [quotaBytes longLongValue];
            }
            if(quotaCount != nil && ![quotaCount isKindOfClass:[NSNull class]]) {
                result.quotaCount = [quotaCount longLongValue];
            }
            if(bytesUsed != nil && ![bytesUsed isKindOfClass:[NSNull class]]) {
                result.bytesUsed = [bytesUsed longLongValue];
            }

            if(objectCount != nil && ![objectCount isKindOfClass:[NSNull class]]) {
                result.objectCount = [objectCount intValue];
            }
            if(quotaExceeded != nil && ![quotaExceeded isKindOfClass:[NSNull class]]) {
                result.quotaExceeded = [quotaExceeded boolValue];
            }
        }
        
        [self shouldReturnSuccessWithObject:result];
    } else {
        [self shouldReturnFailWithMessage:GENERAL_ERROR_MESSAGE];
    }
    
}
*/

@end
