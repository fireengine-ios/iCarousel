//
//  RawTypeFile.h
//  Depo
//
//  Created by Mahir Tarlan on 09/01/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppConstants.h"
#import "UploadRef.h"
#import "MetaFile.h"

@interface RawTypeFile : NSObject

@property (nonatomic) RawFileType rawType;
@property (nonatomic, strong) UploadRef *uploadRef;
@property (nonatomic, strong) MetaFile *metaFile;

@end
