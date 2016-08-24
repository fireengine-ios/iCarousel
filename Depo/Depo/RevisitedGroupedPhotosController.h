//
//  RevisitedGroupedPhotosController.h
//  Depo
//
//  Created by Mahir Tarlan on 01/08/16.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import "MyViewController.h"
#import "RevisitedPhotoHeaderSegmentView.h"
#import "RevisitedGroupedPhotoView.h"
#import "RevisitedAlbumListView.h"
#import "PhotoAlbumController.h"
#import "ImagePreviewController.h"
#import "VideoPreviewController.h"

@interface RevisitedGroupedPhotosController : MyViewController <RevisitedPhotoHeaderSegmentDelegate, RevisitedAlbumListDelegate, PhotoAlbumDelegate, NewAlbumDelegate, RevisitedGroupedPhotoDelegate, ImagePreviewDelegate, VideoPreviewDelegate>

@property (nonatomic, strong) RevisitedPhotoHeaderSegmentView *segmentView;
@property (nonatomic, strong) RevisitedGroupedPhotoView *groupView;
@property (nonatomic, strong) RevisitedAlbumListView *albumView;
@property (nonatomic, strong) UIBarButtonItem *previousButtonRef;

@end
