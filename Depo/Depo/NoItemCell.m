//
//  NoItemCell.m
//  Depo
//
//  Created by Salıh Topcu on 16.02.2015.
//  Copyright (c) 2015 com.igones. All rights reserved.
//

#import "NoItemCell.h"
#import "AppConstants.h"
#import "CustomLabel.h"
#import "Util.h"

@interface NoItemCell () {
    UIImageView *noContentImgView;
    CustomLabel *titleLabel;
    CustomLabel *descLabel;
    NSString *descriptionTextRef;
}
@end

@implementation NoItemCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier imageName:(NSString *)imageName titleText:(NSString *)titleText descriptionText:(NSString *)descriptionText {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor whiteColor];

        descriptionTextRef = descriptionText;

        int topIndex = IS_IPHONE_5 ? 70 : 30;
        if ([descriptionText isEqualToString:@""])
            topIndex += 25;

        if(IS_IPAD)
            topIndex += 100;

        UIImage *noContentImg = [UIImage imageNamed:imageName];
        noContentImgView = [[UIImageView alloc] initWithFrame:CGRectMake((self.frame.size.width - noContentImg.size.width)/2, topIndex, noContentImg.size.width, noContentImg.size.height)];
        noContentImgView.image = noContentImg;
        [self addSubview:noContentImgView];

//        CustomLabel *titleLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(0, topIndex + 170, self.frame.size.width, 24) withFont:[UIFont fontWithName:@"TurkcellSaturaDem" size:20] withColor:[Util UIColorForHexColor:@"363E4F"] withText:NSLocalizedString(@"NoAlbumMessage", @"")];
        titleLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(0, topIndex + 170, self.frame.size.width, 24) withFont:[UIFont fontWithName:@"TurkcellSaturaDem" size:20] withColor:[Util UIColorForHexColor:@"363E4F"] withText:titleText];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:titleLabel];
        
//        CustomLabel *descLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(30, topIndex + 196, self.frame.size.width - 60, 44) withFont:[UIFont fontWithName:@"TurkcellSaturaMed" size:18] withColor:[Util UIColorForHexColor:@"707A8F"] withText:NSLocalizedString(@"NoAlbumSubmessage", @"")];
        descLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(30, topIndex + 196, self.frame.size.width - 60, 44) withFont:[UIFont fontWithName:@"TurkcellSaturaMed" size:18] withColor:[Util UIColorForHexColor:@"707A8F"] withText:descriptionText];
        descLabel.textAlignment = NSTextAlignmentCenter;
        descLabel.numberOfLines = 2;
        [self addSubview:descLabel];
    }
    return self;
}

- (void) layoutSubviews {
    noContentImgView.frame = CGRectMake((self.frame.size.width - noContentImgView.frame.size.width)/2, noContentImgView.frame.origin.y, noContentImgView.frame.size.width, noContentImgView.frame.size.height);
    titleLabel.frame = CGRectMake((self.frame.size.width - 320)/2, noContentImgView.frame.origin.y + noContentImgView.frame.size.height + 40, 320, 24);
    descLabel.frame = CGRectMake((self.frame.size.width - 260)/2, titleLabel.frame.origin.y + titleLabel.frame.size.height + 2, 260, 44);
}

@end
