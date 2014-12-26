//
//  PostLoginSyncPhotoController.h
//  Depo
//
//  Created by Mahir on 5.12.2014.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "MyViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>

@interface PostLoginSyncPhotoController : MyViewController

@property (nonatomic, strong) UISwitch *onOff;
@property (nonatomic, strong) ALAssetsLibrary *assetsLibrary;

@end
