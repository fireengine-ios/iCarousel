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

@synthesize delegate;
@synthesize file;
@synthesize titleLabel;
@synthesize detailLabel;
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

        NSString *nameVal = file.visibleName;
        if(file.detail && file.detail.songTitle) {
            nameVal = file.detail.songTitle;
        }

        titleLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(65, 10, self.frame.size.width - 122, 20) withFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:15] withColor:[Util UIColorForHexColor:@"e1e1e1"] withText:nameVal];
        [self addSubview:titleLabel];

        NSString *detailVal = @"";
        if(file.detail && file.detail.artist) {
            detailVal = file.detail.artist;
        }
        if(file.detail && file.detail.album) {
            detailVal = [NSString stringWithFormat:@"%@ • %@", detailVal, file.detail.album];
        }

        detailLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(65, 30, self.frame.size.width - 122, 20) withFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:14] withColor:[Util UIColorForHexColor:@"888888"] withText:detailVal];
        [self addSubview:detailLabel];

        playButton = [[CustomButton alloc] initWithFrame:CGRectMake(self.frame.size.width - 42, 9, 32, 42) withImageName:@"music_play_icon.png"];
        playButton.hidden = YES;
        [playButton addTarget:self action:@selector(playClicked) forControlEvents:UIControlEventTouchUpInside];
        playButton.isAccessibilityElement = YES;
        playButton.accessibilityIdentifier = @"playButtonAudioMenu";
        [self addSubview:playButton];
        
        pauseButton = [[CustomButton alloc] initWithFrame:CGRectMake(self.frame.size.width - 42, 4, 32, 52) withImageName:@"pause_icon.png"];
        pauseButton.hidden = NO;
        [pauseButton addTarget:self action:@selector(pauseClicked) forControlEvents:UIControlEventTouchUpInside];
        pauseButton.isAccessibilityElement = YES;
        pauseButton.accessibilityIdentifier = @"pauseButtonAudioMenu";
        [self addSubview:pauseButton];

        UITapGestureRecognizer * singleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(audioClicked)];
        singleTapGesture.isAccessibilityElement = YES;
        [self addGestureRecognizer:singleTapGesture];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resumeNotified) name:MUSIC_RESUMED_NOTIFICATION object:nil];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pauseNotified) name:MUSIC_PAUSED_NOTIFICATION object:nil];
    }
    return self;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([touch.view isKindOfClass:[UIControl class]]) {
        return NO;
    }
    return YES;
}

- (void) audioClicked {
    [delegate audioMenuFooterWasClicked];
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
