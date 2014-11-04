//
//  FolderDetailModalController.h
//  Depo
//
//  Created by Mahir on 03/11/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "MyModalController.h"
#import "MetaFile.h"

@interface FolderDetailModalController : MyModalController

@property (nonatomic, strong) MetaFile *folder;

- (id) initWithFolder:(MetaFile *) _folder;

@end
