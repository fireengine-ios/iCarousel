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
        
        CGRect f = self.frame;
        f.size.width = f.size.width + rightPadding;
        
        textLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(20,
                                                                  0,
                                                                  f.size.width - detailLabelWidth - 25,
                                                                  f.size.height)
                                              withFont:[UIFont fontWithName:@"TurkcellSaturaMed" size:17]
                                             withColor:[UIColor blackColor]
                                              withText:@""];
        [self addSubview:textLabel];
        
        detailTextLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(f.size.width - detailLabelWidth,
                                                                        10,
                                                                        detailLabelWidth,
                                                                        f.size.height - 10)
                                                    withFont:[UIFont fontWithName:@"TurkcellSaturaMed" size:17]
//                                                   withColor:[UIColor darkGrayColor]
                                                   withColor:[UIColor colorWithRed:174.0/255.0 green:174.0/255.0 blue:174.0/255.0 alpha:1.0]
                                                    withText:@""];
        [self addSubview:detailTextLabel];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
