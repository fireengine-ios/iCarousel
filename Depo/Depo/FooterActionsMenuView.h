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
- (void) footerActionMenuDidSelectRemove:(FooterActionsMenuView *) menu;
- (void) footerActionMenuDidSelectSync:(FooterActionsMenuView *) menu;
- (void) footerActionMenuDidSelectMove:(FooterActionsMenuView *) menu;
- (void) footerActionMenuDidSelectDownload:(FooterActionsMenuView *) menu;
- (void) footerActionMenuDidSelectShare:(FooterActionsMenuView *) menu;
- (void) footerActionMenuDidSelectPrint:(FooterActionsMenuView *)menu;
- (void) footerActionMenuDidSelectDownload:(FooterActionsMenuView *) menu;
- (void) footerActionMenuDidSelectMore:(FooterActionsMenuView *) menu;
@end

@interface FooterActionsMenuView : UIView

@property (nonatomic, weak) id<FooterActionsDelegate> delegate;
@property (nonatomic, strong) CustomButton *shareButton;
@property (nonatomic, strong) CustomButton *moveButton;
@property (nonatomic, strong) CustomButton *syncButton;
@property (nonatomic, strong) CustomButton *downloadButton;
@property (nonatomic, strong) CustomButton *deleteButton;
@property (nonatomic,strong) CustomButton *printButton;
@property (nonatomic,strong) CustomButton *removeButton;
@property (nonatomic,strong) CustomButton *moreButton;

- (id) initWithFrame:(CGRect)frame shouldShowShare:(BOOL) shareFlag shouldShowMove:(BOOL) moveFlag shouldShowDelete:(BOOL) deleteFlag shouldShowDownload:(BOOL)downloadFlag shouldShowPrint:(BOOL) printFlag;
- (id) initWithFrame:(CGRect)frame shouldShowShare:(BOOL) shareFlag shouldShowMove:(BOOL) moveFlag shouldShowDelete:(BOOL) deleteFlag shouldShowPrint:(BOOL)printFlag ;
- (id) initWithFrame:(CGRect)frame shouldShowShare:(BOOL) shareFlag shouldShowMove:(BOOL) moveFlag shouldShowDelete:(BOOL) deleteFlag shouldShowRemove:(BOOL) removeFlag shouldShowDownload:(BOOL)downloadFlag shouldShowPrint:(BOOL)printFlag;

- (id) initWithFrame:(CGRect)frame shouldShowShare:(BOOL) shareFlag shouldShowMove:(BOOL) moveFlag shouldShowDelete:(BOOL) deleteFlag shouldShowPrint:(BOOL)printFlag isMoveAlbum:(BOOL) moveRename;

-(id)initForPhotosTabWithFrame:(CGRect)frame shouldShowShare:(BOOL) shareFlag shouldShowMove:(BOOL) moveFlag shouldShowDownload:(BOOL) downloadFlag shouldShowDelete:(BOOL) deleteFlag shouldShowPrint:(BOOL)printFlag isMoveAlbum:(BOOL) moveRename;

-(id)initForPhotosTabWithFrame:(CGRect)frame shouldShowShare:(BOOL) shareFlag shouldShowMove:(BOOL) moveFlag shouldShowDownload:(BOOL) downloadFlag shouldShowDelete:(BOOL) deleteFlag shouldShowPrint:(BOOL)printFlag shouldShowSync:(BOOL) syncFlag isMoveAlbum:(BOOL) moveRename;

- (void) hidePrintIcon;

- (void) showPrintIcon;

- (void) disableSyncButton;
- (void) enableSyncButton;

- (void) disableDeleteButton;
- (void) enableDeleteButton;

- (void) disableMoveButton;
- (void) enableMoveButton;

- (void) disablePrintButton;
- (void) enablePrintButton;

- (void) disableDownloadButton;
- (void) enableDownloadButton;

@end
