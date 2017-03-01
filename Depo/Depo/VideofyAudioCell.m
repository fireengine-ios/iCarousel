//
//  VideofyAudioCell.m
//  Depo
//
//  Created by Mahir Tarlan on 08/07/16.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import "VideofyAudioCell.h"
#import "CustomLabel.h"
#import "Util.h"
#import "CustomButton.h"
#import "AppConstants.h"

@interface VideofyAudioCell() {
    CustomLabel *titleLabel;
    UIView *separator;
    UIImageView *choiceView;
    CustomButton *playButton;
    CustomButton *pauseButton;
}
@end

@implementation VideofyAudioCell

@synthesize delegate;
@synthesize audio;

- (id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withAudio:(VideofyAudio *) _audio {
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.audio = _audio;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        choiceView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 30, 30)];
        choiceView.image = [UIImage imageNamed:@"icon_list_circle.png"];
        [self addSubview:choiceView];
        
        titleLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(50, 15, self.frame.size.width - 100, 20) withFont:[UIFont fontWithName:@"TurkcellSaturaDem" size:13] withColor:[Util UIColorForHexColor:@"555555"] withText:self.audio.fileName];
        [self addSubview:titleLabel];
        
        playButton = [[CustomButton alloc] initWithFrame:CGRectMake(self.frame.size.width - 40, 10, 30, 30) withImageName:@"minibutton_play.png"];
        [playButton addTarget:self action:@selector(playClicked) forControlEvents:UIControlEventTouchUpInside];
        playButton.enabled = YES;
        [self addSubview:playButton];

        pauseButton = [[CustomButton alloc] initWithFrame:CGRectMake(self.frame.size.width - 40, 10, 30, 30) withImageName:@"minibutton_pause.png"];
        [pauseButton addTarget:self action:@selector(pauseClicked) forControlEvents:UIControlEventTouchUpInside];
        pauseButton.enabled = YES;
        pauseButton.hidden = YES;
        [self addSubview:pauseButton];

        separator = [[UIView alloc] initWithFrame:CGRectMake(10, self.frame.size.height - 1, self.frame.size.width - 20, 1)];
        separator.backgroundColor = [Util UIColorForHexColor:@"888888"];
        [self addSubview:separator];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetControl:) name:VIDEOFY_MUSIC_PREVIEW_CHANGED_NOTIFICATION object:nil];
    }
    return self;
}

- (void) layoutSubviews {
    [super layoutSubviews];
    titleLabel.frame = CGRectMake(50, 15, self.frame.size.width - 100, 20);
    separator.frame = CGRectMake(10, self.frame.size.height - 1, self.frame.size.width - 20, 1);
    playButton.frame = CGRectMake(self.frame.size.width - 40, 10, 30, 30);
    pauseButton.frame = CGRectMake(self.frame.size.width - 40, 10, 30, 30);
}

- (void) playClicked {
    playButton.hidden = YES;
    pauseButton.hidden = NO;
    [delegate videofyAudioCellPlayClickedWithId:self.audio.audioId];
}

- (void) pauseClicked {
    playButton.hidden = NO;
    pauseButton.hidden = YES;
    [delegate videofyAudioCellPauseClickedWithId:self.audio.audioId];
}

- (void) resetControl:(NSNotification *) notification {
    NSDictionary *userInfo = notification.userInfo;
    NSNumber *playingAudioId = [userInfo objectForKey:@"playingAudioId"];
    if(playingAudioId.longValue != self.audio.audioId) {
        playButton.hidden = NO;
        pauseButton.hidden = YES;
    }
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    if(selected) {
        choiceView.image = [UIImage imageNamed:@"icon_select.png"];
    } else {
        choiceView.image = [UIImage imageNamed:@"icon_list_circle.png"];
    }
}

@end
