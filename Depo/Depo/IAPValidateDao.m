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
    
    SBJSON *json = [SBJSON new];
    NSString *jsonStr = [json stringWithObject:info];
    NSData *postData = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    request.tag = REQ_TAG_FOR_PACKAGE;
    [request setPostBody:postData];
    [request setDelegate:self];
    
    [self sendPostRequest:request];
}

- (void) requestIAPValidationForProductId:(NSString *) productId withReceiptId:(NSString *) receiptId {
    NSURL *url = [NSURL URLWithString:IAP_VALIDATE_URL];
    
    info = [NSDictionary dictionaryWithObjectsAndKeys:
            receiptId, @"receiptId",
            productId, @"productId",
            nil];
    
    SBJSON *json = [SBJSON new];
    NSString *jsonStr = [json stringWithObject:info];
    NSData *postData = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    request.tag = REQ_TAG_FOR_PACKAGE;
    [request setPostBody:postData];
    [request setDelegate:self];
    
    [self sendPostRequest:request];
}

- (void)requestFinished:(ASIHTTPRequest *)request {
    NSError *error = [request error];
    
    if (!error) {
        NSString *responseStr = [request responseString];
        NSLog(@"IAP Validate Response: %@", responseStr);
        SBJSON *jsonParser = [SBJSON new];
        NSDictionary *mainDict = [jsonParser objectWithString:responseStr];
        if(mainDict && [mainDict isKindOfClass:[NSDictionary class]]) {
            NSString *status = [mainDict objectForKey:@"status"];
            if(status != nil && ![status isKindOfClass:[NSNull class]]) {
                [self shouldReturnSuccessWithObject:status];
                return;
            }
        }
        [self shouldReturnFailWithMessage:GENERAL_ERROR_MESSAGE];
    } else {
        [self shouldReturnFailWithMessage:GENERAL_ERROR_MESSAGE];
    }
}

@end
