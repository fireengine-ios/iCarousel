//
//  Offer.h
//  Depo
//
//  Created by Salih Topcu on 07.01.2015.
//  Copyright (c) 2015 com.igones. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Offer : NSObject

@property (nonatomic, strong) NSString *offerId;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *campaignChannel;
@property (nonatomic, strong) NSString *campaignCode;
@property (nonatomic, strong) NSString *campaignId;
@property (nonatomic, strong) NSString *campaignUserCode;
@property (nonatomic, strong) NSString *cometParameters;
@property (nonatomic, strong) NSString *responseApi;
@property (nonatomic, strong) NSString *validationKey;
@property (nonatomic, strong) NSString *price;
@property (nonatomic, strong) NSString *role;
@property (nonatomic, strong) NSString *quota;

@end
