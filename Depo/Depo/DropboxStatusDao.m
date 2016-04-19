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
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setDelegate:self];
    
    [self sendGetRequest:request];
}

- (void)requestFinished:(ASIHTTPRequest *)request {
    NSError *error = [request error];
    if (!error) {
        NSString *responseStr = [request responseString];
        NSLog(@"Dropbox Status Response: %@", responseStr);
        SBJSON *jsonParser = [SBJSON new];
        NSDictionary *mainDict = [jsonParser objectWithString:responseStr];
        if(mainDict != nil && ![mainDict isKindOfClass:[NSNull class]]) {
            NSNumber *connected = [mainDict objectForKey:@"connected"];
            NSNumber *failedCount = [mainDict objectForKey:@"failedCount"];
            NSNumber *progress = [mainDict objectForKey:@"progress"];
            NSNumber *successCount = [mainDict objectForKey:@"successCount"];
            NSNumber *skippedCount = [mainDict objectForKey:@"skippedCount"];
            NSNumber *totalCount = [mainDict objectForKey:@"totalCount"];
            NSString *status = [self strByRawVal:[mainDict objectForKey:@"status"]];

            DropboxExportResult *result = [[DropboxExportResult alloc] init];
            result.connected = [self boolByNumber:connected];
            result.date = [self dateByRawVal:[mainDict objectForKey:@"date"]];
            result.failedCount = [self longByNumber:failedCount];
            result.progress = [self longByNumber:progress];
            result.successCount = [self longByNumber:successCount];
            result.skippedCount = [self longByNumber:skippedCount];
            result.totalCount = [self longByNumber:totalCount];
            
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

            [self shouldReturnSuccessWithObject:result];
            return;
        }
    }
    [self shouldReturnFailWithMessage:GENERAL_ERROR_MESSAGE];
}

@end
