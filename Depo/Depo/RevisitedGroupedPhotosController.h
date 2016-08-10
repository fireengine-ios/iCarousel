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
#import "RevisitedCollectionView.h"
#import "RevisitedAlbumListView.h"

@interface RevisitedGroupedPhotosController : MyViewController <RevisitedPhotoHeaderSegmentDelegate>

@property (nonatomic, strong) RevisitedPhotoHeaderSegmentView *segmentView;
@property (nonatomic, strong) RevisitedGroupedPhotoView *groupView;
@property (nonatomic, strong) RevisitedCollectionView *collView;
@property (nonatomic, strong) RevisitedAlbumListView *albumView;

@end
