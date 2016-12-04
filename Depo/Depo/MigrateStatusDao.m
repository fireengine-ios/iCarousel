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
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    request = [self sendGetRequest:request];
    NSURLSessionDataTask *task = [[DepoHttpManager sharedInstance].urlSession dataTaskWithRequest:request completionHandler:[self createCompletionHandlerWithCompletion:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self requestFailed:response];
            });
        }
        else {
            if (![self checkResponseHasError:response]) {
                NSDictionary *mainDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
                
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
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self shouldReturnSuccessWithObject:result];
                    });
                }
                else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self shouldReturnFailWithMessage:GENERAL_ERROR_MESSAGE];
                    });
                }
            }
        }
    }]];
    self.currentTask = task;
    [task resume];
}

@end
