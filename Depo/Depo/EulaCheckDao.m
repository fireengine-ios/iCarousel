//
//  EulaCheckDao.m
//  Depo
//
//  Created by Mahir Tarlan on 31/03/16.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import "EulaCheckDao.h"

@implementation EulaCheckDao

- (void) requestCheckEulaForLocale:(NSString *) locale {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:CHECK_EULA_URL, locale]];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setDelegate:self];
    
    [self sendGetRequest:request];
}

- (void)requestFinished:(ASIHTTPRequest *)request {
    NSError *error = [request error];
    if (!error) {
        NSString *responseStr = [request responseString];
        NSLog(@"EULA Check Response: %@", responseStr);
        
        SBJSON *jsonParser = [SBJSON new];
        NSDictionary *mainDict = [jsonParser objectWithString:responseStr];
        
        if(mainDict != nil && ![mainDict isKindOfClass:[NSNull class]]) {
            NSString *status = [self strByRawVal:[mainDict objectForKey:@"status"]];
            [self shouldReturnSuccessWithObject:status];
            return;
        }
    }
    [self shouldReturnFailWithMessage:GENERAL_ERROR_MESSAGE];
}

- (void)requestFailed:(ASIHTTPRequest *)request {
    NSString *responseStr = [request responseString];
    NSLog(@"Eula Check Error Response: %@", responseStr);
    
    if([request responseStatusCode] == 412) {
        SBJSON *jsonParser = [SBJSON new];
        NSDictionary *mainDict = [jsonParser objectWithString:responseStr];
        if(mainDict != nil && ![mainDict isKindOfClass:[NSNull class]]) {
            NSString *status = [self strByRawVal:[mainDict objectForKey:@"status"]];
            [self shouldReturnSuccessWithObject:status];
            return;
        }
        [self shouldReturnFailWithMessage:GENERAL_ERROR_MESSAGE];
    } else if([request responseStatusCode] == 403) {
        [self shouldReturnFailWithMessage:FORBIDDEN_ERROR_MESSAGE];
    } else {
        if([request.error code] == ASIConnectionFailureErrorType){
            [self shouldReturnFailWithMessage:NSLocalizedString(@"NoConnErrorMessage", @"")];
        } else {
            [self shouldReturnFailWithMessage:GENERAL_ERROR_MESSAGE];
        }
    }
}

@end
