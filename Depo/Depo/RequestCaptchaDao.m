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
                if(data != nil && ![data isKindOfClass:[NSNull class]]) {
                    UIImage *img = [UIImage imageWithData:data];
                    if(img) {
                        [self shouldReturnSuccessWithObject:img];
                    }
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
    self.currentTask = task;
    [task resume];
}

@end
