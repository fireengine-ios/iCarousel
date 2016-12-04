//
//  IAPValidateDao.m
//  Depo
//
//  Created by Mahir on 20/12/15.
//  Copyright © 2015 com.igones. All rights reserved.
//

#import "IAPValidateDao.h"
#import "AppConstants.h"

@interface IAPValidateDao () {
    NSDictionary *info;
}
@end

@implementation IAPValidateDao

- (void) requestIAPValidationWithReceiptId:(NSString *) receiptId {
    NSURL *url = [NSURL URLWithString:IAP_VALIDATE_URL];

    info = [NSDictionary dictionaryWithObjectsAndKeys:
                          receiptId, @"receiptId",
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
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self shouldReturnSuccessWithObject:status];
                        });
                    }
                }
                else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self shouldReturnFailWithMessage:GENERAL_ERROR_MESSAGE];
                    });
                }
            }
        }
    }]];
    self.currentTask = task;
    [task resume];
    
}

- (void) requestIAPValidationForProductId:(NSString *) productId withReceiptId:(NSString *) receiptId {
    NSURL *url = [NSURL URLWithString:IAP_VALIDATE_URL];
    
    info = [NSDictionary dictionaryWithObjectsAndKeys:
            receiptId, @"receiptId",
            productId, @"productId",
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
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self shouldReturnSuccessWithObject:status];
                        });
                    }
                }
                else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self shouldReturnFailWithMessage:GENERAL_ERROR_MESSAGE];
                    });
                }
            }
        }
    }]];
    self.currentTask = task;
    [task resume];
}

@end
