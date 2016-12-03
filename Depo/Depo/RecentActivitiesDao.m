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
    NSString *parentListingUrl = [NSString stringWithFormat:RECENT_ACTIVITIES_URL, @"name", @"ASC", page, count];
    NSURL *url = [NSURL URLWithString:parentListingUrl];
    
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
                NSArray *mainArray = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
                
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

//- (void)requestFinished:(ASIHTTPRequest *)request {
//    NSError *error = [request error];
//    
//    if (!error) {
//        NSString *responseEnc = [request responseString];
//        
////        NSLog(@"Recent Activities Response: %@", responseEnc);
//
//        SBJSON *jsonParser = [SBJSON new];
//        NSArray *mainArray = [jsonParser objectWithString:responseEnc];
//        
//        NSDateFormatter *hourFormat = [[NSDateFormatter alloc] init];
//        [hourFormat setDateFormat:@"HH:mm"];
//
//        NSMutableArray *result = [[NSMutableArray alloc] init];
//        
//        if(mainArray != nil && ![mainArray isKindOfClass:[NSNull class]]) {
//            for(NSDictionary *activityDict in mainArray) {
//                Activity *activity = [self parseActivity:activityDict];
////                if(![activity.rawActivityType isEqualToString:@"WELCOME"]) {
//                    activity.visibleHour = [hourFormat stringFromDate:activity.date];
//                    [result addObject:activity];
////                }
//            }
//        }
//
//        [self shouldReturnSuccessWithObject:result];
//    } else {
//        [self shouldReturnFailWithMessage:GENERAL_ERROR_MESSAGE];
//    }
//    
//}

@end
