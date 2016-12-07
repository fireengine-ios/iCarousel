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
            if (![self checkResponseHasError:response]) {
                NSDictionary *mainDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
                if(mainDict && [mainDict isKindOfClass:[NSDictionary class]]) {
                    NSString *status = [mainDict objectForKey:@"status"];
                    if(status != nil && ![status isKindOfClass:[NSNull class]]) {
                        NSString *statusVal = [mainDict objectForKey:@"status"];
                        if(statusVal != nil && ![statusVal isKindOfClass:[NSNull class]]) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [self shouldReturnSuccessWithObject:mainDict];
                            });
                        }
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
