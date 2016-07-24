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
#import "UIImageView+AFNetworking.h"
#import "AppUtil.h"

@interface MenuProfileCell() {
    UIImageView *profileBgView;
    UIImageView *profileImgView;
}
@end

@implementation MenuProfileCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withMetaData:(MetaMenu *) _metaData {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.metaData = _metaData;

        UIImage *profileBgImg = [UIImage imageNamed:@"profile_icon.png"];

        profileBgView = [[UIImageView alloc] initWithFrame:CGRectMake(15, (60 - profileBgImg.size.height)/2, profileBgImg.size.width, profileBgImg.size.height)];
        profileBgView.image = profileBgImg;
        [self addSubview:profileBgView];

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul), ^(void) {
            UIImage *profileImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:APPDELEGATE.session.user.profileImgUrl]]];
            APPDELEGATE.session.profileImageRef = profileImage;
            /*
            NSString *imagePath = [AppUtil readDocumentsPathForFileName:AKILLI_DEPO_PROFILE_IMG_NAME];
            NSData *imageData = UIImageJPEGRepresentation(profileImage, 1);
            [imageData writeToFile:imagePath atomically:YES];
             */
            profileImgView = [[UIImageView alloc] initWithFrame:CGRectMake(17, (60 - profileBgImg.size.height - 2)/2, profileBgImg.size.width - 4, profileBgImg.size.height - 4)];
            profileImgView.image = [Util circularScaleNCrop:profileImage forRect:CGRectMake(0, 0, 44, 44)];
            profileImgView.center = profileBgView.center;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self addSubview:profileImgView];
            });
        });

        NSString *infoFieldVal = APPDELEGATE.session.user.username;
        if(APPDELEGATE.session.user.email) {
            infoFieldVal = APPDELEGATE.session.user.email;
        }
        
        int nameWidth = self.frame.size.width - profileBgView.frame.origin.x - profileBgView.frame.size.width - 15;
        UIFont *nameFont = [UIFont fontWithName:@"TurkcellSaturaDem" size:18];
        
        int nameHeight =  [Util calculateHeightForText:infoFieldVal forWidth:nameWidth forFont:nameFont] + 5;
        if(nameHeight > 60) {
            nameHeight = 60;
        }
        
        CGRect nameFieldRect = CGRectMake(profileBgView.frame.origin.x + profileBgView.frame.size.width + 15, (60 - nameHeight)/2, nameWidth, nameHeight);
        
        CustomLabel *nameLabel = [[CustomLabel alloc] initWithFrame:nameFieldRect withFont:nameFont withColor:[Util UIColorForHexColor:@"FFFFFF"] withText:infoFieldVal];
        [self addSubview:nameLabel];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(profileImageUpdated) name:PROFILE_IMG_UPLOADED_NOTIFICATION object:nil];
    }
    return self;
}

- (void) profileImageUpdated {
    profileImgView.image = [Util circularScaleNCrop:APPDELEGATE.session.profileImageRef forRect:CGRectMake(0, 0, 44, 44)];
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
