//
//  CropAndShareListController.h
//  Depo
//
//  Created by Mahir on 09/11/15.
//  Copyright © 2015 com.igones. All rights reserved.
//

#import "MyViewController.h"
#import "ElasticSearchDao.h"
#import "MetaFile.h"
#import "PhotoHeaderSegmentView.h"
#import "SquareImageView.h"
#import "DeleteDao.h"
#import "ShareLinkDao.h"
#import "CustomButton.h"
#import "FooterActionsMenuView.h"
#import "ImagePreviewController.h"
#import "VideoPreviewController.h"
#import "NoItemCell.h"

@interface CropAndShareListController : MyViewController <SquareImageDelegate, UIScrollViewDelegate, FooterActionsDelegate, ImagePreviewDelegate, VideoPreviewDelegate> {
    
    ElasticSearchDao *elasticSearchDao;
    DeleteDao *deleteDao;
    ShareLinkDao *shareDao;
    
    CustomButton *moreButton;
    
    float normalizedContentHeight;
    float maximizedContentHeight;
    
    UIBarButtonItem *previousButtonRef;
    
    int listOffset;
    BOOL isLoading;
    BOOL isSelectible;
    
    NoItemCell *noItemCell;
    
    MyNavigationController *printNav;
}

@property (nonatomic, strong) UIScrollView *photosScroll;
@property (nonatomic, strong) NSMutableArray *photoList;
@property (nonatomic, strong) UIRefreshControl *refreshControlPhotos;

@property (nonatomic, strong) NSMutableArray *selectedFileList;

@property (nonatomic, strong) FooterActionsMenuView *imgFooterActionMenu;
@property int photoCount;

@end
