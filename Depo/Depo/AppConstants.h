//  Created by mahir tarlan
//  Copyright (c) 2013 igones. All rights reserved.
//

#import <Foundation/Foundation.h>

#define IS_IPHONE_5 ([[UIScreen mainScreen] bounds].size.height == 568.0f)

#define IS_BELOW_7 ([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0)

#define IS_BELOW_6 ([[[UIDevice currentDevice] systemVersion] floatValue] < 6.0)

#define turkcellAuthAppIdTest @"151"
#define turkcellAuthSecretKeyTest @"7dad024c-600e-468b-9bcd-5fb518399d15"

#define BASE_PAGE_URL @"https://m.turkcell.com.tr"

#define LOGGED_IN_NOT_NAME @"LOGGED_IN_NOT_NAME"

#define SILENT_LOGGED_IN_NOT_NAME @"SILENT_LOGGED_IN_NOT_NAME"

#define LOGGED_OUT_NOT_NAME @"LOGGED_OUT_NOT_NAME"

#define FORCE_HOMEPAGE_NOTIFICATION @"FORCE_HOMEPAGE_NOTIFICATION"

#define MENU_SCROLLING_NOTIFICATION @"MENU_SCROLLING_NOTIFICATION"

#define MENU_CLOSED_NOTIFICATION @"MENU_CLOSED_NOTIFICATION"

#define MSISDN_STORE_KEY @"MSISDN_STORE_KEY"

#define PASS_STORE_KEY @"PASS_STORE_KEY"

#define SuppressPerformSelectorLeakWarning(Stuff) \
do { \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"") \
Stuff; \
_Pragma("clang diagnostic pop") \
} while (0)

typedef enum {
	LoginTypeRadius = 0,
	LoginTypeWebSifre
} LoginType;

typedef enum {
	MenuTypeProfile = 0,
	MenuTypeSearch,
	MenuTypeHome,
	MenuTypeFav,
	MenuTypeFiles,
	MenuTypePhoto,
	MenuTypeMusic,
	MenuTypeDoc,
	MenuTypeLogin,
	MenuTypeLogout
} MenuType;

typedef enum {
    ModalTypeError = 0,
    ModalTypeWarning,
    ModalTypeSuccess,
    ModalTypeApprove,
    ModalTypeInfo
} ModalType;

@interface AppConstants : NSObject

@end
