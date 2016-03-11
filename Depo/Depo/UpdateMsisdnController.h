//
//  UpdateMsisdnController.h
//  Depo
//
//  Created by Mahir Tarlan on 10/03/16.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import "MyViewController.h"
#import "LoginTextfield.h"

@interface UpdateMsisdnController : MyViewController <UIGestureRecognizerDelegate, UITextFieldDelegate>

@property (nonatomic, strong) LoginTextfield *updatedNumberField;

@end
