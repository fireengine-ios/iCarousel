//
//  CRYRotateImageViewController.h
//  CropySDK
//
//  Created by Alper KIRDÖK on 19/07/16.
//  Copyright © 2016 SolidICT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>
#import "CRYRotateImageDelegate.h"

@interface CRYRotateImageViewController : UIViewController<CRYRotateImageDelegate>

@property (nonatomic, strong) id<CRYRotateImageDelegate> rotateDelegate;

+(CRYRotateImageViewController*) getInstance;
@property (nonatomic, strong) UIImage *rotateImage;

@end
