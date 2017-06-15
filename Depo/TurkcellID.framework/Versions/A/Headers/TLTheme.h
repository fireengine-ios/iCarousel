//
//  TLTheme.h
//  TurkcellID
//
//  Created by Kerem Gunduz on 24/03/15.
//  Copyright (c) 2015. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface TLTheme : NSObject

@property(nonatomic,strong) UIColor * colorTopBarBackground;
@property(nonatomic,strong) UIColor * colorTopBarText;

@property(nonatomic,strong) UIColor * colorLoginBackground;

@property(nonatomic,strong) UIImage * imageTopBarLogo;
@property(nonatomic,strong) UIImage * imageDismissButton;
@property(nonatomic,strong) UIImage * imageBackButton;

@property(nonatomic,strong) UIColor * colorTextFieldBorder;
@property(nonatomic,strong) UIColor * colorTextFieldBackground;
@property(nonatomic,strong) UIColor * colorTextFieldText;

@property(nonatomic,strong) UIImage * imageRememberMeSelected;
@property(nonatomic,strong) UIImage * imageRememberMeNotSelected;

@property(nonatomic,strong) UIColor * colorLabelTouchIDOffer;
@property(nonatomic,strong) UIColor * colorTouchIDOfferBackground;
@property(nonatomic,strong) UIImage * imageTouchIDOfferIcon;
@property(nonatomic,strong) UIColor * colorTouchIDOfferDescription;

@property(nonatomic,strong) UIColor * colorChangePasswordBackground;
@property(nonatomic,strong) UIColor * colorRemembermeOfferBackground;

@property(nonatomic,strong) UIColor* colorPositiveButtonText;
@property(nonatomic,strong) UIColor* colorPositiveButtonHighlightedText;

@property(nonatomic,strong) UIColor* colorNegativeButtonText;
@property(nonatomic,strong) UIColor* colorNegativeButtonHighlightedText;

@property(nonatomic,strong) UIColor* colorPositiveButtonBackground;
@property(nonatomic,strong) UIColor* colorPositiveButtonBackgroundHighlighted;

@property(nonatomic,strong) UIColor* colorNegativeButtonBackground;
@property(nonatomic,strong) UIColor* colorNegativeButtonBackgroundHighlighted;

@property(nonatomic,strong) UIColor* colorPositiveButtonBorder;
@property(nonatomic,strong) UIColor* colorPositiveButtonBorderHighlighted;

@property(nonatomic,strong) UIColor* colorNegativeButtonBorder;
@property(nonatomic,strong) UIColor* colorNegativeButtonBorderHighlighted;

@property(nonatomic,strong) UIColor* colorLabelLoginPageRememberMeText;

@property(nonatomic,strong) UIColor *colorBackgroundRememberMeOffer;

@property(nonatomic,strong) UIFont * fontCommon;

@property(nonatomic,strong) NSString * customButtonTitle;
@end

