//
//  DropboxStatusDao.m
//  Depo
//
//  Created by Mahir Tarlan on 19/04/16.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import "DropboxStatusDao.h"
#import "DropboxExportResult.h"

@implementation DropboxStatusDao

- (void) requestDropboxStatus {
    NSURL *url = [NSURL URLWithString:DROPBOX_STATUS_URL];
    
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
                if(mainDict != nil && ![mainDict isKindOfClass:[NSNull class]]) {
                    NSNumber *connected = [mainDict objectForKey:@"connected"];
                    NSNumber *failedSize = [mainDict objectForKey:@"failedSize"];
                    NSNumber *failedCount = [mainDict objectForKey:@"failedCount"];
                    NSNumber *progress = [mainDict objectForKey:@"progress"];
                    NSNumber *successSize = [mainDict objectForKey:@"successSize"];
                    NSNumber *successCount = [mainDict objectForKey:@"successCount"];
                    NSNumber *skippedCount = [mainDict objectForKey:@"skippedCount"];
                    NSNumber *totalSize = [mainDict objectForKey:@"totalSize"];
                    NSString *status = [self strByRawVal:[mainDict objectForKey:@"status"]];
                    
                    DropboxExportResult *result = [[DropboxExportResult alloc] init];
                    result.connected = [self boolByNumber:connected];
                    result.date = [self dateByRawVal:[mainDict objectForKey:@"date"]];
                    result.failedSize = [self longByNumber:failedSize];
                    result.failedCount = [self longByNumber:failedCount];
                    result.progress = [self longByNumber:progress];
                    result.successSize = [self longByNumber:successSize];
                    result.successCount = [self longByNumber:successCount];
                    result.skippedCount = [self longByNumber:skippedCount];
                    result.totalSize = [self longByNumber:totalSize];
                    
                    result.status = DropboxExportStatusFinished;
                    if(status) {
                        if([status isEqualToString:@"PENDING"]) {
                            result.status = DropboxExportStatusPending;
                        } else if([status isEqualToString:@"RUNNING"]) {
                            result.status = DropboxExportStatusRunning;
                        } else if([status isEqualToString:@"FAILED"]) {
                            result.status = DropboxExportStatusFailed;
                        } else if([status isEqualToString:@"WAITING_ACTION"]) {
                            result.status = DropboxExportStatusWaitingAction;
                        } else if([status isEqualToString:@"SCHEDULED"]) {
                            result.status = DropboxExportStatusScheduled;
                        } else if([status isEqualToString:@"FINISHED"]) {
                            result.status = DropboxExportStatusFinished;
                        } else if([status isEqualToString:@"CANCELLED"]) {
                            result.status = DropboxExportStatusCancelled;
                        }
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
//    request.tag = REQ_TAG_FOR_DROPBOX;
}

@end
