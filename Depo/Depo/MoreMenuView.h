//
//  MoreMenuView.h
//  Depo
//
//  Created by Mahir on 9/26/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MoreMenuView : UIView <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *moreTable;
@property (nonatomic, strong) NSArray *moreList;

- (id)initWithFrame:(CGRect)frame withList:(NSArray *) moreListRef;

@end
