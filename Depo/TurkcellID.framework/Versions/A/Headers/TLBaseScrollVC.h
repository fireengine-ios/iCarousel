//
//  TLBaseScrollVC.h
//  TurkcellID
//
//  Created by Kerem Gunduz on 01/04/15.
//  Copyright (c) 2015 Turkcell. All rights reserved.
//

#import "TLBaseVC.h"

@interface TLBaseScrollVC : TLBaseVC <UIScrollViewDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (assign, nonatomic) BOOL keyboardHandlingEnabled;
@property (weak, nonatomic) UIView    *viewToShowWhenKeyboardIsVisible;

@property (nonatomic, strong) UIDynamicAnimator *animator;
- (void)viewTapped;
@end
