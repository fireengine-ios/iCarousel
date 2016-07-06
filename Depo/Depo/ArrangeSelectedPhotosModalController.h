//
//  ArrangeSelectedPhotosModalController.h
//  Depo
//
//  Created by Mahir Tarlan on 06/07/16.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import "MyModalController.h"
#import "Story.h"

@interface ArrangeSelectedPhotosModalController : MyModalController

@property (nonatomic, strong) Story *story;
@property (nonatomic, strong) UIScrollView *photosScroll;
@property (nonatomic, strong) NSMutableArray *photoList;
@property (nonatomic, strong) NSMutableArray *selectedFileList;

- (id) initWithStory:(Story *) rawStory;

@end
