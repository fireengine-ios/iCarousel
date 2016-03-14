//
//  UpdateMsisdnController.h
//  Depo
//
//  Created by Mahir Tarlan on 10/03/16.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import "MyViewController.h"
#import "LoginTextfield.h"
#import "UpdateMsisdnDao.h"

@interface UpdateMsisdnController : MyViewController <UIGestureRecognizerDelegate, UITextFieldDelegate> {
    UpdateMsisdnDao *msisdnDao;
}

@property (nonatomic, strong) LoginTextfield *updatedNumberField;

@end
