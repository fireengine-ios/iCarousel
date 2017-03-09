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

@interface ContactSyncResultCell () {
    CustomLabel *rowTitleLabel;
    CustomLabel *clientValLabel;
    CustomLabel *serverValLabel;
    CustomLabel *titleLabel;
    CustomLabel *valLabel;
}
@end

@implementation ContactSyncResultCell

- (id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withTitle:(NSString *) titleVal withClientVal:(int) clientVal withServerVal:(int) serverVal {
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor whiteColor];
        
        rowTitleLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(20, 15, 140, 20) withFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:16] withColor:[Util UIColorForHexColor:@"363e4f"] withText:titleVal withAlignment:NSTextAlignmentLeft];
        [self addSubview:rowTitleLabel];

        NSString *clientValStr = @"";
        NSString *serverValStr = @"";
        if(APPDELEGATE.session.syncResult != nil) {
            clientValStr = [NSString stringWithFormat:@"%d", clientVal];
            serverValStr = [NSString stringWithFormat:@"%d", serverVal];
        }
        
        clientValLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(160, 15, 80, 20) withFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:16] withColor:[Util UIColorForHexColor:@"888888"] withText:clientValStr withAlignment:NSTextAlignmentCenter];
        [self addSubview:clientValLabel];

        serverValLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(240, 15, 80, 20) withFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:16] withColor:[Util UIColorForHexColor:@"888888"] withText:serverValStr withAlignment:NSTextAlignmentCenter];
        [self addSubview:serverValLabel];

    }
    return self;
}

- (id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withTitle:(NSString *) titleVal withVal:(int) val isBold:(BOOL)isBold {
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor whiteColor];
        
        if (isBold) {
            titleLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(20, 10, 140, 20) withFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:17] withColor:[Util UIColorForHexColor:@"363e4f"] withText:titleVal withAlignment:NSTextAlignmentLeft];
            [self addSubview:titleLabel];
        } else {
            titleLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(20, 10, 140, 20) withFont:[UIFont fontWithName:@"TurkcellSaturaMed" size:16] withColor:[Util UIColorForHexColor:@"363e4f"] withText:titleVal withAlignment:NSTextAlignmentLeft];
            [self addSubview:titleLabel];
        }
        
        NSString *valStr = @"";
        if(APPDELEGATE.session.syncResult != nil) {
            valStr = [NSString stringWithFormat:@"%d", val];
        }
        
        if (isBold) {
            valLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(160, 15, 160, 20) withFont:[UIFont fontWithName:@"TurkcellSaturaRegBol" size:17] withColor:[Util UIColorForHexColor:@"888888"] withText:valStr withAlignment:NSTextAlignmentCenter];
            [self addSubview:valLabel];
        } else {
            valLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(160, 15, 160, 20) withFont:[UIFont fontWithName:@"TurkcellSaturaRegMed" size:16] withColor:[Util UIColorForHexColor:@"888888"] withText:valStr withAlignment:NSTextAlignmentCenter];
            [self addSubview:valLabel];
        }
    }
    return self;
}

- (void) layoutSubviews {
    rowTitleLabel.frame = CGRectMake(IS_IPAD ? 50 : 20, (self.frame.size.height-20)/2 + 5, 140, 20);
    clientValLabel.frame = CGRectMake(self.frame.size.width/2, (self.frame.size.height-20)/2 + 5, 80, 20);
    serverValLabel.frame = CGRectMake(self.frame.size.width/2 + 80, (self.frame.size.height-20)/2 + 5, 80, 20);
    
    titleLabel.frame = CGRectMake(IS_IPAD ? 50 : 20, (self.frame.size.height-20)/2, 140, 20);
    valLabel.frame = CGRectMake(self.frame.size.width/2, (self.frame.size.height-20)/2 + 5, 160, 20);
    
    [super layoutSubviews];
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
