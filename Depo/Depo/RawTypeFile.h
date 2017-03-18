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
#import <AssetsLibrary/AssetsLibrary.h>

@interface RawTypeFile : NSObject

@property (nonatomic) RawFileType rawType;
@property (nonatomic, strong) UploadRef *uploadRef;
@property (nonatomic, strong) ALAsset *assetRef;
@property (nonatomic, strong) MetaFile *fileRef;
@property (nonatomic, strong) NSDate *refDate;
@property (nonatomic, strong) NSString *hashRef;

@end
