//
//  PhotoAlbumFooterActionsMenuView.h
//  Depo
//
//  Created by Seyma Tanoglu on 30/11/16.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomButton.h"

@class PhotoAlbumFooterActionsMenuView;

@protocol PhotoAlbumFooterActionsDelegate <NSObject>
- (void) footerActionMenuDidSelectRemove:(PhotoAlbumFooterActionsMenuView *) menu;
- (void) footerActionMenuDidSelectMove:(PhotoAlbumFooterActionsMenuView *) menu;
- (void) footerActionMenuDidSelectShare:(PhotoAlbumFooterActionsMenuView *) menu;
- (void) footerActionMenuDidSelectPrint:(PhotoAlbumFooterActionsMenuView *)menu;
- (void) footerActionMenuDidSelectDownload:(PhotoAlbumFooterActionsMenuView *) menu;
@end

@interface PhotoAlbumFooterActionsMenuView : UIView

@property (nonatomic, weak) id<PhotoAlbumFooterActionsDelegate> delegate;
@property (nonatomic, strong) CustomButton *shareButton;
@property (nonatomic, strong) CustomButton *moveButton;
@property (nonatomic, strong) CustomButton *removeButton;
@property (nonatomic, strong) CustomButton *downloadButton;
@property (nonatomic,strong) CustomButton *printButton;

@end
