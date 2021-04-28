//
//  Utils.m
//  ContactSyncExample
//
//  Created by Furkan Bahceci on 14.01.2020.
//  Copyright © 2020 Valven. All rights reserved.
//

#import "Utils.h"

@implementation Utils

+ (BOOL)notify:(NSInteger)counter size:(NSInteger)size {
    if (counter % (int) ceil((size/50.0)) == 0) {
        return true;
    }
    return false;
}

@end
