//
//  UpdateEmailDao.m
//  Depo
//
//  Created by Mahir on 20/01/16.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import "UpdateEmailDao.h"

@implementation UpdateEmailDao

- (void) requestUpdateEmail:(NSString *) emailVal {
    NSURL *url = [NSURL URLWithString:EMAIL_UPDATE_URL];
    
    NSData *postData = [emailVal dataUsingEncoding:NSUTF8StringEncoding];
    
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
        
        SBJSON *jsonParser = [SBJSON new];
        NSDictionary *mainDict = [jsonParser objectWithString:responseStr];
        if(mainDict != nil && ![mainDict isKindOfClass:[NSNull class]]) {
            if([mainDict objectForKey:@"status"] != nil && ![[mainDict objectForKey:@"status"] isKindOfClass:[NSNull class]]) {
                statusVal = [mainDict objectForKey:@"status"];
            }
        }
        [self shouldReturnSuccessWithObject:statusVal];
        return;
    }
    [self shouldReturnFailWithMessage:GENERAL_ERROR_MESSAGE];
}

@end
