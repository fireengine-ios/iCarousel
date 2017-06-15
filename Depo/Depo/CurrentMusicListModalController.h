//
//  CurrentMusicListModalController.h
//  Depo
//
//  Created by Mahir Tarlan on 29/03/16.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import "MyModalController.h"
#import "ElasticSearchDao.h"
#import "AbstractFileFolderCell.h"

@protocol CurrentMusicListModalDelegate <NSObject>
- (void) musicModalListReturnedWithSelectedList:(NSArray *) uuids;
@end

@interface CurrentMusicListModalController : MyModalController <UITableViewDataSource, UITableViewDelegate, AbstractFileFolderDelegate> {
    ElasticSearchDao *elasticSearchDao;
    
    int listOffset;
    BOOL isLoading;
    BOOL isSelectible;
}

@property (nonatomic, weak) id<CurrentMusicListModalDelegate> delegate;
@property (nonatomic, strong) UITableView *musicTable;
@property (nonatomic, strong) NSMutableArray *musicList;
@property (nonatomic, strong) NSMutableArray *selectedMusicList;

@end
