//
//  PartialInfo.m
//  ContactSyncExample
//
//  Created by Furkan Bahceci on 28.10.2018.
//  Copyright © 2018 Valven. All rights reserved.
//

#import "PartialInfo.h"

@implementation PartialInfo

- (instancetype)initWithCount:(NSInteger)count mode:(SYNCMode)mode{
    self = [super init];
    
    _contactCount = count;
    
    if (mode == SYNCRestore) {
        _currentStep = 1;
        _bulkCount = [self calculateBulkCount:_contactCount];
        _totalStep = 1;
    } else {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *prevContactCount = [defaults objectForKey:SYNC_KEY_CURRENT_CONTACT_COUNT];
        NSString *prevBulkCount = [defaults objectForKey:SYNC_KEY_CURRENT_BULK_COUNT];
        NSString *current = [defaults objectForKey:SYNC_KEY_CURRENT_STEP];
        _bulkCount = [self calculateBulkCount:_contactCount];
        _totalStep = ceil((float) _contactCount / (float) _bulkCount);
        [defaults setObject:[@(_contactCount) stringValue] forKey:SYNC_KEY_CURRENT_CONTACT_COUNT];
        [defaults setObject:[@(_bulkCount) stringValue] forKey:SYNC_KEY_CURRENT_BULK_COUNT];
        
        if ((SYNC_STRING_IS_NULL_OR_EMPTY(prevContactCount) || [prevContactCount integerValue] == _contactCount)
            && (SYNC_STRING_IS_NULL_OR_EMPTY(prevBulkCount) || [prevBulkCount integerValue] == _bulkCount) && ([current integerValue] <= self.totalStep )) {
            if(!SYNC_IS_NULL(current)){
                _currentStep = [current integerValue];
            } else {
                _currentStep = 1;
            }
        } else {
            NSLog(@"Partial info resetting. Current contact count: %ld Previous contact count: %@ Current step: %@ Total step : %ld", (long)_contactCount, prevContactCount, current, (long)self.totalStep);
            _currentStep = 1;
        }
        [defaults setObject:[@(_contactCount) stringValue] forKey:SYNC_KEY_CURRENT_CONTACT_COUNT];
        if (_totalStep <= 0) {
            _totalStep = 1;
        }
    }
    
    return self;
}

-(NSInteger)calculateBulkCount:(NSInteger)count{
    if (SyncSettings.shared.bulk > 0) {
        NSLog(@"Custom bulk:  %ld",(long)SyncSettings.shared.bulk);
        return SyncSettings.shared.bulk;
    }
//    if (true) {
//        return 1;
//    }
    if (count <= 200){
        return 20;
    }else if (count <= 500){
        return 50;
    }else{
        return 200;
    }
}

- (BOOL)isFirstStep
{
    return self.currentStep == 1;
}

- (BOOL)isLastStep
{
    return self.currentStep >= self.totalStep;
}

-(void)stepUp {
    self.currentStep++;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:@(self.currentStep) forKey:SYNC_KEY_CURRENT_STEP];
    [defaults synchronize];
}

-(void)erase {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:SYNC_KEY_CURRENT_STEP];
    [defaults synchronize];
}

-(NSInteger)calculateOffset{
    return _bulkCount * (_currentStep - 1);
}

-(NSString *)print{
    return [NSString stringWithFormat:@"currentStep: %ld totalStep: %ld bulkCount: %ld contactCount: %ld", _currentStep, _totalStep, _bulkCount, _contactCount];
}

@end
