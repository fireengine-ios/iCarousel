//
//  AudioMenuFooterView.m
//  Depo
//
//  Created by Mahir on 27.11.2014.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "AudioMenuFooterView.h"
#import "Util.h"
#import "AppDelegate.h"
#import "AppSession.h"

@implementation AudioMenuFooterView

@synthesize file;
@synthesize titleLabel;
@synthesize albumImgView;
@synthesize playButton;
@synthesize pauseButton;

- (id) initWithFrame:(CGRect)frame withFile:(MetaFile *) _file {
    if(self = [super initWithFrame:frame]) {
        self.file = _file;
        
        self.backgroundColor = [Util UIColorForHexColor:@"363e4f"];
        
        UIImage *albumImg = [UIImage imageNamed:@"music_icon.png"];
        albumImgView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 40, 36)];
        albumImgView.image = albumImg;
        [self addSubview:albumImgView];

        titleLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(65, 20, self.frame.size.width - 122, 20) withFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:15] withColor:[Util UIColorForHexColor:@"e1e1e1"] withText:self.file.name];
        [self addSubview:titleLabel];

        playButton = [[CustomButton alloc] initWithFrame:CGRectMake(self.frame.size.width - 42, 9, 32, 42) withImageName:@"music_play_icon.png"];
        playButton.hidden = YES;
        [playButton addTarget:self action:@selector(playClicked) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:playButton];
        
        pauseButton = [[CustomButton alloc] initWithFrame:CGRectMake(self.frame.size.width - 42, 4, 32, 52) withImageName:@"pause_icon.png"];
        pauseButton.hidden = NO;
        [pauseButton addTarget:self action:@selector(pauseClicked) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:pauseButton];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resumeNotified) name:MUSIC_RESUMED_NOTIFICATION object:nil];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pauseNotified) name:MUSIC_PAUSED_NOTIFICATION object:nil];
    }
    return self;
}

- (void) playClicked {
    playButton.hidden = YES;
    pauseButton.hidden = NO;
    [APPDELEGATE.session playAudioItem];
}

- (void) pauseClicked {
    playButton.hidden = NO;
    pauseButton.hidden = YES;
    [APPDELEGATE.session pauseAudioItem];
}

- (void) resumeNotified {
    playButton.hidden = YES;
    pauseButton.hidden = NO;
}

- (void) pauseNotified {
    playButton.hidden = NO;
    pauseButton.hidden = YES;
}

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MUSIC_RESUMED_NOTIFICATION object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MUSIC_PAUSED_NOTIFICATION object:nil];
}

@end
