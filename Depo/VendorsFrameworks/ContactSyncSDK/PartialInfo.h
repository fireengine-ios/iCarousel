//
//  PartialInfo.h
//  ContactSyncExample
//
//  Created by Furkan Bahceci on 28.10.2018.
//  Copyright © 2018 Valven. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SyncConstants.h"
#import "SyncSettings.h"

@interface PartialInfo : NSObject

@property NSInteger currentStep;
@property NSInteger totalStep;
@property NSInteger bulkCount;
@property NSInteger contactCount;
@property SYNCMode mode;

- (instancetype)initWithCount:(NSInteger)count mode:(SYNCMode)mode;
- (NSString *)print;
- (NSInteger)calculateOffset;
- (void)stepUp;
- (BOOL)isFirstStep;
- (BOOL)isLastStep;
- (void)erase;

@end
