//
//  SendVerificationSMSDao.m
//  Depo
//
//  Created by Mahir on 20/01/16.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import "SendVerificationSMSDao.h"

@implementation SendVerificationSMSDao

- (void) requestTriggerSendVerificationSMS:(NSString *)token {
    NSURL *url = [NSURL URLWithString:SEND_VERIFICATION_SMS_URL];
    
    NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:
                          token, @"referenceToken",
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
                
                NSNumber *statusVal = [mainDict objectForKey:@"status"];
                if(statusVal != nil && ![statusVal isKindOfClass:[NSNull class]]) {
                    NSString *statusVal = [mainDict objectForKey:@"status"];
                    if(statusVal != nil && ![statusVal isKindOfClass:[NSNull class]]) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self shouldReturnFailWithMessage:NSLocalizedString(@"InvalidCaptchaErrorMessage", @"")];
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
            }
        }
    }]];
    self.currentTask = task;
    [task resume];
}

@end
