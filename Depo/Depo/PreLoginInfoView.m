//
//  PreLoginInfoView.m
//  Depo
//
//  Created by Mahir on 10/02/15.
//  Copyright (c) 2015 com.igones. All rights reserved.
//

#import "PreLoginInfoView.h"
#import "CustomLabel.h"
#import "Util.h"

@implementation PreLoginInfoView

- (id) initWithFrame:(CGRect)frame withImageName:(NSString *) imgName withTitleKey:(NSString *) titleKey withInfoKey:(NSString *) infoKey {
    if(self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        
        CustomLabel *titleLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 50) withFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:18] withColor:[UIColor whiteColor] withText:NSLocalizedString(titleKey, @"") withAlignment:NSTextAlignmentCenter numberOfLines:2];
        [self addSubview:titleLabel];
        
        UIImage *bgImg = [UIImage imageNamed:imgName];
        UIImageView *bgImgView = [[UIImageView alloc] initWithFrame:CGRectMake((self.frame.size.width - bgImg.size.width)/2, 50, bgImg.size.width, bgImg.size.height)];
        bgImgView.image = bgImg;
        [self addSubview:bgImgView];

        CustomLabel *infoLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(0, bgImgView.frame.origin.y + bgImgView.frame.size.height, self.frame.size.width, 60) withFont:[UIFont fontWithName:@"TurkcellSaturaMed" size:16] withColor:[UIColor whiteColor] withText:NSLocalizedString(infoKey, @"") withAlignment:NSTextAlignmentCenter numberOfLines:3];
        [self addSubview:infoLabel];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
