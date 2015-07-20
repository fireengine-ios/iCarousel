//
//  SharedUtil.h
//  Depo
//
//  Created by Mahir on 18/07/15.
//  Copyright (c) 2015 com.igones. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SharedUtil : NSObject

+ (void) writeSharedToken:(NSString *) token;
+ (NSString *) readSharedToken;
+ (void) writeSharedRememberMeToken:(NSString *) token;
+ (NSString *) readSharedRememberMeToken;
+ (void) writeSharedBaseUrl:(NSString *) url;
+ (NSString *) readSharedBaseUrl;

@end
