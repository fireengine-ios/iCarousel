//
//  PhotosHeaderSyncView.h
//  Depo
//
//  Created by Mahir Tarlan on 13/03/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UploadManager.h"

@protocol PhotosHeaderSyncViewDelegate <NSObject>
- (void) photosHeaderSyncFinishedForAssetUrl:(NSString *) urlVal;
@end

@interface PhotosHeaderSyncView : UIView <UploadManagerDelegate>

@property (nonatomic, weak) id<PhotosHeaderSyncViewDelegate> delegate;

- (void) loadAsset:(NSString *) assetUrlStr;

@end
