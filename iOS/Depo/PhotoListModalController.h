//
//  PhotoListModalController.h
//  Depo
//
//  Created by Mahir on 10/1/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "MyModalController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "SelectibleAssetView.h"
#import "MultipleUploadFooterView.h"
#import "UploadManager.h"
#import "MetaAlbum.h"

@protocol PhotoModalDelegate <NSObject>
- (void) photoModalDidTriggerUploadForUrls:(NSArray *) assetUrls;
@end

@interface PhotoListModalController : MyModalController <SelectibleAssetDelegate, MultipleUploadFooterDelegate> {
    UploadManager *uploadManager;
}

@property (nonatomic, weak) id<PhotoModalDelegate> modalDelegate;
@property (nonatomic, strong) NSMutableArray *assets;
@property (nonatomic, strong) NSMutableArray *selectedAssets;
@property (nonatomic, strong) UIScrollView *mainScroll;
@property (nonatomic, strong) MultipleUploadFooterView *footerView;
@property (nonatomic, strong) ALAssetsLibrary *al;
@property (nonatomic, strong) MetaAlbum *album;

- (id)initWithAlbum:(MetaAlbum *) _album;

@end
