//
//  ImagePreviewController.h
//  Depo
//
//  Created by Mahir on 10/5/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "MyViewController.h"
#import "MetaFile.h"

@interface ImagePreviewController : MyViewController

@property (nonatomic, strong) MetaFile *file;

- (id)initWithFile:(MetaFile *) _file;

@end
