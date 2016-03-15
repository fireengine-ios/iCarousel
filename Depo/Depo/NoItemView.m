//
//  NoItemView.m
//  Depo
//
//  Created by Mahir Tarlan on 15/03/16.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import "NoItemView.h"
#import "AppConstants.h"
#import "CustomLabel.h"
#import "Util.h"

@implementation NoItemView

- (id)initWithFrame:(CGRect)frame imageName:(NSString *)imageName titleText:(NSString *)titleText descriptionText:(NSString *)descriptionText {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        int topIndex = IS_IPHONE_5 ? 70 : 30;
        if ([descriptionText isEqualToString:@""])
            topIndex += 25;
        
        if(IS_IPAD)
            topIndex += 100;
        
        UIImage *noContentImg = [UIImage imageNamed:imageName];
        UIImageView *noContentImgView = [[UIImageView alloc] initWithFrame:CGRectMake((self.frame.size.width - noContentImg.size.width)/2, topIndex, noContentImg.size.width, noContentImg.size.height)];
        noContentImgView.image = noContentImg;
        [self addSubview:noContentImgView];
        
        //        CustomLabel *titleLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(0, topIndex + 170, self.frame.size.width, 24) withFont:[UIFont fontWithName:@"TurkcellSaturaDem" size:20] withColor:[Util UIColorForHexColor:@"363E4F"] withText:NSLocalizedString(@"NoAlbumMessage", @"")];
        CustomLabel *titleLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(0, topIndex + 170, self.frame.size.width, 24) withFont:[UIFont fontWithName:@"TurkcellSaturaDem" size:20] withColor:[Util UIColorForHexColor:@"363E4F"] withText:titleText];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:titleLabel];
        
        //        CustomLabel *descLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(30, topIndex + 196, self.frame.size.width - 60, 44) withFont:[UIFont fontWithName:@"TurkcellSaturaMed" size:18] withColor:[Util UIColorForHexColor:@"707A8F"] withText:NSLocalizedString(@"NoAlbumSubmessage", @"")];
        CustomLabel *descLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(30, topIndex + 196, self.frame.size.width - 60, 44) withFont:[UIFont fontWithName:@"TurkcellSaturaMed" size:18] withColor:[Util UIColorForHexColor:@"707A8F"] withText:descriptionText];
        descLabel.textAlignment = NSTextAlignmentCenter;
        descLabel.numberOfLines = 2;
        [self addSubview:descLabel];
    }
    return self;
}

@end
