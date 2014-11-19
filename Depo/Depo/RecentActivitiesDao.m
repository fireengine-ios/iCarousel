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

- (void) requestRecentActivitiesForOffset:(int) offset andCount:(int) count {
    [self performSelector:@selector(tempResponse) withObject:nil afterDelay:1.0f];
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
