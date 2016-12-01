//
//  RecentActivitiesDao.m
//  Depo
//
//  Created by Mahir on 19.11.2014.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "RecentActivitiesDao.h"
#import "Activity.h"

@implementation RecentActivitiesDao

- (void) requestRecentActivitiesForPage:(int) page andCount:(int) count {
    NSLog(@"requestRecentActivitiesForPage:");
    NSString *parentListingUrl = [NSString stringWithFormat:RECENT_ACTIVITIES_URL, @"name", @"ASC", page, count];
    NSURL *url = [NSURL URLWithString:parentListingUrl];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setDelegate:self];
    [self sendGetRequest:request];
}

- (void)requestFinished:(ASIHTTPRequest *)request {
    NSLog(@"requestRecentActivitiesForPageFinished:");
    NSError *error = [request error];
    
    if (!error) {
        NSString *responseEnc = [request responseString];
        
       NSLog(@"Recent Activities Response: %@", responseEnc);

        SBJSON *jsonParser = [SBJSON new];
        NSArray *mainArray = [jsonParser objectWithString:responseEnc];
        
        NSDateFormatter *hourFormat = [[NSDateFormatter alloc] init];
        [hourFormat setDateFormat:@"HH:mm"];

        NSMutableArray *result = [[NSMutableArray alloc] init];
        
        if(mainArray != nil && ![mainArray isKindOfClass:[NSNull class]]) {
            for(NSDictionary *activityDict in mainArray) {
                Activity *activity = [self parseActivity:activityDict];
//                if(![activity.rawActivityType isEqualToString:@"WELCOME"]) {
                    activity.visibleHour = [hourFormat stringFromDate:activity.date];
                    [result addObject:activity];
//                }
            }
        }

        [self shouldReturnSuccessWithObject:result];
    } else {
        [self shouldReturnFailWithMessage:GENERAL_ERROR_MESSAGE];
    }
    
}

@end
