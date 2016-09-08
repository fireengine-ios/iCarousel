//
//  FaqUrlDao.m
//  Depo
//
//  Created by Mahir Tarlan on 08/09/16.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import "FaqUrlDao.h"
#import "Util.h"

@implementation FaqUrlDao

- (void) requestFaqUrl {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:FAQ_RETRIEVAL_URL, [Util readLocaleCode]]];
    
    IGLog(@"[GET] FaqUrlDao requestFaqUrl called");
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setDelegate:self];
    [self sendGetRequest:request];
}

- (void) requestFinished:(ASIHTTPRequest *)request {
    NSError *error = [request error];
    if (!error) {
        NSString *responseStr = [request responseString];
        NSLog(@"FaqUrlDao requestFaqUrl Success With Response: %@", responseStr);
        IGLog(@"FaqUrlDao requestFaqUrl Success");
        [self shouldReturnSuccessWithObject:responseStr];
        return;
    }
    IGLog(@"FaqUrlDao requestFaqUrl failed with general error");
    [self shouldReturnFailWithMessage:GENERAL_ERROR_MESSAGE];
}

@end
