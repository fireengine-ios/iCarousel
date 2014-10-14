//
//  VideoPreviewController.h
//  Depo
//
//  Created by Mahir on 10/14/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "MyViewController.h"
#import "MetaFile.h"
#import "CustomAVPlayer.h"

@interface VideoPreviewController : MyViewController <CustomAVPlayerDelegate>

@property (nonatomic, strong) MetaFile *file;
@property (nonatomic, strong) CustomAVPlayer *avPlayer;

- (id)initWithFile:(MetaFile *) _file;

@end
