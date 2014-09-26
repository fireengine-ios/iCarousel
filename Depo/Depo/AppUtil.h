//
//  AppUtil.h
//  Depo
//
//  Created by Mahir on 9/18/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppConstants.h"

@interface AppUtil : NSObject

+ (NSArray *) readMenuItemsForLoggedIn;
+ (NSString *) iconNameByContentType:(ContentType) contentType;
+ (NSString *) nakedFileFolderName:(NSString *) fileFolderName;
+ (NSString *) buttonImgNameByAddType:(AddType) addType;
+ (NSString *) buttonTitleByAddType:(AddType) addType;
+ (NSString *) moreMenuRowImgNameByMoreMenuType:(MoreMenuType) menuType;
+ (NSString *) moreMenuRowTitleByMoreMenuType:(MoreMenuType) menuType;

@end
