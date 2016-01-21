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
        NSLog(@"Verify Phone Response: %@", responseStr);
        
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

/*
- (void)requestFailed:(ASIHTTPRequest *)request {
    NSString *responseStr = [request responseString];
    NSLog(@"Verify Phone Error Response: %@", responseStr);

    if([request responseStatusCode] == 412) {
        //TODO
    } else if([request responseStatusCode] == 403) {
        [self shouldReturnFailWithMessage:FORBIDDEN_ERROR_MESSAGE];
    } else {
        if([request.error code] == ASIConnectionFailureErrorType){
            [self shouldReturnFailWithMessage:NSLocalizedString(@"NoConnErrorMessage", @"")];
        } else {
            [self shouldReturnFailWithMessage:GENERAL_ERROR_MESSAGE];
        }
    }
}
*/

@end
