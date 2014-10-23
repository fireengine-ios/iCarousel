//
//  CacheUtil.h
//  Depo
//
//  Created by Mahir on 9/23/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CacheUtil : NSObject

+ (NSString *) readCachedMsisdn;
+ (NSString *) readCachedPassword;
+ (void) writeCachedMsisdn:(NSString *) newMsisdn;
+ (void) writeCachedPassword:(NSString *) newPass;
+ (void) resetCachedMsisdn;
+ (void) resetCachedPassword;
+ (BOOL) showConfirmDeletePageFlag;
+ (void) setConfirmDeletePageFlag;

@end
