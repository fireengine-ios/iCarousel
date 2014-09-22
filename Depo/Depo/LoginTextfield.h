//
//  LoginTextfield.h
//  Depo
//
//  Created by mahir tarlan
//  Copyright (c) 2013 igones. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginTextfield : UITextField

- (id)initWithFrame:(CGRect)frame withPlaceholder:(NSString *) placeholderText;
- (id)initSecureWithFrame:(CGRect)frame withPlaceholder:(NSString *) placeholderText;

@end
