//
//  FBStatusDao.m
//  Depo
//
//  Created by Mahir Tarlan on 08/07/16.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import "FBStatusDao.h"
#import "SocialExportResult.h"

@implementation FBStatusDao

- (void) requestFBStatus {
    NSURL *url = [NSURL URLWithString:FB_STATUS_URL];
    
    IGLog(@"[GET] FBStatusDao requestFBStatus called");
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    request = [self sendGetRequest:request];
    
    NSURLSessionDataTask *task = [[DepoHttpManager sharedInstance].urlSession dataTaskWithRequest:request completionHandler:[self createCompletionHandlerWithCompletion:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            IGLog(@"EulaApproveDao requestFinished with general error");
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self requestFailed:response];
            });
        }
        else {
            if (![self checkResponseHasError:response]) {
                IGLog(@"EulaApproveDao requestFinished successfully");
                NSDictionary *mainDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
                if(mainDict != nil && ![mainDict isKindOfClass:[NSNull class]]) {
                    NSNumber *connected = [mainDict objectForKey:@"connected"];
                    NSNumber *syncEnabled = [mainDict objectForKey:@"syncEnabled"];
                    NSString *date = [mainDict objectForKey:@"date"];
                    NSString *status = [mainDict objectForKey:@"status"];
                    
                    SocialExportResult *result = [[SocialExportResult alloc] init];
                    result.connected = [self boolByNumber:connected];
                    result.syncEnabled = [self boolByNumber:syncEnabled];
                    result.lastDate = [self dateByRawVal:date];
                    
                    result.status = SocialExportStatusFinished;
                    if(status) {
                        if([status isEqualToString:@"PENDING"]) {
                            result.status = SocialExportStatusPending;
                        } else if([status isEqualToString:@"RUNNING"]) {
                            result.status = SocialExportStatusRunning;
                        } else if([status isEqualToString:@"FAILED"]) {
                            result.status = SocialExportStatusFailed;
                        } else if([status isEqualToString:@"WAITING_ACTION"]) {
                            result.status = SocialExportStatusWaitingAction;
                        } else if([status isEqualToString:@"SCHEDULED"]) {
                            result.status = SocialExportStatusScheduled;
                        } else if([status isEqualToString:@"FINISHED"]) {
                            result.status = SocialExportStatusFinished;
                        } else if([status isEqualToString:@"CANCELLED"]) {
                            result.status = SocialExportStatusCancelled;
                        }
                    }
                    
                    IGLog(@"FBStatusDao request finished successfully");
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self shouldReturnSuccessWithObject:result];
                    });
                }
                else {
                    IGLog(@"FBStatusDao request failed with general error");
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self shouldReturnFailWithMessage:GENERAL_ERROR_MESSAGE];
                    });
                }
            }
            else {
                [self requestFailed:response];
            }
        }
    }]];
    self.currentTask = task;
    [task resume];
}

@end
