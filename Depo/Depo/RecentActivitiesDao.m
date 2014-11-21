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
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setDelegate:self];
    [self sendGetRequest:request];
}

- (void)requestFinished:(ASIHTTPRequest *)request {
    NSError *error = [request error];
    
    if (!error) {
        NSString *responseEnc = [request responseString];
        
        NSLog(@"Recent Activities Response: %@", responseEnc);

        SBJSON *jsonParser = [SBJSON new];
        NSArray *mainArray = [jsonParser objectWithString:responseEnc];
        
        NSMutableArray *result = [[NSMutableArray alloc] init];
        
        if(mainArray != nil && ![mainArray isKindOfClass:[NSNull class]]) {
            for(NSDictionary *activityDict in mainArray) {
                [result addObject:[self parseActivity:activityDict]];
            }
        }

        [self shouldReturnSuccessWithObject:result];
    } else {
        [self shouldReturnFailWithMessage:GENERAL_ERROR_MESSAGE];
    }
    
}

- (void) tempResponse {
    Activity *a1 = [[Activity alloc] init];
    a1.activityType = ActivityTypeFolder;
    a1.title = @"Eskiler klasörü oluşturuldu";
    a1.visibleHour = @"08:11";
    a1.date = [NSDate date];

    Activity *a2 = [[Activity alloc] init];
    a2.activityType = ActivityTypeImage;
    a2.title = @"3 resim Piknik klasörüne eklendi";
    a2.visibleHour = @"11:02";
    a2.date = [NSDate date];

    Activity *a3 = [[Activity alloc] init];
    a3.activityType = ActivityTypeTrash;
    a3.title = @"2 resim silindi";
    a3.visibleHour = @"17:44";
    a3.date = [NSDate dateWithTimeIntervalSince1970:1416285314];

    Activity *a4 = [[Activity alloc] init];
    a4.activityType = ActivityTypeImage;
    a4.title = @"4 resim Tatil klasörüne eklendi";
    a4.visibleHour = @"22:35";
    a4.date = [NSDate dateWithTimeIntervalSince1970:1416185414];

    Activity *a5 = [[Activity alloc] init];
    a5.activityType = ActivityTypeImage;
    a5.title = @"1 resim Okul klasörüne eklendi";
    a5.visibleHour = @"11:35";
    a5.date = [NSDate dateWithTimeIntervalSince1970:1416115414];

    NSArray *result = @[a1, a2, a3, a4];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:NO];
    result = [result sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    [self shouldReturnSuccessWithObject:result];
}
@end
