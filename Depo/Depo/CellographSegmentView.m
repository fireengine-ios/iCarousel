//
//  CellographSegmentView.m
//  Depo
//
//  Created by Mahir Tarlan on 18/07/16.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import "CellographSegmentView.h"
#import "Util.h"
#import "AppConstants.h"

@implementation CellographSegmentView

@synthesize delegate;
@synthesize currentButton;
@synthesize historyButton;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [Util UIColorForHexColor:@"3FB0E8"];
        
        CGRect currentButtonRect = CGRectMake(10, (self.frame.size.height - 24)/2, 150, 24);
        CGRect historyButtonRect = CGRectMake(160, (self.frame.size.height - 24)/2, 150, 24);
        
        if(IS_IPAD) {
            currentButtonRect = CGRectMake(30, (self.frame.size.height - 24)/2, self.frame.size.width/2-30, 24);
            historyButtonRect = CGRectMake(self.frame.size.width/2, (self.frame.size.height - 24)/2, self.frame.size.width/2-30, 24);
        }
        
        currentButton = [[SimpleButton alloc] initWithFrame:currentButtonRect withTitle:NSLocalizedString(@"CellographCurrent", @"") withTitleColor:[UIColor whiteColor] withTitleFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:17] isUnderline:NO withUnderlineColor:nil];
        [currentButton addTarget:self action:@selector(currentClicked) forControlEvents:UIControlEventTouchUpInside];
        currentButton.isAccessibilityElement = YES;
        currentButton.accessibilityIdentifier = @"currentButtonCellograph";
        [self addSubview:currentButton];

        historyButton = [[SimpleButton alloc] initWithFrame:historyButtonRect withTitle:NSLocalizedString(@"CellographHistory", @"") withTitleColor:[UIColor whiteColor] withTitleFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:17] isUnderline:NO withUnderlineColor:nil];
        [historyButton addTarget:self action:@selector(historyClicked) forControlEvents:UIControlEventTouchUpInside];
        historyButton.isAccessibilityElement = YES;
        historyButton.accessibilityIdentifier = @"historyButtonCellograph";
        [self addSubview:historyButton];

        UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(self.frame.size.width/2-0.25f, 0, 0.5, self.frame.size.height)];
        separator.backgroundColor = [UIColor whiteColor];
        [self addSubview:separator];
        
    }
    return self;
}

- (void) currentClicked {
//    [currentButton changeTextColor:[Util UIColorForHexColor:@"FFFFFF"]];
//    [historyButton changeTextColor:[Util UIColorForHexColor:@"3FB0E8"]];
    
    [delegate cellographHeaderDidSelectCurrent];
}

- (void) historyClicked {
//    [currentButton changeTextColor:[Util UIColorForHexColor:@"3FB0E8"]];
//    [historyButton changeTextColor:[Util UIColorForHexColor:@"FFFFFF"]];
    
    [delegate cellographHeaderDidSelectHistory];
}

@end
