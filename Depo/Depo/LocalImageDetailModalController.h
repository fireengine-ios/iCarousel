//
//  LocalImageDetailModalController.h
//  Depo
//
//  Created by Mahir Tarlan on 22/03/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

#import "MyModalController.h"
#import <AssetsLibrary/AssetsLibrary.h>

@interface LocalImageDetailModalController : MyModalController

@property (nonatomic, strong) ALAsset *asset;

- (id) initWithAsset:(ALAsset *) _asset;

@end
