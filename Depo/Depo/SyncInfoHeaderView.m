//
//  SyncInfoHeaderView.m
//  Depo
//
//  Created by Mahir on 28/03/15.
//  Copyright (c) 2015 com.igones. All rights reserved.
//

#import "SyncInfoHeaderView.h"
#import "Util.h"
#import "AppDelegate.h"

@implementation SyncInfoHeaderView

@synthesize infoLabel;
@synthesize indicator;

- (id) initWithFrame:(CGRect)frame {
    if(self = [super initWithFrame:frame]) {
        self.backgroundColor = [Util UIColorForHexColor:@"ffe000"];
        
        infoLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(60, 3, self.frame.size.width - 70, 18) withFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:14] withColor:[Util UIColorForHexColor:@"565656"] withText:@""];
        [self addSubview:infoLabel];
        
        indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        indicator.center = CGPointMake(30, self.frame.size.height/2);
        [self addSubview:indicator];
    }
    return self;
}

- (void) show {
    self.hidden = NO;
    [indicator startAnimating];
}

- (void) hide {
    self.hidden = YES;
    [indicator stopAnimating];
}

- (void) reCheckInfo {
    int totalAutoSyncCount = [[UploadQueue sharedInstance] totalAutoSyncCount];
    int finishedAutoSyncCount = [[UploadQueue sharedInstance] finishedAutoSyncCount];
    NSString *infoMessage = [NSString stringWithFormat:NSLocalizedString(@"AutoSyncStatusInfo", @""), finishedAutoSyncCount + 1, totalAutoSyncCount];
    infoLabel.text = infoMessage;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
