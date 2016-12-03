//
//  RequestTokenDao.h
//  Depo
//
//  Created by Mahir on 9/22/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppConstants.h"

@interface RequestTokenDao : NSObject

@property (nonatomic, strong) id delegate;
@property (nonatomic) SEL successMethod;
@property (nonatomic) SEL failMethod;

- (void) requestTokenForMsisdn:(NSString *) msisdnVal andPassword:(NSString *) passVal shouldRememberMe:(BOOL) rememberMeFlag;
- (void) requestTokenForMsisdn:(NSString *) msisdnVal andPassword:(NSString *) passVal shouldRememberMe:(BOOL) rememberMeFlag withCaptchaId:(NSString *) captchaId withCaptchaValue:(NSString *) captchaValue;
- (void) requestTokenByRememberMe;

@end
