//
//  CRYConfiguration.h
//  CropyMain
//
//  Created by Alper KIRDÖK on 03/01/2017.
//  Copyright © 2017 Alper KIRDÖK. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface CRYConfiguration : NSObject

+ (CRYConfiguration *)sharedInstance;

typedef enum {
    SharedTypeURL,
    SharedTypeImage,
    ShareTypeDefault,
} SharedType;

@property (nonatomic, assign) SharedType shareType;

#pragma mark Strings

@property (nonatomic, strong) NSString *headerText;

@property (nonatomic, strong) NSString *origin;

@property (nonatomic, strong) NSString *apiKey;

#pragma mark Background Colors

@property (nonatomic, strong) UIColor *headerColor;

@property (nonatomic, strong) UIColor *tabToolColor;

@property (nonatomic, strong) UIColor *topToolBarColor;

@property (nonatomic, strong) UIColor *headerTitleColor;

@property (nonatomic, strong) UIColor *activeTextColor;

@property (nonatomic, strong) UIColor *passiveTextColor;

@property (nonatomic, strong) UIColor *cropBorderColor;

@property (nonatomic, strong) UIColor *cropHeaderColor;

@property (nonatomic, strong) UIColor *cropHeaderTitleColor;

#pragma mark Modules

@property (nonatomic, assign) BOOL enableHeaderTitle;

@property (nonatomic, assign) BOOL enableCrop;

@property (nonatomic, assign) BOOL enableRotation;

@property (nonatomic, assign) BOOL enableAdjustment;

@property (nonatomic, assign) BOOL enableFilter;

@property (nonatomic, assign) BOOL enableText;

@property (nonatomic, assign) BOOL enableArrow;

@property (nonatomic, assign) BOOL enableLine;

@property (nonatomic, assign) BOOL enablePen;

@property (nonatomic, assign) BOOL enableRectangel;

@property (nonatomic, assign) BOOL enableCircle;

@property (nonatomic, assign) BOOL enableFrame;

@property (nonatomic, assign) BOOL enablePixel;

@property (nonatomic, assign) BOOL enableFocus;

@property (nonatomic, assign) BOOL enableCaps;

@property (nonatomic, assign) BOOL enableShare;

@end
