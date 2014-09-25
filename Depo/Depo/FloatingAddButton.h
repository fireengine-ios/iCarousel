//
//  FloatingAddButton.h
//  Depo
//
//  Created by Mahir on 9/25/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FloatingAddButtonDelegate <NSObject>
- (void) floatingAddButtonDidOpenMenu;
- (void) floatingAddButtonDidCloseMenu;
@end

@interface FloatingAddButton : UIButton {
    BOOL isActive;
}

@property (nonatomic, strong) id<FloatingAddButtonDelegate> delegate;

@end
