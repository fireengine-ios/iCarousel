//
//  CustomAdvertisementView.h
//  Depo
//
//  Created by Gürhan KODALAK on 13/08/15.
//  Copyright (c) 2015 com.igones. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CustomAdvertisementDelegate <NSObject>

- (void) advertisementViewYesClick;
- (void) advertisementViewNoClick;
- (void) advertisementViewOkClick;

@optional
- (void) advertisementViewOkClickWhenFull;

@end

@interface CustomAdvertisementView : UIView

@property (nonatomic, strong) id<CustomAdvertisementDelegate> delegate;

- (id) initWithFrame:(CGRect)frame withMessage:(NSString *) message withBooleanOption:(BOOL) option withTitle:(NSString *) title;
- (id) initWithFrame:(CGRect)frame withMessage:(NSString *)message withFullPackage:(BOOL) isFull withTitle:(NSString *) title;

@end
