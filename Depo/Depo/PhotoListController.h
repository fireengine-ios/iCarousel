//
//  PhotoListController.h
//  Depo
//
//  Created by Mahir on 9/24/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "MyViewController.h"
#import "FileListDao.h"
#import "MetaFile.h"
#import "PhotoHeaderSegmentView.h"

@interface PhotoListController : MyViewController <PhotoHeaderSegmentDelegate> {
    FileListDao *fileListDao;
}

@property (nonatomic, strong) PhotoHeaderSegmentView *headerView;
@property (nonatomic, strong) UIScrollView *photosScroll;

@end
