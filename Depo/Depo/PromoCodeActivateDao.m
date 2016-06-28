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
    
    NSData *postData = [promoCode dataUsingEncoding:NSUTF8StringEncoding];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setPostBody:postData];
    [request setDelegate:self];
    
    [self sendPostRequest:request];
}

- (void)requestFinished:(ASIHTTPRequest *)request {
    NSError *error = [request error];
    if (!error) {
        NSString *responseStr = [request responseString];

        NSLog(@"Promo code response: %@", responseStr);
        [self shouldReturnSuccess];
        return;
    }
    [self shouldReturnFailWithMessage:GENERAL_ERROR_MESSAGE];
}

@end
