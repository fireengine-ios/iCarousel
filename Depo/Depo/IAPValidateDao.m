//
//  IAPValidateDao.m
//  Depo
//
//  Created by Mahir on 20/12/15.
//  Copyright © 2015 com.igones. All rights reserved.
//

#import "IAPValidateDao.h"

@interface IAPValidateDao () {
    NSDictionary *info;
}
@end

@implementation IAPValidateDao

- (void) requestIAPValidationForProductId:(NSString *) productId withReceiptId:(NSData *) receiptId {
    NSURL *url = [NSURL URLWithString:IAP_VALIDATE_URL];

    info = [NSDictionary dictionaryWithObjectsAndKeys:
                          [receiptId base64EncodedStringWithOptions:0], @"receiptId",
                          productId, @"productId",
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
    
    //TODO "status" ve "value" degeri olan response geldigi sürece tekrar deneme yapilmayacak. status hata gösterse bile !error'a giriyor mu kontrol et. Eğer "status" FAILED gelirse ve !error'a girmezse sorun yok.
    if (!error) {
        NSString *responseStr = [request responseString];
        NSLog(@"Validate IAP Response: %@", responseStr);
        [self shouldReturnSuccessWithObject:info];
    } else {
        [self shouldReturnFailWithMessage:GENERAL_ERROR_MESSAGE];
    }
}

@end
