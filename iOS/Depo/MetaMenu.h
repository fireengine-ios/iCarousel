//
//  MetaMenu.h
//  Depo
//
//  Created by mahir tarlan
//  Copyright (c) 2013 igones. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppConstants.h"

@interface MetaMenu : NSObject

@property (nonatomic, strong) NSString *iconName;
@property (nonatomic, strong) NSString *selectedIconName;
@property (nonatomic, strong) NSString *iconUrl;
@property (nonatomic, strong) NSString *selectedIconUrl;
@property (nonatomic, strong) NSString *title;
@property (nonatomic) MenuType menuType;

- (id) initWithMenuType:(MenuType) type;

@end
