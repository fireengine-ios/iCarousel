//
//  CustomEntryPopupView.m
//  Depo
//
//  Created by Mahir Tarlan on 05/07/16.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import "CustomEntryPopupView.h"
#import "CustomButton.h"
#import "Util.h"
#import "CustomLabel.h"

@implementation CustomEntryPopupView

@synthesize delegate;
@synthesize field;
@synthesize modalView;

- (id) initWithFrame:(CGRect)frame withTitle:(NSString *) titleVal withButtonTitle:(NSString *) buttonTitleVal {
    if(self = [super initWithFrame:frame]) {
        UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        bgView.backgroundColor = [UIColor blackColor];
        bgView.alpha = 0.7;
        [self addSubview:bgView];
        
        int modalHeight = 200;
        
        modalView = [[UIView alloc] initWithFrame:CGRectMake((self.frame.size.width - 280)/2, (self.frame.size.height - modalHeight)/2, 280, modalHeight)];
        modalView.backgroundColor = [UIColor whiteColor];

        CustomLabel *titleLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(0, 20, modalView.frame.size.width, 20) withFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:20] withColor:[Util UIColorForHexColor:@"3D3D3D"] withText:titleVal withAlignment:NSTextAlignmentCenter];
        [modalView addSubview:titleLabel];

        field = [[GeneralTextField alloc] initWithFrame:CGRectMake(20, 60, modalView.frame.size.width - 40, 43) withPlaceholder:@""];
        field.delegate = self;
        [modalView addSubview:field];

        CGSize buttonSize = CGSizeMake(240, 50);
        CustomButton *okButton = [[CustomButton alloc] initWithFrame:CGRectMake((modalView.frame.size.width - buttonSize.width)/2, field.frame.origin.y + field.frame.size.height + 20, buttonSize.width, buttonSize.height) withImageName:@"buttonbg_yellow.png" withTitle:buttonTitleVal withFont:[UIFont fontWithName:@"TurkcellSaturaDem" size:16] withColor:[Util UIColorForHexColor:@"363e4f"]];
        [okButton addTarget:self action:@selector(triggerOk) forControlEvents:UIControlEventTouchUpInside];
        [modalView addSubview:okButton];

        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(triggerResign)];
        tapGestureRecognizer.numberOfTapsRequired = 1;
        tapGestureRecognizer.enabled = YES;
        tapGestureRecognizer.delegate = self;
        [self addGestureRecognizer:tapGestureRecognizer];
        
        [self addSubview:modalView];
    }
    return self;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([touch.view isDescendantOfView:field] || [touch.view isKindOfClass:[UIControl class]]) {
        return NO;
    }
    return YES;
}

- (void) triggerResign {
    [field resignFirstResponder];
}

- (void) triggerOk {
    if([field.text length] > 0) {
        [delegate customEntryDidDismissWithValue:field.text];
        [self removeFromSuperview];
    }
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField {
    [field resignFirstResponder];
    return YES;
}

@end
