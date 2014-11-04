//
//  MusicPreviewController.h
//  Depo
//
//  Created by Mahir on 10/15/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "MyViewController.h"
#import "MetaFile.h"
#import <AVFoundation/AVFoundation.h>

@interface MusicPreviewController : MyViewController

@property (nonatomic, strong) MetaFile *file;
@property (nonatomic, strong) AVAudioPlayer *player;

- (id)initWithFile:(MetaFile *) _file;

@end
