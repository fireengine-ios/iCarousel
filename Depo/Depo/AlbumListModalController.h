//
//  AlbumListModalController.h
//  Depo
//
//  Created by Mahir on 10/3/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "MyModalController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "MetaAlbum.h"

@interface AlbumListModalController : MyModalController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSMutableArray *albums;
@property (nonatomic, strong) UITableView *albumTable;
@property (nonatomic, strong) ALAssetsLibrary *al;

@end
