//
//  ObjC.c
//  Depo
//
//  Created by yilmaz edis on 2.01.2023.
//  Copyright © 2023 LifeTech. All rights reserved.
//

#import "SwiftTryCatch.h"

@implementation SwiftTryCatch

/**
 Provides try catch functionality for swift by wrapping around Objective-C
 */
+ (void)try:(__attribute__((noescape))  void(^ _Nullable)(void))try catch:(__attribute__((noescape)) void(^ _Nullable)(NSException*_Nullable exception))catch finally:(__attribute__((noescape)) void(^ _Nullable)(void))finally {
    @try {
        if (try != NULL) try();
    }
    @catch (NSException *exception) {
        if (catch != NULL) catch(exception);
    }
    @finally {
        if (finally != NULL) finally();
    }
}

+ (void)throwString:(NSString*_Nullable)s
{
    @throw [NSException exceptionWithName:s reason:s userInfo:nil];
}

+ (void)throwException:(NSException*_Nullable)e
{
    @throw e;
}

@end
