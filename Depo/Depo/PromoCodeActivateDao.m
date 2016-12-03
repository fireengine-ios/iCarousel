//
//  PromoCodeActivateDao.m
//  Depo
//
//  Created by Mahir Tarlan on 28/06/16.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import "PromoCodeActivateDao.h"

@implementation PromoCodeActivateDao

- (void) requestActivateCode:(NSString *) promoCode {
    NSURL *url = [NSURL URLWithString:PROMO_ACTIVATE_URL];
    
    NSData *postData = [NSJSONSerialization dataWithJSONObject:promoCode options:NSJSONWritingPrettyPrinted error:nil];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    
    request = [self sendPostRequest:request];
    [request setHTTPBody:[postData mutableCopy]];
    
    NSURLSessionDataTask *task = [[DepoHttpManager sharedInstance].urlSession dataTaskWithRequest:request completionHandler:[self createCompletionHandlerWithCompletion:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self requestFailed:response];
            });
        }
        else {
            if (![self checkResponseHasError:response]) {
                NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
                if(dict != nil && [dict isKindOfClass:[NSDictionary class]]) {
                    NSString *status = [dict objectForKey:@"status"];
                    if(status != nil && [status isEqualToString:@"OK"]) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self shouldReturnSuccess];
                        });
                    } else {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self shouldReturnFailWithMessage:NSLocalizedString(@"PromoError", @"")];
                        });
                    }
                }
                else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self shouldReturnFailWithMessage:NSLocalizedString(@"PromoError", @"")];
                    });
                }
            }
        }
    }]];
    self.currentTask = task;
    [task resume];
}

@end
