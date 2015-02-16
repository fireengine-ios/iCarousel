//
//  EmptyPhotoAlbumCell.m
//  Depo
//
//  Created by Mahir on 10/10/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "EmptyPhotoAlbumCell.h"
#import "AppConstants.h"
#import "CustomLabel.h"
#import "Util.h"

@implementation EmptyPhotoAlbumCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor whiteColor];

        int topIndex = 30;
        if(IS_IPHONE_5) {
            topIndex = 70;
        }

        UIImage *noContentImg = [UIImage imageNamed:@"no_album_icon.png"];
        UIImageView *noContentImgView = [[UIImageView alloc] initWithFrame:CGRectMake((self.frame.size.width - noContentImg.size.width)/2, topIndex, noContentImg.size.width, noContentImg.size.height)];
        noContentImgView.image = noContentImg;
        [self addSubview:noContentImgView];

        CustomLabel *titleLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(0, topIndex + 170, self.frame.size.width, 24) withFont:[UIFont fontWithName:@"TurkcellSaturaDem" size:20] withColor:[Util UIColorForHexColor:@"363E4F"] withText:NSLocalizedString(@"NoAlbumMessage", @"")];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:titleLabel];
        
        CustomLabel *descLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(30, topIndex + 196, self.frame.size.width - 60, 44) withFont:[UIFont fontWithName:@"TurkcellSaturaMed" size:18] withColor:[Util UIColorForHexColor:@"707A8F"] withText:NSLocalizedString(@"NoAlbumSubmessage", @"")];
        descLabel.textAlignment = NSTextAlignmentCenter;
        descLabel.numberOfLines = 2;
        [self addSubview:descLabel];

        
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
