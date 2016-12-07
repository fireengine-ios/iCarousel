//
//  RequestBaseUrlDao.m
//  Depo
//
//  Created by Mahir on 9/22/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "RequestBaseUrlDao.h"
#import "AppDelegate.h"
#import "AppSession.h"
#import "AppUtil.h"
#import "SyncUtil.h"
#import "SharedUtil.h"

@implementation RequestBaseUrlDao

- (void) requestBaseUrl {
	NSURL *url = [NSURL URLWithString:USER_BASE_URL];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    NSURLRequest *finalRequest =  [self sendGetRequest:request];
    NSURLSessionDataTask *task = [[DepoHttpManager sharedInstance].urlSession dataTaskWithRequest:finalRequest completionHandler:[self createCompletionHandlerWithCompletion:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (!error) {
            if ([self checkResponseHasError:response]) {
                [self requestFailed:response];
            }
            else {
                NSDictionary *mainDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                if(mainDict != nil && ![mainDict isKindOfClass:[NSNull class]]) {
                    NSString *baseUrlValue = [mainDict objectForKey:@"value"];
                    APPDELEGATE.session.baseUrl = [self strByRawVal:baseUrlValue];
                    APPDELEGATE.session.baseUrlConstant = [AppUtil userUniqueValueByBaseUrl:[self strByRawVal:baseUrlValue]];
                    [SharedUtil writeSharedBaseUrl:APPDELEGATE.session.baseUrl];
                    [SyncUtil writeBaseUrlConstant:APPDELEGATE.session.baseUrlConstant];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self shouldReturnSuccess];
                    });
                }
                else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self shouldReturnFailWithMessage:GENERAL_ERROR_MESSAGE];
                    });
                }
            }
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self requestFailed:response];
            });
        }
    }]];
    [task resume];
    self.currentTask = task;
}

@end
