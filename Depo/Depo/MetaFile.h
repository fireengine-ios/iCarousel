//
//  MetaFile.h
//  Depo
//
//  Created by Mahir on 9/23/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppConstants.h"
#import "FileDetail.h"

@interface MetaFile : NSObject

@property (nonatomic, strong) NSString *uuid;
@property (nonatomic, strong) NSString *hash;
@property (nonatomic, strong) NSString *subDir;
@property (nonatomic, strong) NSString *parent;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *visibleName;
@property (nonatomic) long bytes;
@property (nonatomic) BOOL folder;
@property (nonatomic) BOOL hidden;
@property (nonatomic, strong) NSString *path;
@property (nonatomic, strong) NSString *tempDownloadUrl;
@property (nonatomic, strong) NSString *rawContentType;
@property (nonatomic) ContentType contentType;
@property (nonatomic, strong) NSDate *lastModified;
@property (nonatomic, strong) FileDetail *detail;
@property (nonatomic, strong) NSString *contentLengthDisplay;
@property (nonatomic) int itemCount;

@end
