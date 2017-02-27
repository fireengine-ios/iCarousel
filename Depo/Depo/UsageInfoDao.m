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
    
    IGLog(@"UsageInfoDao [GET] calling requestUsageInfo");
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
                NSLog(@"USAGE INFO RESPONSE = %@",mainDict);
                Usage *result = [[Usage alloc] init];
                
                if(mainDict != nil && ![mainDict isKindOfClass:[NSNull class]]) {
                    
                    NSDictionary *storageUsage = [mainDict objectForKey:@"storageUsage"];
                    
                    NSString *totalStorage = [storageUsage objectForKey:@"Quota-Bytes"];
                    NSString *usedStorage = [storageUsage objectForKey:@"Bytes-Used"];
                    NSNumber *imageUsage = [storageUsage objectForKey:@"imageUsage"];
                    NSNumber *othersUsage = [storageUsage objectForKey:@"othersUsage"];
                    NSNumber *audioUsage = [storageUsage objectForKey:@"audioUsage"];
                    NSNumber *videoUsage = [storageUsage objectForKey:@"videoUsage"];
                    
                    NSNumber *totalFileCount = [storageUsage objectForKey:@"totalFileCount"];
                    NSNumber *folderCount = [storageUsage objectForKey:@"folderCount"];
                    NSNumber *imageCount = [storageUsage objectForKey:@"imageCount"];
                    NSNumber *videoCount = [storageUsage objectForKey:@"videoCount"];
                    NSNumber *audioCount = [storageUsage objectForKey:@"audioCount"];
                    NSNumber *othersCount = [storageUsage objectForKey:@"othersCount"];
                    
                    
                    NSMutableArray *internetDataArray = [mainDict objectForKey:@"internetDataUsage"];
                    NSDictionary *internetDataDict = internetDataArray[0];
                    
                    if (internetDataDict != nil && ![internetDataDict isKindOfClass:[NSNull class]]) {
                        
                        InternetDataUsage *internetDataUsage = [[InternetDataUsage alloc] init];
                        
                        NSNumber *expiryDate = [internetDataDict objectForKey:@"expiryDate"];
                        NSString *offerName = [internetDataDict objectForKey:@"offerName"];
                        NSNumber *remaining = [internetDataDict objectForKey:@"remaining"];
                        NSNumber *total = [internetDataDict objectForKey:@"total"];
                        NSString *unit = [internetDataDict objectForKey:@"unit"];
                        
                        if (expiryDate != nil && ![expiryDate isKindOfClass:[NSNull class]]) {
                            internetDataUsage.expiryDate = [expiryDate longLongValue];
                        }
                        if (offerName != nil && ![offerName isKindOfClass:[NSNull class]]) {
                            internetDataUsage.offerName = offerName;
                        }
                        if (remaining != nil && ![remaining isKindOfClass:[NSNull class]]) {
                            internetDataUsage.remaining = [remaining intValue];
                        }
                        if (total != nil && ![total isKindOfClass:[NSNull class]]) {
                            internetDataUsage.total = [total intValue];
                        }
                        if (unit != nil && ![unit isKindOfClass:[NSNull class]]) {
                            internetDataUsage.unit = unit;
                        }
                        
                        result.internetDataUsage = internetDataUsage;
                    }
                    
                    
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
                    
                    if(totalFileCount != nil && ![totalFileCount isKindOfClass:[NSNull class]]) {
                        result.totalFileCount = [totalFileCount intValue];
                    }
                    if(folderCount != nil && ![folderCount isKindOfClass:[NSNull class]]) {
                        result.folderCount = [folderCount intValue];
                    }
                    if(imageCount != nil && ![imageCount isKindOfClass:[NSNull class]]) {
                        result.imageCount = [imageCount intValue];
                    }
                    if(videoCount != nil && ![videoCount isKindOfClass:[NSNull class]]) {
                        result.videoCount = [videoCount intValue];
                    }
                    if(audioCount != nil && ![audioCount isKindOfClass:[NSNull class]]) {
                        result.audioCount = [audioCount intValue];
                    }
                    if(othersCount != nil && ![othersCount isKindOfClass:[NSNull class]]) {
                        result.othersCount = [othersCount intValue];
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
            else {
                [self requestFailed:response];
            }
        }
    }]];
    [task resume];
    self.currentTask = task;
}

@end
