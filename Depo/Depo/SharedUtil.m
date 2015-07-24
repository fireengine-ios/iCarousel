//
//  SharedUtil.m
//  Depo
//
//  Created by Mahir on 18/07/15.
//  Copyright (c) 2015 com.igones. All rights reserved.
//

#import "SharedUtil.h"

#ifdef PLATFORM_STORE
#define SHARED_GROUP_NAME @"group.com.turkcell.akillidepo"
#elif defined PLATFORM_ICT
#define SHARED_GROUP_NAME @"group.com.turkcell.akillideponew.ent"
#else
#define SHARED_GROUP_NAME @"group.com.igones.Depo"
#endif
#define SHARED_TOKEN_KEY @"SHARED_TOKEN_KEY"
#define SHARED_REMEMBER_ME_TOKEN_KEY @"SHARED_REMEMBER_ME_TOKEN_KEY"
#define SHARED_BASE_URL @"SHARED_BASE_URL"

@implementation SharedUtil

+ (void) writeSharedToken:(NSString *) token {
    NSUserDefaults *sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:SHARED_GROUP_NAME];
    [sharedDefaults setObject:token forKey:SHARED_TOKEN_KEY];
    [sharedDefaults synchronize];
}

+ (NSString *) readSharedToken {
    NSUserDefaults *sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:SHARED_GROUP_NAME];
    return [sharedDefaults objectForKey:SHARED_TOKEN_KEY];
}

+ (void) writeSharedRememberMeToken:(NSString *) token {
    NSUserDefaults *sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:SHARED_GROUP_NAME];
    [sharedDefaults setObject:token forKey:SHARED_REMEMBER_ME_TOKEN_KEY];
    [sharedDefaults synchronize];
}

+ (NSString *) readSharedRememberMeToken {
    NSUserDefaults *sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:SHARED_GROUP_NAME];
    return [sharedDefaults objectForKey:SHARED_REMEMBER_ME_TOKEN_KEY];
}

+ (void) writeSharedBaseUrl:(NSString *) url {
    NSUserDefaults *sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:SHARED_GROUP_NAME];
    [sharedDefaults setObject:url forKey:SHARED_BASE_URL];
    [sharedDefaults synchronize];
}

+ (NSString *) readSharedBaseUrl {
    NSUserDefaults *sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:SHARED_GROUP_NAME];
    return [sharedDefaults objectForKey:SHARED_BASE_URL];
}

@end
