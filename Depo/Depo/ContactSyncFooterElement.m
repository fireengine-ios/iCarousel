//
//  ContactSyncFooterElement.m
//  Depo
//
//  Created by Turan Yilmaz on 27/03/2017.
//  Copyright © 2017 com.igones. All rights reserved.
//

#import "ContactSyncFooterElement.h"
#import "CustomLabel.h"
#import "AppConstants.h"
#import "Util.h"

@implementation ContactSyncFooterElement

- (id) initWithFrame:(CGRect)frame withTitle:(NSString *) title {
    if (self = [super initWithFrame:frame]) {
        
        CustomLabel *titleLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, (IS_IPHONE_6P_OR_HIGHER ? 60 : 50)) withFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:(IS_IPHONE_6P_OR_HIGHER ? 18 : 14)] withColor:[Util UIColorForHexColor:@"3fb0e8"] withText:title withAlignment:NSTextAlignmentCenter numberOfLines:2];
//        titleLabel.adjustsFontSizeToFitWidth = YES;
        titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        [self addSubview:titleLabel];
        
        UIView *separator = [[UIView alloc] initWithFrame:CGRectMake((frame.size.width - 74)/2, titleLabel.frame.size.height, 74, 1)];
        separator.backgroundColor = [Util UIColorForHexColor:@"D4D4D4"];
        [self addSubview:separator];
        
        self.countLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(0, separator.frame.origin.y + 10, frame.size.width, 20) withFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:(IS_IPHONE_6P_OR_HIGHER ? 22 : 18)] withColor:[Util UIColorForHexColor:@"363e4f"] withText:@"0" withAlignment:NSTextAlignmentCenter];
        [self addSubview:self.countLabel];
    }
    return self;
}

@end
