//
//  MetaFile.h
//  Depo
//
//  Created by Mahir on 9/23/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MetaFile : NSObject

@property (nonatomic, strong) NSString *hash;
@property (nonatomic, strong) NSString *subDir;
@property (nonatomic, strong) NSString *parent;
@property (nonatomic, strong) NSString *name;
@property (nonatomic) long bytes;
@property (nonatomic) BOOL folder;
@property (nonatomic) BOOL hidden;
@property (nonatomic, strong) NSString *path;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSString *tempDownloadUrl;
@property (nonatomic, strong) NSString *contentType;
@property (nonatomic, strong) NSDate *lastModified;

@end
