//
//  FooterActionsMenuView.h
//  Depo
//
//  Created by Mahir on 01/11/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomButton.h"

@class FooterActionsMenuView;

@protocol FooterActionsDelegate <NSObject>
- (void) footerActionMenuDidSelectDelete:(FooterActionsMenuView *) menu;
- (void) footerActionMenuDidSelectMove:(FooterActionsMenuView *) menu;
- (void) footerActionMenuDidSelectShare:(FooterActionsMenuView *) menu;
- (void) footerActionMenuDidSelectPrint:(FooterActionsMenuView *)menu;
@end

@interface FooterActionsMenuView : UIView

@property (nonatomic, weak) id<FooterActionsDelegate> delegate;
@property (nonatomic, strong) CustomButton *shareButton;
@property (nonatomic, strong) CustomButton *moveButton;
@property (nonatomic, strong) CustomButton *deleteButton;
@property (nonatomic,strong) CustomButton *printButton;

- (id) initWithFrame:(CGRect)frame shouldShowShare:(BOOL) shareFlag shouldShowMove:(BOOL) moveFlag shouldShowDelete:(BOOL) deleteFlag shouldShowPrint:(BOOL) printFlag;

- (id) initWithFrame:(CGRect)frame shouldShowShare:(BOOL) shareFlag shouldShowMove:(BOOL) moveFlag shouldShowDelete:(BOOL) deleteFlag shouldShowPrint:(BOOL)printFlag isMoveAlbum:(BOOL) moveRename;

- (void) hidePrintIcon;

- (void) showPrintIcon;

@end
