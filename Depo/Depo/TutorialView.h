//
//  TutorialView.h
//  Depo
//
//  Created by Mahir Tarlan on 17/04/16.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CheckButton.h"
#import "CustomLabel.h"

@interface TutorialView : UIView

@property (nonatomic, strong) CheckButton *checkButton;

- (id) initWithFrame:(CGRect)frame withBgImageName:(NSString *) imgName withTitle:(NSString *) titleVal withKey:(NSString *) keyVal;
- (id) initWithFrame:(CGRect)frame withBgImageName:(NSString *) imgName withTitle:(NSString *) titleVal withKey:(NSString *) keyVal doNotShowFlag:(BOOL) doNotShowFlag;

@end
