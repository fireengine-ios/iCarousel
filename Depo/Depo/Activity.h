//
//  Activity.h
//  Depo
//
//  Created by Mahir on 19.11.2014.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppConstants.h"

@interface Activity : NSObject

@property (nonatomic) long activityId;
@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) NSString *visibleHour;
@property (nonatomic, strong) NSString *title;
@property (nonatomic) ActivityType activityType;
@property (nonatomic, strong) NSArray *actionItemList;
@property (nonatomic, strong) NSString *fileUuid;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *rawActivityType;
@property (nonatomic, strong) NSString *rawFileType;

@end
