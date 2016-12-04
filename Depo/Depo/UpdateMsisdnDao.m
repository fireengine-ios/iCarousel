//
//  UpdateMsisdnDao.m
//  Depo
//
//  Created by Mahir Tarlan on 09/03/16.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import "UpdateMsisdnDao.h"

@implementation UpdateMsisdnDao

- (void) requestUpdateMsisdn:(NSString *)msisdnVal {
    NSURL *url = [NSURL URLWithString:MSISDN_UPDATE_URL];
    
    NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:
                          msisdnVal, @"phoneNumber",
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
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self shouldReturnSuccessWithObject:mainDict];
                });
            }
            else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self shouldReturnFailWithMessage:GENERAL_ERROR_MESSAGE];
                });
            }
        }
    }]];
    self.currentTask = task;
    [task resume];

}

//- (void)requestFinished:(ASIHTTPRequest *)request {
//    NSError *error = [request error];
//    if (!error) {
//        NSString *statusVal = @"";
//        NSString *responseStr = [request responseString];
//        
//        NSLog(@"Update Msisdn Response: %@", responseStr);
//        SBJSON *jsonParser = [SBJSON new];
//        NSDictionary *mainDict = [jsonParser objectWithString:responseStr];
//        if(mainDict != nil && ![mainDict isKindOfClass:[NSNull class]]) {
//            [self shouldReturnSuccessWithObject:mainDict];
//            return;
//        }
//    }
//    [self shouldReturnFailWithMessage:GENERAL_ERROR_MESSAGE];
//}

@end
