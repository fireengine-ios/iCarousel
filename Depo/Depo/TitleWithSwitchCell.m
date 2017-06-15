//
//  TitleWithSwitchCell.m
//  Depo
//
//  Created by Mahir Tarlan on 21/07/16.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import "TitleWithSwitchCell.h"
#import "Util.h"
#import "AppConstants.h"

@implementation TitleWithSwitchCell

@synthesize delegate;
@synthesize onOffswitch;
@synthesize switchKey;
@synthesize titleLabel;
@synthesize iconImageView;
@synthesize rowIndex;

- (id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withIcon:(NSString *) iconVal withTitle:(NSString *) titleVal withSwitchKey:(NSString *) switchKeyVal withIndex:(int) indexVal {
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;

        self.switchKey = switchKeyVal;
        self.rowIndex = indexVal;
        
        iconImageView = [[UIImageView alloc]initWithFrame:CGRectMake(15, (self.frame.size.height-30)/2, 29, 29)];
        iconImageView.contentMode = UIViewContentModeScaleAspectFit;
        iconImageView.image = [UIImage imageNamed:iconVal];
        [self addSubview:iconImageView];

        titleLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(55, (self.frame.size.height - 20)/2, self.frame.size.width - 125, 20) withFont:[UIFont fontWithName:@"TurkcellSaturaDem" size:18] withColor:[Util UIColorForHexColor:@"292F3E"] withText:titleVal];
        [self addSubview:titleLabel];
        
        onOffswitch = [[UISwitch alloc] initWithFrame:CGRectMake(self.frame.size.width - 70, (self.frame.size.height - 30)/2, 50, 30)];
        onOffswitch.on = [[NSUserDefaults standardUserDefaults] boolForKey:switchKeyVal];
        [onOffswitch addTarget:self action:@selector(switchChanged) forControlEvents:UIControlEventValueChanged];
        [self addSubview:onOffswitch];
        
        if([self.switchKey isEqualToString:FB_AUTO_SYNC_SWITCH_KEY]) {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fbErrorOnStart) name:FB_AUTO_SYNC_STOP_ERR_NOT_KEY object:nil];
        }
    }
    return self;
}

- (void) fbErrorOnStart {
    onOffswitch.on = NO;
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:self.switchKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void) layoutSubviews {
    [super layoutSubviews];
    
    iconImageView.frame = CGRectMake(15, (self.frame.size.height-30)/2, 29, 29);
    titleLabel.frame = CGRectMake(55, (self.frame.size.height - 20)/2, self.frame.size.width - 125, 20);
    onOffswitch.frame = CGRectMake(self.frame.size.width - 70, (self.frame.size.height - 30)/2, 50, 30);
}

- (void) switchChanged {
    [delegate titleWithSwitchValueChanged:onOffswitch.isOn forKey:self.switchKey];
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    if(selected) {
//        [self.onOffswitch setOn:YES];
//        [delegate titleWithSwitchValueChanged:YES forKey:self.switchKey];
    } else {
//        [self.onOffswitch setOn:NO];
//        [delegate titleWithSwitchValueChanged:NO forKey:self.switchKey];
    }
}

@end
