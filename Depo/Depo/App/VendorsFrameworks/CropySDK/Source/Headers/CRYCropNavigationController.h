//
//  CRYCropNavigationController.h
//  CropySDK
//
//  Created by Alper KIRDÖK on 16/08/16.
//  Copyright © 2016 SolidICT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ACEDrawingView.h"
#import "MySlider.h"

@class TOCropViewController;
@protocol TOCropViewControllerDelegate;

@protocol SharedTypeDelegate <NSObject>
@optional

-(void)getSharedUrl:(NSString *)sharedUrl;
-(void)getEditedImage:(UIImage *)sharedImage;

@end

@interface CRYCropNavigationController : UINavigationController

@property (nonatomic, strong) id sharedDelegate;

@property (nonatomic, strong) UIImage *image;

-(void)setCropDelegate:(id<TOCropViewControllerDelegate>) delegate;
-(void)setShareEnabled:(BOOL)shareEnabled;
+(CRYCropNavigationController *)startEditControllerWithImage:(UIImage *)image andUseCropPage:(BOOL)useCropPage;
- (void)setSharedImage:(UIImage *)sharedImage;
- (void)setSharedUrl:(NSString *)sharedUrl;

@end
