//
//  MetaMenu.m
//  Depo
//
//  Created by mahir tarlan
//  Copyright (c) 2013 igones. All rights reserved.
//

#import "MetaMenu.h"

@implementation MetaMenu

@synthesize iconName;
@synthesize selectedIconName;
@synthesize iconUrl;
@synthesize selectedIconUrl;
@synthesize title;
@synthesize menuType;

- (id) initWithMenuType:(MenuType) type {
    self = [super init];
    if (self) {
        self.menuType = type;
    }
    return self;
}
@end
