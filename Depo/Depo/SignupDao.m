//
//  SignupDao.m
//  Depo
//
//  Created by Mahir on 07/01/16.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import "SignupDao.h"
#import "Util.h"

@implementation SignupDao

- (void) requestTriggerSignupForEmail:(NSString *) email forPhoneNumber:(NSString *) phoneNumber withPassword:(NSString *) password withEulaId:(int) eulaId {
    NSURL *url = [NSURL URLWithString:SIGNUP_URL];
    
    NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:
                          email, @"email",
                          phoneNumber, @"phoneNumber",
                          password, @"password",
                          [NSNumber numberWithInt:eulaId], @"eulaId",
                          [Util readLocaleCode], @"language",
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
        NSLog(@"Signup Response: %@", responseStr);
        
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
