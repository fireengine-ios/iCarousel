//
//  EulaApproveDao.m
//  Depo
//
//  Created by Mahir Tarlan on 31/03/16.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import "EulaApproveDao.h"

@implementation EulaApproveDao

- (void) requestApproveEulaForId:(int) eulaId {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:APPROVE_EULA_URL, eulaId]];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setDelegate:self];
    
    [self sendGetRequest:request];
}

- (void)requestFinished:(ASIHTTPRequest *)request {
    NSError *error = [request error];
    if (!error) {
        NSString *responseStr = [request responseString];
        NSLog(@"EULA Approve Response: %@", responseStr);
        [self shouldReturnSuccess];
    }
    [self shouldReturnFailWithMessage:GENERAL_ERROR_MESSAGE];
}

@end
