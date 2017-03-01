//
//  ZPhotoView.h
//  Depo
//
//  Created by Metin Guler on 21/02/2017.
//  Copyright © 2017 com.igones. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MetaFile.h"
#import "MBProgressHUD.h"

@interface ZPhotoView : UIScrollView <UIScrollViewDelegate>

@property (nonatomic, strong) MBProgressHUD *progress;
@property (nonatomic) MetaFile *file;

- (id)initWithFrame:(CGRect)frame imageFile:(MetaFile *)metaFile isZoomEnabled:(BOOL)zoomEnabled;
// resize view when frame changed
-(void)resizeScrollView;
// set this with requireGestureRecognizerToFail when adding single tap on superview
- (UITapGestureRecognizer*)getDoubleTapGestureRecognizer;

- (void) showLoading;
- (void) hideLoading;

@end
