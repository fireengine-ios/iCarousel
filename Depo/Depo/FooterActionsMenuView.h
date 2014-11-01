//
//  FooterActionsMenuView.h
//  Depo
//
//  Created by Mahir on 01/11/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomButton.h"

@protocol FooterActionsDelegate <NSObject>
- (void) footerActionMenuDidSelectDelete;
- (void) footerActionMenuDidSelectMove;
- (void) footerActionMenuDidSelectShare;
@end

@interface FooterActionsMenuView : UIView

@property (nonatomic, strong) id<FooterActionsDelegate> delegate;
@property (nonatomic, strong) CustomButton *shareButton;
@property (nonatomic, strong) CustomButton *moveButton;
@property (nonatomic, strong) CustomButton *deleteButton;

@end
