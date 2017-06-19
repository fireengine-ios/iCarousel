//
//  MsisdnEntryController.h
//  Depo
//
//  Created by Mahir Tarlan on 09/03/16.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import "MyViewController.h"
#import "LoginTextfield.h"
#import "UpdateMsisdnDao.h"

@interface MsisdnEntryController : MyViewController <UITextFieldDelegate, UIGestureRecognizerDelegate> {
    UpdateMsisdnDao *msisdnDao;
}

@property (nonatomic, strong) LoginTextfield *msisdnField;

@end
