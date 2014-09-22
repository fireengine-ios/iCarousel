//
//  MenuProfileCell.m
//  Depo
//
//  Created by Mahir on 9/18/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "MenuProfileCell.h"
#import "AppDelegate.h"
#import "AppSession.h"
#import "User.h"
#import "CustomLabel.h"
#import "Util.h"

@implementation MenuProfileCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        UIImage *profileBgImg = [UIImage imageNamed:@"profile_bg.png"];

        UIImageView *profileBgView = [[UIImageView alloc] initWithFrame:CGRectMake(15, (60 - profileBgImg.size.height)/2, profileBgImg.size.width, profileBgImg.size.height)];
        profileBgView.image = profileBgImg;
        [self addSubview:profileBgView];

        UIImage *profileImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:APPDELEGATE.session.user.profileImgUrl]]];
        UIImageView *profileImgView = [[UIImageView alloc] initWithFrame:CGRectMake(17, (60 - profileBgImg.size.height - 2)/2, profileBgImg.size.width - 4, profileBgImg.size.height - 4)];
        profileImgView.image = [Util circularScaleNCrop:profileImage forRect:CGRectMake(0, 0, 44, 44)];
        profileImgView.center = profileBgView.center;
        [self addSubview:profileImgView];

        int nameWidth = self.frame.size.width - profileBgView.frame.origin.x - profileBgView.frame.size.width - 15;
        UIFont *nameFont = [UIFont fontWithName:@"TurkcellSaturaDem" size:18];
        
        int nameHeight =  [Util calculateHeightForText:APPDELEGATE.session.user.fullName forWidth:nameWidth forFont:nameFont] + 5;
        if(nameHeight > 60) {
            nameHeight = 60;
        }
        
        CGRect nameFieldRect = CGRectMake(profileBgView.frame.origin.x + profileBgView.frame.size.width + 15, (60 - nameHeight)/2, nameWidth, nameHeight);
        
        CustomLabel *nameLabel = [[CustomLabel alloc] initWithFrame:nameFieldRect withFont:nameFont withColor:[Util UIColorForHexColor:@"FFFFFF"] withText:APPDELEGATE.session.user.fullName];
        [self addSubview:nameLabel];
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
