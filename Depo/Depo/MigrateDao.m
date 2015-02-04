//
//  MigrateDao.m
//  Depo
//
//  Created by Mahir on 03/02/15.
//  Copyright (c) 2015 com.igones. All rights reserved.
//

#import "MigrateDao.h"

@implementation MigrateDao

- (void) requestSendMigrate {
    NSURL *url = [NSURL URLWithString:MIGRATION_URL];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setDelegate:self];
    [self sendGetRequest:request];
}

- (void)requestFinished:(ASIHTTPRequest *)request {
    NSError *error = [request error];
    
    if (!error) {
        NSString *responseStr = [request responseString];
        NSLog(@"Migration response: %@", responseStr);
    }
    [self shouldReturnSuccess];
}

@end
