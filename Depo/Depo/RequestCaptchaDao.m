//
//  RequestCaptchaDao.m
//  Depo
//
//  Created by Mahir on 19/01/16.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import "RequestCaptchaDao.h"

@implementation RequestCaptchaDao

- (void) requestCaptchaForType:(NSString *) type andId:(NSString *) captchaId {
    NSString *captchaUrlStr = [NSString stringWithFormat:REQ_CAPTCHA_URL, type, captchaId];
    NSURL *url = [NSURL URLWithString:captchaUrlStr];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setDelegate:self];
    
    [self sendGetRequest:request];
}

- (void)requestFinished:(ASIHTTPRequest *)request {
    NSError *error = [request error];
    
    if (!error) {
        NSData *responseData = [request responseData];
        if(responseData != nil && ![responseData isKindOfClass:[NSNull class]]) {
            UIImage *img = [UIImage imageWithData:responseData];
            if(img) {
                [self shouldReturnSuccessWithObject:img];
                return;
            }
        }
    }
    [self shouldReturnFailWithMessage:GENERAL_ERROR_MESSAGE];
}

@end
