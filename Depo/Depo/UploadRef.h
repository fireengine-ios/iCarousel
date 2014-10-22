//
//  UploadRef.h
//  Depo
//
//  Created by Mahir on 10/6/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppConstants.h"

@interface UploadRef : NSObject

@property (nonatomic, strong) NSString *fileName;
@property (nonatomic, strong) NSString *filePath;
@property (nonatomic, strong) NSString *folderUuid;
@property (nonatomic, strong) NSString *fileUuid;
@property (nonatomic, strong) NSString *tempUrl;
@property (nonatomic, strong) NSString *urlForUpload;
@property (nonatomic) ContentType contentType;

@end
