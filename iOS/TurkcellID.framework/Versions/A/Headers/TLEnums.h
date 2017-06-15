//
//  TLEnums.h
//  TurkcellID
//
//  Created by Kerem Gunduz on 18/02/15.
//  Copyright (c) 2015 . All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, TLLoginType)
{
    TcellLoginTypeNonLogin,
    TcellLoginTypeServiceLogin,
    TcellLoginTypeRememberMe,
    TcellLoginTypeLightLoginRememberMe,
    TcellLoginTypeLightLogin,
    TcellLoginTypeTouchID    
};

#define kTLLoginTypeArray @"TcellLoginTypeNonLogin", @"TcellLoginTypeServiceLogin", @"TcellLoginTypeRememberMe", @"TcellLoginTypeLightLoginRememberMe", @"TcellLoginTypeLightLogin", @"TcellLoginTypeTouchID", nil


