//
//  ContactSyncResult.m
//  Depo
//
//  Created by Mahir on 08/02/15.
//  Copyright (c) 2015 com.igones. All rights reserved.
//

#import "ContactSyncResult.h"

@implementation ContactSyncResult

@synthesize clientUpdateCount;
@synthesize serverUpdateCount;
@synthesize clientNewCount;
@synthesize serverNewCount;
@synthesize clientDeleteCount;
@synthesize serverDeleteCount;

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeInt:clientUpdateCount forKey:@"clientUpdateCount"];
    [encoder encodeInt:serverUpdateCount forKey:@"serverUpdateCount"];
    [encoder encodeInt:clientNewCount forKey:@"clientNewCount"];
    [encoder encodeInt:serverNewCount forKey:@"serverNewCount"];
    [encoder encodeInt:clientDeleteCount forKey:@"clientDeleteCount"];
    [encoder encodeInt:serverDeleteCount forKey:@"serverDeleteCount"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if((self = [super init])) {
        self.clientUpdateCount = [decoder decodeIntForKey:@"clientUpdateCount"];
        self.serverUpdateCount = [decoder decodeIntForKey:@"serverUpdateCount"];
        self.clientNewCount = [decoder decodeIntForKey:@"clientNewCount"];
        self.serverNewCount = [decoder decodeIntForKey:@"serverNewCount"];
        self.clientDeleteCount = [decoder decodeIntForKey:@"clientDeleteCount"];
        self.serverDeleteCount = [decoder decodeIntForKey:@"serverDeleteCount"];
    }
    return self;
}

@end
