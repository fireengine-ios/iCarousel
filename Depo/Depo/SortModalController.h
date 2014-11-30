//
//  SortModalController.h
//  Depo
//
//  Created by Mahir on 30/10/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "MyModalController.h"

@protocol SortModalDelegate <NSObject>
- (void) sortDidChange;
@end

@interface SortModalController : MyModalController <UITableViewDataSource, UITableViewDelegate>

@property(nonatomic, strong) id<SortModalDelegate> delegate;
@property(nonatomic, strong) UITableView *sortTable;
@property(nonatomic, strong) NSArray *sortTypes;

- (id) initWithList:(NSArray *) typeList;

@end
