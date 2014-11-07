//
//  MoreMenuView.h
//  Depo
//
//  Created by Mahir on 9/26/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MetaFile.h"

@protocol MoreMenuDelegate <NSObject>
- (void) moreMenuDidSelectFav;
- (void) moreMenuDidSelectUnfav;
- (void) moreMenuDidSelectShare;
- (void) moreMenuDidSelectDelete;
@end

@interface MoreMenuView : UIView <UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) id<MoreMenuDelegate> delegate;
@property (nonatomic, strong) UITableView *moreTable;
@property (nonatomic, strong) NSArray *moreList;
@property (nonatomic, strong) MetaFile *fileFolder;

- (id)initWithFrame:(CGRect)frame withList:(NSArray *) moreListRef;
- (id)initWithFrame:(CGRect)frame withList:(NSArray *) moreListRef withFileFolder:(MetaFile *) _fileFolder;

@end
