//
//  RadiusDao.h
//  Depo
//
//  Created by Mahir on 27/01/15.
//  Copyright (c) 2015 com.igones. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppConstants.h"

@interface RadiusDao : NSObject

@property (nonatomic, strong) id delegate;
@property (nonatomic) SEL successMethod;
@property (nonatomic) SEL failMethod;

- (void) requestRadiusLogin;

@end
