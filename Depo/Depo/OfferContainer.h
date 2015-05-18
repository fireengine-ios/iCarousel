//
//  OfferContainer.h
//  Depo
//
//  Created by gurhan on 05/05/15.
//  Copyright (c) 2015 com.igones. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Offer.h"

@interface OfferContainer : NSObject

@property (nonatomic,strong) Offer *montlyOffer;
@property (nonatomic,strong) Offer *yearlyOffer;
@property float quota;


@end
