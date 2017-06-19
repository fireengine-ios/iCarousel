//
//  DevicePhotoCell.h
//  Depo
//
//  Created by Mahir Tarlan on 10/11/16.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

@protocol DevicePhotoAssetDelegate <NSObject>
- (void) devicePhotoAssetDidBecomeSelected:(ALAsset *) selectedAsset;
- (void) devicePhotoAssetDidBecomeDeselected:(ALAsset *) deselectedAsset;
@end

@interface DevicePhotoCell : UICollectionViewCell {
    UIImageView *maskView;
}

@property (nonatomic, strong) id<DevicePhotoAssetDelegate> delegate;
@property (nonatomic, strong) ALAsset *asset;
@property (nonatomic) BOOL isSelected;

- (void) loadAsset:(ALAsset *) _asset isSelectedFlag:(BOOL) isSelectedFlag;
- (void) manuallySelect;
- (void) manuallyDeselect;

@end
