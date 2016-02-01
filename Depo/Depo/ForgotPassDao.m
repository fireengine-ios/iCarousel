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
    
    NSString *postValue = [NSString stringWithFormat:@"{%@}", email];
    NSData *postData = [postValue dataUsingEncoding:NSUTF8StringEncoding];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setPostBody:postData];
    [request setDelegate:self];
    
    if(captchaId != nil && captchaValue != nil) {
        [request addRequestHeader:@"X-Captcha-Id" value:captchaId];
        [request addRequestHeader:@"X-Captcha-Answer" value:captchaValue];
    }
    
    [self sendPostRequest:request];
}

- (void)requestFinished:(ASIHTTPRequest *)request {
    NSError *error = [request error];

    if (!error) {
        NSString *responseStr = [request responseString];
        SBJSON *jsonParser = [SBJSON new];
        NSDictionary *dict = [jsonParser objectWithString:responseStr];
        if(dict != nil && [dict isKindOfClass:[NSDictionary class]]) {
            NSNumber *statusVal = [dict objectForKey:@"status"];
            if(statusVal != nil && ![statusVal isKindOfClass:[NSNull class]]) {
                if([statusVal intValue] == 4001) {
                    [self shouldReturnFailWithMessage:NSLocalizedString(@"InvalidCaptchaErrorMessage", @"")];
                    return;
                }
            }
        }
        [self shouldReturnSuccessWithObject:dict];
    } else {
        [self shouldReturnFailWithMessage:GENERAL_ERROR_MESSAGE];
    }
}

@end
