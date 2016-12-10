//
//  ForgotPassDao.m
//  Depo
//
//  Created by Mahir on 19/01/16.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import "ForgotPassDao.h"

@implementation ForgotPassDao

- (void) requestNotifyForgotPassWithEmail:(NSString *) email withCaptchaId:(NSString *) captchaId withCaptchaValue:(NSString *) captchaValue {
    NSURL *url = [NSURL URLWithString:FORGOT_PASS_URL];
    
    NSString *postValue = [NSString stringWithFormat:@"%@", email];
 
    NSData *postData = [postValue dataUsingEncoding:NSUTF8StringEncoding];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    if(captchaId != nil && captchaValue != nil) {
        [request addValue:captchaId forHTTPHeaderField:@"X-Captcha-Id"];
        [request addValue:captchaValue forHTTPHeaderField:@"X-Captcha-Answer"];
    }

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
                NSNumber *statusVal = [mainDict objectForKey:@"status"];
                if(statusVal != nil && ![statusVal isKindOfClass:[NSNull class]]) {
                    if([statusVal intValue] == 4001) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self shouldReturnFailWithMessage:NSLocalizedString(@"InvalidCaptchaErrorMessage", @"")];
                            return ;
                        });
                    }
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self shouldReturnSuccessWithObject:mainDict];
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

@end
