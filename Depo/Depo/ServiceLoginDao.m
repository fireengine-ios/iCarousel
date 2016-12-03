//
//  ServiceLoginDao.m
//  Acdm_1
//
//  Created by mahir tarlan on 12/30/13.
//  Copyright (c) 2013 igones. All rights reserved.
//

#import "ServiceLoginDao.h"
#import "AuthResponse.h"

@implementation ServiceLoginDao

- (id)init {
	if (self = [super init]) {
	}
	return self;
}

- (void) requestServiceLogin:(NSString *) gsmVal withPass:(NSString *) passVal shouldRememberMe:(BOOL) rememberMe {
	NSURL *url = [NSURL URLWithString:turkcellServiceLogin];
	
    NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:
                          turkcellAuthAppId, @"appId",
                          gsmVal, @"username",
                          passVal, @"password",
                          rememberMe ? @"yes" : @"no", @"rememberMe",
                          @"", @"captchaToken",
                          nil];
    
    NSData *postData = [NSJSONSerialization dataWithJSONObject:info options:NSJSONWritingPrettyPrinted error:nil];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request addValue:@"application/json; encoding=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    NSURLSessionDataTask *task = [[DepoHttpManager sharedInstance].urlSession dataTaskWithRequest:request completionHandler:[self createCompletionHandlerWithCompletion:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self requestFailed:response];
            });
        }
        else {
            if (![self checkResponseHasError:response]) {
                NSDictionary *mainDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
                
                NSNumber *code = [mainDict objectForKey:@"code"];
                NSString *message = [mainDict objectForKey:@"message"];
                NSNumber *rememberMe = [mainDict objectForKey:@"rememberMe"];
                NSNumber *showCaptcha = [mainDict objectForKey:@"showCaptcha"];
                NSString *token = [mainDict objectForKey:@"authToken"];
                
                AuthResponse *result = [[AuthResponse alloc] init];
                result.code = [code intValue];
                result.message = message;
                if(rememberMe != nil) {
                    result.rememberMe = [rememberMe boolValue];
                }
                if(showCaptcha != nil) {
                    result.showCaptcha = [showCaptcha boolValue];
                }
                if(token != nil) {
                    result.authToken = token;
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.delegate performSelector:successMethod withObject:result];
                });
            }
        }
    }]];
    self.currentTask = task;
    [task resume];
}


@end
