//
//  ContactSyncResultCell.m
//  Depo
//
//  Created by Mahir on 08/02/15.
//  Copyright (c) 2015 com.igones. All rights reserved.
//

#import "ContactSyncResultCell.h"
#import "CustomLabel.h"
#import "Util.h"
#import "CacheUtil.h"
#import "AppDelegate.h"
#import "AppSession.h"

@implementation ContactSyncResultCell

- (id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withTitle:(NSString *) titleVal withClientVal:(int) clientVal withServerVal:(int) serverVal {
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor whiteColor];
        
        CustomLabel *titleLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(20, 15, 140, 20) withFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:18] withColor:[Util UIColorForHexColor:@"363e4f"] withText:titleVal withAlignment:NSTextAlignmentLeft];
        [self addSubview:titleLabel];

        NSString *clientValStr = @"";
        NSString *serverValStr = @"";
        if(APPDELEGATE.session.syncResult != nil) {
            clientValStr = [NSString stringWithFormat:@"%d", clientVal];
            serverValStr = [NSString stringWithFormat:@"%d", serverVal];
        }
        
        CustomLabel *clientValLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(160, 15, 80, 20) withFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:18] withColor:[Util UIColorForHexColor:@"888888"] withText:clientValStr withAlignment:NSTextAlignmentCenter];
        [self addSubview:clientValLabel];

        CustomLabel *serverValLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(240, 15, 80, 20) withFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:18] withColor:[Util UIColorForHexColor:@"888888"] withText:serverValStr withAlignment:NSTextAlignmentCenter];
        [self addSubview:serverValLabel];

    }
    return self;
}

- (id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withTitle:(NSString *) titleVal withVal:(int) val {
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor whiteColor];
        
        CustomLabel *titleLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(20, 10, 140, 20) withFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:18] withColor:[Util UIColorForHexColor:@"363e4f"] withText:titleVal withAlignment:NSTextAlignmentLeft];
        [self addSubview:titleLabel];
        
        NSString *valStr = @"";
        if(APPDELEGATE.session.syncResult != nil) {
            valStr = [NSString stringWithFormat:@"%d", val];
        }
        
        CustomLabel *valLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(160, 15, 160, 20) withFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:18] withColor:[Util UIColorForHexColor:@"888888"] withText:valStr withAlignment:NSTextAlignmentCenter];
        [self addSubview:valLabel];
        
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
