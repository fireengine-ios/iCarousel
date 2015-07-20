//
//  MetaFileSummary.m
//  Depo
//
//  Created by Mahir on 20/03/15.
//  Copyright (c) 2015 com.igones. All rights reserved.
//

#import "MetaFileSummary.h"

@implementation MetaFileSummary

@synthesize bytes;
@synthesize fileName;

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeInt64:self.bytes forKey:@"bytes"];
    [encoder encodeObject:self.fileName forKey:@"fileName"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if((self = [super init])) {
        self.bytes = [decoder decodeInt64ForKey:@"bytes"];
        self.fileName = [decoder decodeObjectForKey:@"fileName"];
    }
    return self;
}

- (NSUInteger) hash {
    return [self.fileName hash];
}

- (BOOL) isEqual:(id) comparedObj {
    if (comparedObj == self)
        return YES;
    if (!comparedObj || ![comparedObj isKindOfClass:[self class]])
        return NO;
    if (((MetaFileSummary *)comparedObj).bytes != self.bytes || ![((MetaFileSummary *)comparedObj).fileName isEqualToString:self.fileName])
        return NO;
    return YES;
}

@end
