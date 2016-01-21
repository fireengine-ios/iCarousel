//
//  SendVerificationEmailDao.m
//  Depo
//
//  Created by Mahir on 07/01/16.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import "SendVerificationEmailDao.h"

@implementation SendVerificationEmailDao

- (void) requestTriggerSendVerificationEmail:(NSString *)email {
    NSURL *url = [NSURL URLWithString:SEND_VERIFICATION_EMAIL_URL];
    
    NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:
                          email, @"email",
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
        NSLog(@"Send Verification Email Response: %@", responseStr);
        
        SBJSON *jsonParser = [SBJSON new];
        NSDictionary *mainDict = [jsonParser objectWithString:responseStr];
        if(mainDict != nil && ![mainDict isKindOfClass:[NSNull class]]) {
            NSString *statusVal = [mainDict objectForKey:@"status"];
            if(statusVal != nil && ![statusVal isKindOfClass:[NSNull class]]) {
                [self shouldReturnSuccessWithObject:statusVal];
                return;
            }
        }
    }
    [self shouldReturnFailWithMessage:GENERAL_ERROR_MESSAGE];
}

@end
