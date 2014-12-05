//
//  AuthResponse.h
//  Acdm_1
//
//  Created by mahir tarlan on 12/30/13.
//  Copyright (c) 2013 igones. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AuthResponse : NSObject

@property (nonatomic) int code;
@property (nonatomic) BOOL isSuccess;
@property (nonatomic, strong) NSString *message;
@property (nonatomic) BOOL rememberMe;
@property (nonatomic) BOOL showCaptcha;
@property (nonatomic, strong) NSString *authToken;
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *clientSecret;

@end
