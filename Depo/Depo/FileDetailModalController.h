//
//  FileDetailModalController.h
//  Depo
//
//  Created by Mahir on 03/11/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "MyModalController.h"
#import "MetaFile.h"

@interface FileDetailModalController : MyModalController

@property (nonatomic, strong) MetaFile *file;

- (id) initWithFile:(MetaFile *) _file;

@end
