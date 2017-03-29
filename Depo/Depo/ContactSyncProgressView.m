//
//  ContactSyncProgressView.m
//  Depo
//
//  Created by Turan Yilmaz on 26/03/2017.
//  Copyright © 2017 com.igones. All rights reserved.
//

#import "ContactSyncProgressView.h"
#import "Util.h"
#import "CustomLabel.h"
#import "AppConstants.h"

@implementation ContactSyncProgressView

- (id) initWithFrame:(CGRect) frame {
    if(self = [super initWithFrame:frame]) {
        
        float circleProgressWidth = IS_IPAD ? 350 : frame.size.width - 80;
        float progressLabelWidth = self.frame.size.width - 40;
        
        self.progressLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(20, 10, progressLabelWidth, 40) withFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:16] withColor:[Util UIColorForHexColor:@"363e4f"] withText:@"" withAlignment:NSTextAlignmentCenter numberOfLines:2];
        [self addSubview:self.progressLabel];
        
        
//        self.pieChart = [[XYPieChart alloc] initWithFrame:CGRectMake((frame.size.width-circleProgressWidth)/2, (frame.size.height - circleProgressWidth)/2, circleProgressWidth, circleProgressWidth)];
//        [self addSubview:self.pieChart];
        
        self.progressBar = [[CircleProgressBar alloc] initWithFrame:CGRectMake((frame.size.width-circleProgressWidth)/2, (self.progressLabel.frame.origin.y + self.progressLabel.frame.size.height) + (IS_IPAD ? 90 : 20), circleProgressWidth, circleProgressWidth)];
        self.progressBar.progressBarWidth = 5.0;
        self.progressBar.progressBarProgressColor = [Util UIColorForHexColor:@"3fb0e8"];
        self.progressBar.progressBarTrackColor = [UIColor clearColor];
        self.progressBar.startAngle = 270.0;
        self.progressBar.hintHidden = YES;
        self.progressBar.backgroundColor = [UIColor clearColor];
        [self addSubview:self.progressBar];
        
//        UIImageView *pieChartBG = [[UIImageView alloc] initWithFrame:CGRectMake((frame.size.width - 300)/2, 10, 300, 300)];
        UIImageView *pieChartBG = [[UIImageView alloc] initWithFrame:CGRectMake((frame.size.width - (self.progressBar.frame.size.width))/2, self.progressBar.frame.origin.y, self.progressBar.frame.size.width, self.progressBar.frame.size.width)];
        pieChartBG.image = [UIImage imageNamed:@"contact_progress.png"];
//        pieChartBG.backgroundColor = [UIColor redColor];
        pieChartBG.contentMode = UIViewContentModeScaleAspectFit;
        pieChartBG.clipsToBounds = YES;
        [pieChartBG.layer setCornerRadius:pieChartBG.frame.size.width/2];
        [self addSubview:pieChartBG];
        
        [self bringSubviewToFront:self.progressBar];
        
        UIView *labelAndIconView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.progressBar.frame.size.width - 30, self.progressBar.frame.size.height - 30)];
        labelAndIconView.center = CGPointMake(self.progressBar.frame.size.width  / 2, self.progressBar.frame.size.height / 2);
        [self.progressBar addSubview:labelAndIconView];
        
        labelAndIconView.backgroundColor = [UIColor whiteColor];
        labelAndIconView.clipsToBounds = YES;
        [labelAndIconView.layer setCornerRadius:labelAndIconView.frame.size.width/2];
        
        UIView *labelIconContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, labelAndIconView.frame.size.width - 100, labelAndIconView.frame.size.height - 100)];
        labelIconContainer.center = CGPointMake(labelAndIconView.frame.size.width  / 2, labelAndIconView.frame.size.height / 2);
        [labelAndIconView addSubview:labelIconContainer];
        
        
        UIImageView *contactsIconIV = [[UIImageView alloc] initWithFrame:CGRectMake((labelIconContainer.frame.size.width-60)/2, (labelIconContainer.frame.size.height/2) - 60 - 5, 60, 60)];
        contactsIconIV.image = [UIImage imageNamed:@"new_contacts_icon.png"];
        contactsIconIV.contentMode = UIViewContentModeScaleAspectFit;
        [labelIconContainer addSubview:contactsIconIV];
        
        self.percentLabel = [[CustomLabel alloc] initWithFrame:CGRectMake((labelIconContainer.frame.size.width-60)/2, (labelIconContainer.frame.size.height/2) + 5, 60, 40) withFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:32] withColor:[Util UIColorForHexColor:@"363e4f"] withText:@"% 0" withAlignment:NSTextAlignmentCenter];
        [labelIconContainer addSubview:self.percentLabel];
        
        
        
        
        
        
        
        
    }
    return self;
}


@end
