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

- (id) initWithFrame:(CGRect)frame {
    if(self = [super initWithFrame:frame]) {
        self.backgroundColor = [Util UIColorForHexColor:@"ffe000"];
        
        infoLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(20, 3, self.frame.size.width - 40, 18) withFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:14] withColor:[Util UIColorForHexColor:@"565656"] withText:@""];
        [self addSubview:infoLabel];
    }
    return self;
}

- (void) reCheckInfo {
    int totalAutoSyncCount = [APPDELEGATE.uploadQueue totalAutoSyncCount];
    int finishedAutoSyncCount = [APPDELEGATE.uploadQueue finishedAutoSyncCount];
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
