//
//  RevisitedAlbumListView.h
//  Depo
//
//  Created by Mahir Tarlan on 09/08/16.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MetaAlbum.h"

@protocol RevisitedAlbumListDelegate <NSObject>
- (void) revisitedAlbumListDidSelectAlbum:(MetaAlbum *) albumSelected;
@end

@interface RevisitedAlbumListView : UIView <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) id<RevisitedAlbumListDelegate> delegate;
@property (nonatomic, strong) NSArray *albums;
@property (nonatomic, strong) UITableView *albumTable;

@end
