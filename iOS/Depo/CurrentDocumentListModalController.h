//
//  CurrentDocumentListModalController.h
//  Depo
//
//  Created by Mahir Tarlan on 29/03/16.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import "MyModalController.h"
#import "ElasticSearchDao.h"
#import "AbstractFileFolderCell.h"

@protocol CurrentDocumentListModalDelegate <NSObject>
- (void) docModalListReturnedWithSelectedList:(NSArray *) uuids;
@end

@interface CurrentDocumentListModalController : MyModalController <UITableViewDataSource, UITableViewDelegate, AbstractFileFolderDelegate> {
    ElasticSearchDao *elasticSearchDao;
    
    int listOffset;
    BOOL isLoading;
    BOOL isSelectible;
}

@property (nonatomic, weak) id<CurrentDocumentListModalDelegate> delegate;
@property (nonatomic, strong) UITableView *docTable;
@property (nonatomic, strong) NSMutableArray *docList;
@property (nonatomic, strong) NSMutableArray *selectedDocList;

@end
