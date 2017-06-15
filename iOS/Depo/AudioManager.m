//
//  AudioManager.m
//  Depo
//
//  Created by Gürhan KODALAK on 31/07/15.
//  Copyright (c) 2015 com.igones. All rights reserved.
//

#import "AudioManager.h"

@implementation AudioManager

@synthesize session;

+ (AudioManager *) sharedInstance {
    static AudioManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[AudioManager alloc] init];
    });
    return sharedInstance;
}

- (id) init {
    if (self == [super init]) {
        session = [AVAudioSession sharedInstance];
        [session setActive:YES error:nil];
        [session setCategory:AVAudioSessionCategoryPlayback error:nil];
    }
    return self;
}

@end
