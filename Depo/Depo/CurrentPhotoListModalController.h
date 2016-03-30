//
//  CurrentPhotoListModalController.h
//  Depo
//
//  Created by Mahir Tarlan on 29/03/16.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import "MyModalController.h"
#import "SquareImageView.h"
#import "ElasticSearchDao.h"
#import "NoItemView.h"

@protocol CurrentPhotoListModalDelegate <NSObject>
- (void) photoModalListReturnedWithSelectedList:(NSArray *) uuids;
@end


@interface CurrentPhotoListModalController : MyModalController <SquareImageDelegate, UIScrollViewDelegate> {
    
    ElasticSearchDao *elasticSearchDao;
    
    int listOffset;
    BOOL isLoading;
    BOOL isSelectible;
    
    NoItemView *noItemView;
}

@property (nonatomic, weak) id<CurrentPhotoListModalDelegate> delegate;
@property (nonatomic, strong) UIScrollView *photosScroll;
@property (nonatomic, strong) NSMutableArray *photoList;
@property (nonatomic, strong) NSMutableArray *selectedFileList;

@end
