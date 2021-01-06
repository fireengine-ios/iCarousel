//
//  BackupVersion.m
//  ContactSyncExample
//
//  Created by Enes Kokturk on 16.09.2020.
//  Copyright © 2020 Valven. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BackupVersion.h"

@implementation BackupVersion

- (instancetype)initWithDictionary:(NSDictionary*)json
{
    self = [super init];
    if (self){
        
        _created= json[@"created"];
        _modified = json[@"modified"];
        _objectId = json[@"id"];
        _key = json[@"key"];
        _total = json[@"total"];
        _isLast = json[@"is_last"];
        
    }
    return self;
}
@end
