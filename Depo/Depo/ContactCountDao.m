//
//  ContactCountDao.m
//  Depo
//
//  Created by Mahir on 16/03/15.
//  Copyright (c) 2015 com.igones. All rights reserved.
//

#import "ContactCountDao.h"

@implementation ContactCountDao

- (void) requestContactCount {
    NSURL *url = [NSURL URLWithString:TTY_CONTACT_COUNT_URL];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setDelegate:self];
    
    [self sendGetRequest:request];
}

- (void)requestFinished:(ASIHTTPRequest *)request {
    NSError *error = [request error];
    
    if (!error) {
        NSString *responseStr = [request responseString];
        SBJSON *jsonParser = [SBJSON new];
        NSDictionary *mainDict = [jsonParser objectWithString:responseStr];
        if(mainDict != nil && ![mainDict isKindOfClass:[NSNull class]]) {
            NSNumber *countData = [mainDict objectForKey:@"data"];
            if(countData != nil && ![countData isKindOfClass:[NSNull class]]) {
                [self shouldReturnSuccessWithObject:[NSString stringWithFormat:@"%d", [countData intValue]]];
                return;
            }
        }
    }
    [self shouldReturnFailWithMessage:GENERAL_ERROR_MESSAGE];
}

@end
