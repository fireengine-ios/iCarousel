//
//  RecentSearchCell.m
//  Depo
//
//  Created by NCO on 24/11/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "RecentSearchCell.h"
#import "Util.h"

@implementation RecentSearchCell

- (id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withHistory:(SearchHistory *)history {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        int left = 20;
        
        if (history.type.length > 0 &&
            ([history.type isEqualToString:@"TIME"] ||
             [history.type isEqualToString:@"LOCATION"] ||
             [history.type isEqualToString:@"CATEGORY"])) {
            UIImage *iconImg = [UIImage imageNamed:@"icon_calendar"];
            if ([history.type isEqualToString:@"LOCATION"]) {
                iconImg = [UIImage imageNamed:@"icon_location"];
            }
            if ([history.type isEqualToString:@"CATEGORY"]) {
                iconImg = [UIImage imageNamed:@"icon_bottom_sync_purple"];
            }
            UIImageView* imageView = [[UIImageView alloc] initWithFrame:CGRectMake(left, 7, iconImg.size.width, iconImg.size.height)];
            imageView.image = iconImg;
            [self addSubview:imageView];
            left += 30;
        }
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(left, 11, 280, 20)];
        
        NSString *highLightedText = history.searchText;
        
        NSRange r1 = [highLightedText rangeOfString:@"<m>"];
        NSRange r2 = [highLightedText rangeOfString:@"</m>"];
        NSRange rSub = NSMakeRange(r1.location + r1.length, r2.location - r1.location - r1.length);
        NSString *sub = @"";
        if (rSub.location != NSNotFound) {
            
            sub = [highLightedText substringWithRange:rSub];
            highLightedText = [highLightedText stringByReplacingOccurrencesOfString:@"<m>" withString:@""];
            highLightedText = [highLightedText stringByReplacingOccurrencesOfString:@"</m>" withString:@""];
        }
        if (highLightedText != nil) {
            NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:highLightedText];
            [attributedString addAttribute:NSForegroundColorAttributeName
                                     value:[Util UIColorForHexColor:@"292F3E"]
                                     range:NSMakeRange(0, highLightedText.length)];
            
            [attributedString addAttribute:NSForegroundColorAttributeName
                                     value:[Util UIColorForHexColor:@"199cd4"]
                                     range:[highLightedText rangeOfString:sub]];
            
            [attributedString addAttribute:NSFontAttributeName
                                     value:[UIFont fontWithName:@"TurkcellSaturaDem" size:18]
                                     range:NSMakeRange(0, highLightedText.length)];
            titleLabel.attributedText = attributedString;
        }
//        titleLabel.font = [UIFont fontWithName:@"TurkcellSaturaDem" size:18];
//        titleLabel.textColor = [Util UIColorForHexColor:@"292F3E"];
        titleLabel.backgroundColor= [UIColor clearColor];
        [self addSubview:titleLabel];
        
        UIView *greyLine = [[UIView alloc] initWithFrame:CGRectMake(0, 43, 320, 1)];
        greyLine.backgroundColor = [Util UIColorForHexColor:@"E0E2E0"];
        [self addSubview:greyLine];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
