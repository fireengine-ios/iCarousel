//
//  PhotoAlbum.h
//  Depo
//
//  Created by Mahir on 10/9/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MetaFile.h"

@interface PhotoAlbum : NSObject

@property (nonatomic, strong) NSString *uuid;
@property (nonatomic) long albumId;
@property (nonatomic, strong) NSString *label;
@property (nonatomic) int imageCount;
@property (nonatomic) int videoCount;
@property (nonatomic, strong) MetaFile *cover;
@property (nonatomic) long bytes;
@property (nonatomic, strong) NSDate *lastModifiedDate;
@property (nonatomic, strong) NSArray *content;

@end
