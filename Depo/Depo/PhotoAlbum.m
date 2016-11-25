//
//  PhotoAlbum.m
//  Depo
//
//  Created by Mahir on 10/9/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "PhotoAlbum.h"

@implementation PhotoAlbum

@synthesize uuid;
@synthesize albumId;
@synthesize label;
@synthesize imageCount;
@synthesize videoCount;
@synthesize cover;
@synthesize bytes;
@synthesize isReadOnly;
@synthesize lastModifiedDate;
@synthesize content;


-(PhotoAlbum *)initWithMetaFile:(MetaFile *)file {
    self = [super init];
    if (self) {
        self.uuid = file.uuid;
        self.albumId = file.Id;
        self.label = file.name;
    }
    
    return self;
}

@end
