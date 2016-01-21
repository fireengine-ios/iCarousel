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
    
    SBJSON *json = [SBJSON new];
    NSString *jsonStr = [json stringWithObject:info];
    NSData *postData = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setPostBody:postData];
    [request setDelegate:self];
    
    [self sendPostRequest:request];
}

- (void)requestFinished:(ASIHTTPRequest *)request {
    NSError *error = [request error];
    if (!error) {
        NSString *responseStr = [request responseString];
        NSLog(@"Send Verification SMS Response: %@", responseStr);
        
        SBJSON *jsonParser = [SBJSON new];
        NSDictionary *mainDict = [jsonParser objectWithString:responseStr];
        if(mainDict != nil && ![mainDict isKindOfClass:[NSNull class]]) {
            NSString *statusVal = [mainDict objectForKey:@"status"];
            if(statusVal != nil && ![statusVal isKindOfClass:[NSNull class]]) {
                [self shouldReturnSuccessWithObject:mainDict];
                return;
            }
        }
    }
    [self shouldReturnFailWithMessage:GENERAL_ERROR_MESSAGE];
}

@end
