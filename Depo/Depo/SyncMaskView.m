//
//  SyncMaskView.m
//  Depo
//
//  Created by Mahir Tarlan on 22/03/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

#import "SyncMaskView.h"
#import "UploadQueue.h"
#import "CustomLabel.h"
#import "Util.h"

@implementation SyncMaskView

@synthesize delegate;

- (id) initWithFrame:(CGRect)frame {
    if(self = [super initWithFrame:frame]) {
        UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        bgView.backgroundColor = [UIColor blackColor];
        bgView.alpha = 0.8f;
        [self addSubview:bgView];

        UITapGestureRecognizer *cancelRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(triggerCancelSyncProcess)];
        cancelRecognizer.numberOfTapsRequired = 1;
        [bgView addGestureRecognizer:cancelRecognizer];
        
        UIView *infoView = [[UIView alloc] initWithFrame:CGRectMake(30, self.frame.size.height - 100, self.frame.size.width - 60, 60)];
        infoView.backgroundColor = [UIColor whiteColor];
        [self addSubview:infoView];
        
        CustomLabel *infoLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(10, 0, infoView.frame.size.width - 20, infoView.frame.size.height) withFont:[UIFont fontWithName:@"TurkcellSaturaDem" size:14] withColor:[Util UIColorForHexColor:@"555555"] withText:NSLocalizedString(@"UploadingPhoto", @"") withAlignment:NSTextAlignmentCenter numberOfLines:2];
        [infoView addSubview:infoLabel];
    }
    return self;
}

- (void) triggerCancelSyncProcess {
    [delegate syncMaskViewShouldClose];
}

@end
