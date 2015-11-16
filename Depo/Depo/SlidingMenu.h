//
//  SlidingMenu.h
//  Depo
//
//  Created by mahir tarlan
//  Copyright (c) 2013 iGones. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppConstants.h"
#import "MenuCell.h"
#import "MenuSearchCell.h"
#import "MenuProfileCell.h"
#import "AudioMenuFooterView.h"

@protocol SlidingMenuDelegate <NSObject>
- (void) didTriggerProfile;
- (void) didTriggerHome;
- (void) didTriggerSearch;
- (void) didTriggerFavorites;
- (void) didTriggerFiles;
- (void) didTriggerPhotos;
- (void) didTriggerMusic;
- (void) didTriggerDocs;
- (void) didTriggerLogout;
- (void) didTriggerLogin;
- (void) didTriggerCropAndShare;
- (void) didTriggerCurrentMusic;
- (void) didTriggerContactSync;
@end

@protocol SlidingMenuCloseDelegate <NSObject>
- (void) shouldClose;
@end

@interface SlidingMenu : UIView <UITableViewDataSource, UITableViewDelegate, AudioMenuFooterDelegate>

@property (nonatomic, strong) id<SlidingMenuDelegate> delegate;
@property (nonatomic, strong) id<SlidingMenuCloseDelegate> closeDelegate;
@property (nonatomic, strong) UITableView *menuTable;
@property (nonatomic, strong) NSArray *sectionMetaArray;
@property (nonatomic, strong) AudioMenuFooterView *audioFooterView;
@property (nonatomic) int tableUpdateCounter;

- (void) updateMenuByLoginStatus;

@end
