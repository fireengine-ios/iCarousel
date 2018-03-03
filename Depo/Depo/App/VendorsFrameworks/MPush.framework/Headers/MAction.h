//
//  XPAction.h
//  XPush
//
//  Created by Vlad Soroka on 8/23/17.
//  Copyright © 2017 XPush. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MPublicConstants.h"

@interface MAction : NSObject

///click, dismiss, display
@property (nonatomic, readonly) MActionType type;

@property (nonatomic, readonly, nullable) NSString *identifier;
@property (nonatomic, readonly, nullable) NSURL *url;
@property (nonatomic, readonly, nullable) NSString *deeplink;
@property (nonatomic, readwrite, nullable) NSString* inapp;

@end
