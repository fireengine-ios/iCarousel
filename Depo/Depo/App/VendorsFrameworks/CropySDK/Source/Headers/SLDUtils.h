//
//  SLDUtils.h
//  SOLID
//
//  Created by Alper KIRDÖK on 9/13/15.
//  Copyright (c) 2015 Alper KIRDÖK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"
#import "CRYMBProgressHUD.h"
#import "CropyConstants.h"
//#import "UIImageView+WebCache.h"

@interface SLDUtils : NSObject

@property (nonatomic, strong) CRYMBProgressHUD *progressHUD;
@property (nonatomic, strong) NSString *baseURL;
@property (nonatomic, strong) NSString *headerKey;

+ (SLDUtils *)sharedInstance;

//+ (AppDelegate *)getAppDelegate;
- (void)showHud:(NSString *)text view:(UIView *)view;
- (void)hideHud;
//- (void)informWithAlertViewWithTitle:(NSString *)title andMessage:(NSString *)message;
+ (AFHTTPSessionManager *) getSessionManager;
+ (AFHTTPSessionManager *) getJsonSessiontManager;
- (NSString *)appendUrlToBase:(NSString *)url;
+ (CGFloat)getScreenHeight;
+ (CGFloat)getScreenWidth;
+ (UIImage *)scaleImage:(UIImage *)sourceImage scaledToWidth:(float)i_width;
+ (void)logScreen:(NSString *)str;
+ (void)saveNSUserDefaults:(id)object key:(NSString *)key;
- (UIToolbar *)getOkeyButton:(UIViewController *)viewController;
- (void)closeKeyboard:(UIBarButtonItem *)sender;
+ (BOOL) validateUrl: (NSString *) candidate;
+ (CGSize)getCalculateLabelSizeMethod:(NSString *)text font:(UIFont *)font sizeMake:(CGSize)sizeMake;
+ (UIImage *)scaleImage:(UIImage *)sourceImage scaledToHeight:(float)i_height;

//Calculate Date Methods
+ (NSString *)getDateFromSecondSince1970:(NSString *)second dateFormat:(NSString *)dateFormat;
+ (NSDate *)getDateFormatFromString:(NSString *)stringDate dateFormat:(NSString *)dateFormat;
+ (NSString *)getStringDateFromDateFormat:(NSDate *)date dateFormat:(NSString *)dateFormat;
+ (NSString *)getTurkishMounthName:(int)mounth;
+ (int)getDayOfMounth:(NSDate *)date dateFormat:(NSString *)dateFormat;
+ (int)getMounthOfYear:(NSDate *)date dateFormat:(NSString *)dateFormat;
+ (int)getYearFromDate:(NSDate *)date dateFormat:(NSString *)dateFormat;

//Validation Email
+ (BOOL)isValidEmail:(NSString *)checkEmail;
+ (BOOL)isDeviceIPhone;

+ (NSString *) platformString;

+ (void)showPopup:(UIViewController *)viewController title:(NSString *) title message:(NSString*)message buttonTitle:(NSString *)buttontitle staticButtonText:(NSString *)staticButtonText type:(int)type localized:(BOOL)localized;

@end
