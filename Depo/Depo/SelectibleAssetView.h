//
//  SelectibleAssetView.h
//  Depo
//
//  Created by Mahir on 10/1/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

@protocol SelectibleAssetDelegate <NSObject>
- (void) selectibleAssetDidBecomeSelected:(ALAsset *) selectedAsset;
- (void) selectibleAssetDidBecomeDeselected:(ALAsset *) deselectedAsset;
@end

@interface SelectibleAssetView : UIView {
    UIImageView *maskView;
}

@property (nonatomic, strong) id<SelectibleAssetDelegate> delegate;
@property (nonatomic, strong) ALAsset *asset;
@property (nonatomic) BOOL isSelected;

- (id)initWithFrame:(CGRect)frame withAsset:(ALAsset *) _asset;
- (void) manuallySelect;
- (void) manuallyDeselect;

@end
