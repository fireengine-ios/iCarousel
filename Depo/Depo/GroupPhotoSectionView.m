//
//  GroupPhotoSectionView.m
//  Depo
//
//  Created by Mahir Tarlan on 15/11/16.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import "GroupPhotoSectionView.h"
#import "CustomLabel.h"
#import "Util.h"

@interface GroupPhotoSectionView() {
    CustomLabel *titleLabel;
    CheckButton *checkButton;
}
@end

@implementation GroupPhotoSectionView

@synthesize checkDelegate;

- (void) loadSectionWithTitle:(NSString *) titleVal isSelectible:(BOOL) selectibleFlag isSelected:(BOOL) selectedFlag {
    self.backgroundColor = [UIColor whiteColor];
    if(!titleLabel) {
        titleLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(selectibleFlag ? 50 : 20, 10, (self.frame.size.width-40)/2, 20) withFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:14] withColor:[Util UIColorForHexColor:@"555555"] withText:titleVal];
        titleLabel.adjustsFontSizeToFitWidth = YES;
        [self addSubview:titleLabel];
    } else {
        titleLabel.frame = CGRectMake(selectibleFlag ? 50 : 20, 10, (self.frame.size.width-40)/2, 20);
        titleLabel.text = titleVal;
    }
    
    if(selectibleFlag) {
        if(!checkButton) {
            checkButton = [[CheckButton alloc] initWithFrame:CGRectMake(20, 10, 21, 20) isInitiallyChecked:selectedFlag autoActionFlag:YES];
            checkButton.checkDelegate = self;
            [self addSubview:checkButton];
        } else {
            checkButton.hidden = false;
            if(selectedFlag) {
                [checkButton manuallyCheck];
            } else {
                [checkButton manuallyUncheck];
            }
        }
    } else {
        checkButton.hidden = true;
        [checkButton manuallyUncheck];
    }
}

- (void) checkButtonWasChecked {
    [checkDelegate groupPhotoSectionViewCheckboxChecked:titleLabel.text];
}

- (void) checkButtonWasUnchecked {
    [checkDelegate groupPhotoSectionViewCheckboxUnchecked:titleLabel.text];
}

@end
