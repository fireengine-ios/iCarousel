//
//  ProvisionDao.m
//  Depo
//
//  Created by Mahir on 03/02/15.
//  Copyright (c) 2015 com.igones. All rights reserved.
//

#import "ProvisionDao.h"

@implementation ProvisionDao

- (void) requestSendProvision {
    NSURL *url = [NSURL URLWithString:PROVISION_URL];
    
    NSDictionary *dict = [[NSDictionary alloc] init];
    
    SBJSON *json = [SBJSON new];
    NSString *jsonStr = [json stringWithObject:dict];
    NSData *postData = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
//    NSLog(@"Provision Load: %@", jsonStr);
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setPostBody:postData];
    [request setDelegate:self];
    
    [self sendPostRequest:request];
}

- (void)requestFinished:(ASIHTTPRequest *)request {
    NSError *error = [request error];
    
    if (!error) {
        NSString *responseStr = [request responseString];
        NSLog(@"Provision response: %@", responseStr);
    }
    [self shouldReturnSuccess];
}

@end
