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
    
    IGLog(@"FBStatusDao requestFBStatus called");
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setDelegate:self];
    [self sendGetRequest:request];
}

- (void) requestFinished:(ASIHTTPRequest *)request {
    NSError *error = [request error];
    if (!error) {
        NSString *responseStr = [request responseString];
        NSLog(@"FBStatusDao requestFBStatus Response: %@", responseStr);
        
        SBJSON *jsonParser = [SBJSON new];
        NSDictionary *mainDict = [jsonParser objectWithString:responseStr];
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
            
            [self shouldReturnSuccessWithObject:result];
            return;
        }
    }
    [self shouldReturnFailWithMessage:GENERAL_ERROR_MESSAGE];
}

@end
