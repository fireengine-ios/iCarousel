//
//  MigrateStatusDao.m
//  Depo
//
//  Created by Mahir on 03/02/15.
//  Copyright (c) 2015 com.igones. All rights reserved.
//

#import "MigrateStatusDao.h"
#import "MigrationStatus.h"

@implementation MigrateStatusDao

- (void) requestMigrationStatus {
    NSURL *url = [NSURL URLWithString:MIGRATION_STATUS_URL];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setDelegate:self];
    [self sendGetRequest:request];
}

- (void)requestFinished:(ASIHTTPRequest *)request {
    NSError *error = [request error];
    
    if (!error) {
        NSString *responseStr = [request responseString];
//        NSLog(@"Migration Status Response: %@", responseStr);
        
        SBJSON *jsonParser = [SBJSON new];
        NSDictionary *mainDict = [jsonParser objectWithString:responseStr];
        
        MigrationStatus *result = [[MigrationStatus alloc] init];
        if(mainDict != nil && ![mainDict isKindOfClass:[NSNull class]]) {
            NSNumber *progress = [mainDict objectForKey:@"progress"];
            NSString *status = [mainDict objectForKey:@"status"];
            
            if(progress != nil && ![progress isKindOfClass:[NSNull class]]) {
                result.progress = [progress floatValue];
            }
            if(status != nil && ![status isKindOfClass:[NSNull class]]) {
                result.status = status;
            }
        }
        [self shouldReturnSuccessWithObject:result];
    }
    [self shouldReturnFailWithMessage:GENERAL_ERROR_MESSAGE];
}

@end
