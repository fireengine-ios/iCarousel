//
//  FBPermissionDao.m
//  Depo
//
//  Created by Mahir Tarlan on 08/07/16.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import "FBPermissionDao.h"

@implementation FBPermissionDao

- (void) requestFbPermissionTypes {
    NSURL *url = [NSURL URLWithString:FB_PERMISSIONS_URL];
    
    IGLog(@"[GET] FBPermissionDao requestFbPermissionTypes called");
    
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
                NSDictionary *mainDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
                if(mainDict != nil && [mainDict isKindOfClass:[NSDictionary class]]) {
                    NSArray *readArr = [mainDict objectForKey:@"read"];
                    NSArray *publishArr = [mainDict objectForKey:@"write"];
                    if(readArr != nil && ![readArr isKindOfClass:[NSNull class]]
                       && publishArr != nil  && ![publishArr isKindOfClass:[NSNull class]]) {
                        IGLog(@"FBPermissionDao request finished successfully");
                        NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
                        [result setObject:readArr forKey:@"read"];
                        [result setObject:publishArr forKey:@"publish"];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self shouldReturnSuccessWithObject:result];
                        });
                    }
                } else if(mainDict != nil && [mainDict isKindOfClass:[NSArray class]]) {
                    //dict beklerken array gelme durumu oldugundan bu sekilde gelistirme eklendi
                    NSArray *mainArr = (NSArray *) mainDict;
                    IGLog(@"FBPermissionDao request finished successfully");
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self shouldReturnSuccessWithObject:mainArr];
                    });
                }
                else {
                    IGLog(@"FBPermissionDao request failed with general error message");
                    
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
