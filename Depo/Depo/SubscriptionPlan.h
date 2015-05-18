//
//  SubscriptionPlan.h
//  Depo
//
//  Created by Salih Topcu on 19.01.2015.
//  Copyright (c) 2015 com.igones. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SubscriptionPlan : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *displayName;
@property (nonatomic, strong) NSString *accountDescription;
@property (nonatomic) float price;
@property (nonatomic) BOOL isDefault;
@property (nonatomic, strong) NSString *role;
@property (nonatomic, strong) NSString *slcmOfferId;
@property (nonatomic, strong) NSString *cometOfferId;
@property (nonatomic,strong) NSString *period;
@property (nonatomic) float quota;

@end
