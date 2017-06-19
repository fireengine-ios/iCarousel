//
//  InternetDataUsage.h
//  Depo
//
//  Created by RDC Partner on 27/02/2017.
//  Copyright © 2017 com.igones. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface InternetDataUsage : NSObject

@property (nonatomic) long long expiryDate;
@property (nonatomic) NSString *offerName;
@property (nonatomic) long long remaining;
@property (nonatomic) long long total;
@property (nonatomic) NSString *unit;

@end

