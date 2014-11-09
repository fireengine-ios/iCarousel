//
//  MoreMenuCell.m
//  Depo
//
//  Created by Mahir on 9/26/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "MoreMenuCell.h"
#import "CustomLabel.h"
#import "AppUtil.h"
#import "Util.h"

@implementation MoreMenuCell

@synthesize menuType;
@synthesize contentType;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withMenuType:(MoreMenuType) _menuType {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.menuType = _menuType;
        self.backgroundColor = [UIColor whiteColor];

        UIImage *iconImg = [UIImage imageNamed:[AppUtil moreMenuRowImgNameByMoreMenuType:menuType]];
        UIImageView *iconView = [[UIImageView alloc] initWithFrame:CGRectMake(15, (40 - iconImg.size.height)/2, iconImg.size.width, iconImg.size.height)];
        iconView.image = iconImg;
        [self addSubview:iconView];
        
        CGRect nameFieldRect = CGRectMake(50, 14, self.frame.size.width - 60, 22);
        
        UIFont *nameFont = [UIFont fontWithName:@"TurkcellSaturaDem" size:18];
        
        CustomLabel *nameLabel = [[CustomLabel alloc] initWithFrame:nameFieldRect withFont:nameFont withColor:[Util UIColorForHexColor:@"363E4F"] withText:[AppUtil moreMenuRowTitleByMoreMenuType:menuType withContentType:ContentTypeFolder]];
        [self addSubview:nameLabel];
        
        UIView *progressSeparator = [[UIView alloc] initWithFrame:CGRectMake(0, 49, self.frame.size.width, 1)];
        progressSeparator.backgroundColor = [Util UIColorForHexColor:@"E1E1E1"];
        progressSeparator.alpha = 0.5f;
        [self addSubview:progressSeparator];
    }
    return self;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withMenuType:(MoreMenuType) _menuType withFileType:(ContentType) _contentType {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.menuType = _menuType;
        self.contentType = _contentType;
        self.backgroundColor = [UIColor whiteColor];
        
        UIImage *iconImg = [UIImage imageNamed:[AppUtil moreMenuRowImgNameByMoreMenuType:menuType]];
        UIImageView *iconView = [[UIImageView alloc] initWithFrame:CGRectMake(15, (40 - iconImg.size.height)/2, iconImg.size.width, iconImg.size.height)];
        iconView.image = iconImg;
        [self addSubview:iconView];
        
        CGRect nameFieldRect = CGRectMake(50, 14, self.frame.size.width - 60, 22);
        
        UIFont *nameFont = [UIFont fontWithName:@"TurkcellSaturaDem" size:18];
        
        CustomLabel *nameLabel = [[CustomLabel alloc] initWithFrame:nameFieldRect withFont:nameFont withColor:[Util UIColorForHexColor:@"363E4F"] withText:[AppUtil moreMenuRowTitleByMoreMenuType:menuType withContentType:self.contentType]];
        [self addSubview:nameLabel];
        
        UIView *progressSeparator = [[UIView alloc] initWithFrame:CGRectMake(0, 49, self.frame.size.width, 1)];
        progressSeparator.backgroundColor = [Util UIColorForHexColor:@"E1E1E1"];
        progressSeparator.alpha = 0.5f;
        [self addSubview:progressSeparator];
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
