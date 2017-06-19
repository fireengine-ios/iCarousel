//
//  SelectiblePhotoListModalController.h
//  Depo
//
//  Created by Mahir Tarlan on 05/07/16.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import "MyModalController.h"
#import "Story.h"
#import "ElasticSearchDao.h"
#import "SquareImageView.h"

@interface SelectiblePhotoListModalController : MyModalController <UIScrollViewDelegate, SquareImageDelegate> {
    ElasticSearchDao *elasticSearchDao;
}

@property (nonatomic, strong) Story *story;
@property (nonatomic, strong) UIScrollView *photosScroll;
@property (nonatomic, strong) NSMutableArray *photoList;
@property (nonatomic, strong) NSMutableArray *selectedFileList;
@property (nonatomic) int listOffset;
@property (nonatomic) BOOL isLoading;

- (id) initWithStory:(Story *) rawStory;

@end
