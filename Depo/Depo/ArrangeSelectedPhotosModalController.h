//
//  ArrangeSelectedPhotosModalController.h
//  Depo
//
//  Created by Mahir Tarlan on 06/07/16.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import "MyModalController.h"
#import "Story.h"
#import "VideofyFooterView.h"
#import "VideofyCreateDao.h"

@interface ArrangeSelectedPhotosModalController : MyModalController <UIGestureRecognizerDelegate, VideofyFooterDelegate>

@property (nonatomic, strong) Story *story;
@property (nonatomic, strong) UIScrollView *photosScroll;
@property (nonatomic, strong) NSMutableArray *photoList;
@property (nonatomic, strong) NSMutableArray *selectedFileList;

@property (nonatomic, strong) VideofyFooterView *footerView;
@property (nonatomic, strong) VideofyCreateDao *createDao;

- (id) initWithStory:(Story *) rawStory;

@end
