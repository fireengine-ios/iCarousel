//
//  CountrySelectionCell.m
//  Depo
//
//  Created by RDC on 16/03/2017.
//  Copyright © 2017 com.igones. All rights reserved.
//

#import "CountrySelectionCell.h"

#define detailLabelWidth 60.0f
#define rightPadding 40.0f

@implementation CountrySelectionCell

@synthesize textLabel;
@synthesize detailTextLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        CGRect f = self.frame;
        f.size.width = f.size.width + rightPadding;
        
        textLabel = [[CustomLabel alloc] initWithFrame:[self getFrameForTextLabel]
//                                              withFont:[UIFont fontWithName:@"TurkcellSaturaMed" size:17]
                                              withFont:[UIFont systemFontOfSize:17]
                                             withColor:[UIColor blackColor]
                                              withText:@""];
        [self addSubview:textLabel];
        
        detailTextLabel = [[CustomLabel alloc] initWithFrame:[self getFrameForDetailTextLabel]
//                                                    withFont:[UIFont fontWithName:@"TurkcellSaturaMed" size:17]
                                                    withFont:[UIFont systemFontOfSize:17]
//                                                   withColor:[UIColor darkGrayColor]
                                                   withColor:[UIColor colorWithRed:174.0/255.0 green:174.0/255.0 blue:174.0/255.0 alpha:1.0]
                                                    withText:@""];
        [self addSubview:detailTextLabel];
    }
    return self;
}

- (CGRect)getFrameForTextLabel {
    return CGRectMake(20,
                      0,
                      self.frame.size.width - detailLabelWidth -20 -5 -20,
                      self.frame.size.height);
}

- (CGRect)getFrameForDetailTextLabel {
    return CGRectMake(self.frame.size.width - detailLabelWidth - 20,
               10,
               detailLabelWidth,
               self.frame.size.height - 10);
}

- (void) addGreenTickIcon {
    self.tickImageV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_selected.png"]];
    self.tickImageV.frame = CGRectMake(self.detailTextLabel.frame.origin.x - 30,
                                  10,
                                  25,
                                  25);
    [self addSubview:self.tickImageV];
}

- (void) removeGreenTickIcon {
    self.tickImageV.hidden = YES;
    [self.tickImageV removeFromSuperview];
    self.tickImageV = nil;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    if (selected) {
        [self addGreenTickIcon];
    } else {
        [self removeGreenTickIcon];
        
        // update frames
        self.textLabel.frame = [self getFrameForTextLabel];
        self.detailTextLabel.frame = [self getFrameForDetailTextLabel];
    }
}

@end
