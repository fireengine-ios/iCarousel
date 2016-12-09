//
//  VerifyPhoneDao.m
//  Depo
//
//  Created by Mahir on 07/01/16.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import "VerifyPhoneDao.h"

@implementation VerifyPhoneDao

- (void) requestTriggerVerifyPhone:(NSString *) token withOTP:(NSString *) otp {
    NSURL *url = [NSURL URLWithString:VERIFY_PHONE_URL];
    
    NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:
                          token, @"referenceToken",
                          otp, @"otp",
                          nil];
    
    NSData *postData = [NSJSONSerialization dataWithJSONObject:info options:NSJSONWritingPrettyPrinted error:nil];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    request = [self sendPostRequest:request];
    [request setHTTPBody:postData];
    
    NSURLSessionDataTask *task = [[DepoHttpManager sharedInstance].urlSession dataTaskWithRequest:request completionHandler:[self createCompletionHandlerWithCompletion:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self requestFailed:response];
            });
        }
        else {
            NSDictionary *mainDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
            if(mainDict && [mainDict isKindOfClass:[NSDictionary class]]) {
                NSString *status = [mainDict objectForKey:@"status"];
                if(status != nil && ![status isKindOfClass:[NSNull class]]) {
                    NSString *statusVal = [mainDict objectForKey:@"status"];
                    if(statusVal != nil && ![statusVal isKindOfClass:[NSNull class]]) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self shouldReturnSuccessWithObject:statusVal];
                            return ;
                        });
                    }
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self shouldReturnSuccessWithObject:@"OK"];
                });
            }
            else {
                if (![self checkResponseHasError:response]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self shouldReturnFailWithMessage:GENERAL_ERROR_MESSAGE];
                    });
                }
                else {
                    [self requestFailed:response];
                }
            }
        }
    }]];
    self.currentTask = task;
    [task resume];
}

- (void) requestTriggerVerifyPhoneToUpdate:(NSString *) token withOTP:(NSString *) otp {
    NSURL *url = [NSURL URLWithString:VERIFY_PHONE_TO_UPDATE_URL];
    
    NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:
                          token, @"referenceToken",
                          otp, @"otp",
                          nil];
    
    NSData *postData = [NSJSONSerialization dataWithJSONObject:info options:NSJSONWritingPrettyPrinted error:nil];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    request = [self sendPostRequest:request];
    [request setHTTPBody:postData];
    
    NSURLSessionDataTask *task = [[DepoHttpManager sharedInstance].urlSession dataTaskWithRequest:request completionHandler:[self createCompletionHandlerWithCompletion:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self requestFailed:response];
            });
        }
        else {
            NSDictionary *mainDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
            if(mainDict && [mainDict isKindOfClass:[NSDictionary class]]) {
                NSString *status = [mainDict objectForKey:@"status"];
                if(status != nil && ![status isKindOfClass:[NSNull class]]) {
                    NSString *statusVal = [mainDict objectForKey:@"status"];
                    if(statusVal != nil && ![statusVal isKindOfClass:[NSNull class]]) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self shouldReturnSuccessWithObject:statusVal];
                            return ;
                        });
                    }
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self shouldReturnSuccessWithObject:@"OK"];
                    });
                }
            }
            else {
                if (![self checkResponseHasError:response]) {
                    [self requestFailed:response];
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
