//
//  CustomInfoWithIconView.h
//  Depo
//
//  Created by Mahir Tarlan on 08/09/16.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Util.h"
#import "CustomButton.h"
#import "SimpleButton.h"

@protocol CustomInfoWithIconDelegate <NSObject>
- (void) customInfoWithIconViewDidDismiss;
@end

@interface CustomInfoWithIconView : UIView

@property (nonatomic, weak) id<CustomInfoWithIconDelegate> delegate;
@property (nonatomic, strong) UIView *modalView;

- (id) initWithFrame:(CGRect) frame withIcon:(NSString *) iconName withInfo:(NSString *) infoVal withSubInfo:(NSString *) subInfoVal isCloseable:(BOOL) closableFlag;

@end
