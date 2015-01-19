//
//  Subscription.h
//  Depo
//
//  Created by Salih Topcu on 06.01.2015.
//  Copyright (c) 2015 com.igones. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SubscriptionPlan.h"

@interface Subscription : NSObject

@property (nonatomic, strong) NSString *createdDate;
@property (nonatomic, strong) NSString *lastModifiedDate;
@property (nonatomic, strong) NSString *createdBy;
@property (nonatomic, strong) NSString *lastModifiedBy;
@property (nonatomic) BOOL isCurrentSubscription;
@property (nonatomic, strong) NSString *status;
@property (nonatomic) SubscriptionPlan *plan;

@end
