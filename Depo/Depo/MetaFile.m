//
//  MetaFile.m
//  Depo
//
//  Created by Mahir on 9/23/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "MetaFile.h"

@implementation MetaFile

@synthesize uuid;
@synthesize fileHash;
@synthesize metaHash;
@synthesize subDir;
@synthesize parent;
@synthesize parentUuid;
@synthesize name;
@synthesize visibleName;
@synthesize bytes;
@synthesize folder;
@synthesize hidden;
@synthesize path;
@synthesize tempDownloadUrl;
@synthesize rawContentType;
@synthesize contentType;
@synthesize lastModified;
@synthesize detail;
@synthesize contentLengthDisplay;
@synthesize itemCount;

- (NSUInteger) hash {
    return [self.uuid hash];
}

- (BOOL) isEqual:(id)other {
    if (other == self)
        return YES;
    if (!other || ![other isKindOfClass:[self class]])
        return NO;
    if(self.uuid == nil || ((MetaFile *)other).uuid == nil)
        return NO;
    return ([self.uuid isEqualToString:((MetaFile *)other).uuid]);
}

@end
