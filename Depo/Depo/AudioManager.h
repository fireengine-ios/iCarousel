//
//  AudioManager.h
//  Depo
//
//  Created by Gürhan KODALAK on 31/07/15.
//  Copyright (c) 2015 com.igones. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>

@interface AudioManager : NSObject

@property (nonatomic, strong) AVAudioSession *session;

+ (AudioManager *) sharedInstance;

@end
