//
//  ContactSyncResultTitleCell.m
//  Depo
//
//  Created by Mahir on 08/02/15.
//  Copyright (c) 2015 com.igones. All rights reserved.
//

#import "ContactSyncResultTitleCell.h"
#import "CustomLabel.h"
#import "Util.h"

@implementation ContactSyncResultTitleCell

- (id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor whiteColor];
        
        CustomLabel *clientTitleLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(160, 10, 80, 20) withFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:18] withColor:[Util UIColorForHexColor:@"363e4f"] withText:NSLocalizedString(@"ContactLastSyncDetailClientTitle", @"") withAlignment:NSTextAlignmentCenter];
        [self addSubview:clientTitleLabel];
        
        CustomLabel *serverTitleLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(240, 10, 80, 20) withFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:18] withColor:[Util UIColorForHexColor:@"363e4f"] withText:NSLocalizedString(@"ContactLastSyncDetailServerTitle", @"") withAlignment:NSTextAlignmentCenter];
        [self addSubview:serverTitleLabel];
        
    }
    return self;
}

- (id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withTitle:(NSString *) titleVal {
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor whiteColor];
        
        CustomLabel *titleLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(160, 10, 160, 20) withFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:18] withColor:[Util UIColorForHexColor:@"363e4f"] withText:titleVal withAlignment:NSTextAlignmentCenter];
        [self addSubview:titleLabel];
    }
    return self;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
