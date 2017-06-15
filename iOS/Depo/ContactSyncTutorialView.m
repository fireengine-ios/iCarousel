//
//  ContactSyncTutorialView.m
//  Depo
//
//  Created by RDC on 04/05/2017.
//  Copyright © 2017 com.igones. All rights reserved.
//

#import "ContactSyncTutorialView.h"
#import "Util.h"

@implementation ContactSyncTutorialView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        NSString *locale = [[Util readLocaleCode] isEqualToString:@"tr"] ? @"tr" : @"en";
        
        NSString *imageName = [locale isEqualToString:@"tr"] ? @"Lifebox-0@3x.png" : @"Lifebox-0 Eng@3x.png";
        
        // +2 fotografin en altindaki beyaz cizgiyi kapatmak icin
        UIImageView *bgImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height +2)];
        bgImgView.image = [UIImage imageNamed:imageName];
        bgImgView.contentMode = UIViewContentModeScaleToFill;
        [self addSubview:bgImgView];
        
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(triggerDismiss)];
        tapGestureRecognizer.numberOfTapsRequired = 1;
        tapGestureRecognizer.enabled = YES;
        [self addGestureRecognizer:tapGestureRecognizer];
    }
    return self;
}

- (void)triggerDismiss {
    [self removeFromSuperview];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
