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
            if([mainDict objectForKey:@"status"] != nil && [[mainDict objectForKey:@"status"] isKindOfClass:[NSString class]]) {
                statusVal = [mainDict objectForKey:@"status"];
            } else if([mainDict objectForKey:@"status"] != nil && [[mainDict objectForKey:@"status"] isKindOfClass:[NSNumber class]]) {
                //TODO normalde status "OK" gibi string gelmeli. Fakat sunucu tarafindaki bir sorundan dolayını bu kontrol eklendi
                NSNumber *status = [mainDict objectForKey:@"status"];
                if([status intValue] != 200 && [status intValue] != 0) {
                    [self shouldReturnFailWithMessage:GENERAL_ERROR_MESSAGE];
                    return;
                }
            }
        }
        [self shouldReturnSuccessWithObject:statusVal];
        return;
    }
    [self shouldReturnFailWithMessage:GENERAL_ERROR_MESSAGE];
}

@end
