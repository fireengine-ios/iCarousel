//
//  ChangePassController.h
//  Depo
//
//  Created by Mahir Tarlan on 09/03/16.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import "MyViewController.h"
#import "LoginTextfield.h"

@interface ChangePassController : MyViewController <UIGestureRecognizerDelegate, UITextFieldDelegate>

@property (nonatomic, strong) LoginTextfield *updatedPassField;
@property (nonatomic, strong) LoginTextfield *updatedPassAgainField;

@end
