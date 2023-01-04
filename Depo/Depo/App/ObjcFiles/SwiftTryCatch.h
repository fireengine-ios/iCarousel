//
//  ObjC.h
//  Depo
//
//  Created by yilmaz edis on 2.01.2023.
//  Copyright © 2023 LifeTech. All rights reserved.
//

#ifndef ObjC_h
#define ObjC_h

#import <Foundation/Foundation.h>
/// little bit modifeid
/// added -fobjc-arc-exceptions to build phase of SwiftTryCatch.m
/// https://github.com/williamFalcon/SwiftTryCatch

@interface SwiftTryCatch : NSObject
+ (void)try:(__attribute__((noescape))  void(^ _Nullable)(void))try catch:(__attribute__((noescape)) void(^ _Nullable)(NSException* _Nullable exception))catch finally:(__attribute__((noescape)) void(^ _Nullable)(void))finally;
+ (void)throwString:(NSString*_Nullable)s;
+ (void)throwException:(NSException*_Nullable)e;
@end

#endif /* ObjC_h */
