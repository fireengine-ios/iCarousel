//
//  AddTypeButton.h
//  Depo
//
//  Created by Mahir on 9/25/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppConstants.h"

@interface AddTypeButton : UIButton

@property (nonatomic) AddType addType;

- (id)initWithFrame:(CGRect)frame withAddType:(AddType) type;

@end
