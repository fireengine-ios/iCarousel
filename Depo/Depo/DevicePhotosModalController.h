//
//  DevicePhotosModalController.h
//  Depo
//
//  Created by Mahir Tarlan on 10/11/16.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import "MyModalController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "DevicePhotoCell.h"
#import "MultipleUploadFooterView.h"
#import "UploadManager.h"
#import "MetaAlbum.h"

@protocol DevicePhotosModalDelegate <NSObject>
- (void) devicePhotosDidTriggerUploadForUrls:(NSArray *) assetUrls;
@end

@interface DevicePhotosModalController : MyModalController <MultipleUploadFooterDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, DevicePhotoAssetDelegate> {
    UploadManager *uploadManager;
}

@property (nonatomic, weak) id<DevicePhotosModalDelegate> modalDelegate;
@property (nonatomic, strong) NSMutableArray *assets;
@property (nonatomic, strong) NSMutableArray *selectedAssets;
@property (nonatomic, strong) UICollectionView *collView;
@property (nonatomic, strong) MultipleUploadFooterView *footerView;
@property (nonatomic, strong) MetaAlbum *album;

- (id)initWithAlbum:(MetaAlbum *) _album;

@end
