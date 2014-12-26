//
//  SyncReference.m
//  Depo
//
//  Created by Mahir on 25.12.2014.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "SyncReference.h"

@implementation SyncReference

@synthesize assetUrl;
@synthesize uuid;

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.assetUrl forKey:@"assetUrl"];
    [encoder encodeObject:self.uuid forKey:@"uuid"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if((self = [super init])) {
        self.assetUrl = [decoder decodeObjectForKey:@"assetUrl"];
        self.uuid = [decoder decodeObjectForKey:@"uuid"];
    }
    return self;
}

@end
