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
    if (!error) {
        NSString *statusVal = @"";
        NSString *responseStr = [request responseString];
        
        NSLog(@"Update Msisdn Response: %@", responseStr);
        SBJSON *jsonParser = [SBJSON new];
        NSDictionary *mainDict = [jsonParser objectWithString:responseStr];
        if(mainDict != nil && ![mainDict isKindOfClass:[NSNull class]]) {
            [self shouldReturnSuccessWithObject:mainDict];
            return;
        }
    }
    [self shouldReturnFailWithMessage:GENERAL_ERROR_MESSAGE];
}

@end
