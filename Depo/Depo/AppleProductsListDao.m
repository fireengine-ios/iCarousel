//
//  AppleProductsListDao.m
//  Depo
//
//  Created by Mahir on 09/01/16.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import "AppleProductsListDao.h"

@implementation AppleProductsListDao

- (void) requestAppleProductNames {
    NSURL *url = [NSURL URLWithString:APPLE_PRODUCT_NAMES_URL];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setDelegate:self];
    
    [self sendGetRequest:request];
}

- (void)requestFinished:(ASIHTTPRequest *)request {
    NSError *error = [request error];
    
    if (!error) {
        NSString *responseStr = [request responseString];
        SBJSON *jsonParser = [SBJSON new];
        NSArray *productNamesArray = [jsonParser objectWithString:responseStr];
        if(productNamesArray != nil && [productNamesArray isKindOfClass:[NSArray class]]) {
            [self shouldReturnSuccessWithObject:productNamesArray];
            return;
        }
    }
    [self shouldReturnFailWithMessage:GENERAL_ERROR_MESSAGE];
}

@end
