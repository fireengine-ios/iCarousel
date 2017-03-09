//
//  ZPhotoView.m
//  Depo
//
//  Created by Metin Guler on 21/02/2017.
//  Copyright © 2017 com.igones. All rights reserved.
//

#import "ZPhotoView.h"
#import "UIImageView+WebCache.h"

@interface ZPhotoView ()

@property (nonatomic) UIImageView *imgView;
@property (nonatomic) UITapGestureRecognizer *doubleTap;
@property (atomic) BOOL isZoomEnabled;

@end

@implementation ZPhotoView

- (id)initWithFrame:(CGRect)frame imageFile:(MetaFile *)metaFile isZoomEnabled:(BOOL)zoomEnabled {
    self = [super initWithFrame:frame];
    if (self) {
        _isZoomEnabled = zoomEnabled;
        
        // progress view
        self.progress = [[MBProgressHUD alloc] initWithFrame:self.frame];
        self.progress.opacity = 0.4f;
        [self addSubview:self.progress];
        
        // file
        self.file = metaFile;
        NSString *imgUrlStr = [self.file.tempDownloadUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        if(self.file.detail && self.file.detail.thumbLargeUrl) {
            imgUrlStr = [self.file.detail.thumbLargeUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        }
        
        // scrollview
        __weak ZPhotoView *weakSelf = self;
        self.delegate = self;
        self.minimumZoomScale = 1.0f;
        self.maximumZoomScale = 5.0f;
//        self.backgroundColor = [UIColor redColor];
        
        // image view
        _imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        _imgView.contentMode = UIViewContentModeScaleAspectFit;
        
        [self showLoading];
        [_imgView sd_setImageWithURL:[NSURL URLWithString:imgUrlStr]
                           completed:
         ^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf hideLoading];
                if (!error) {
                    [weakSelf resizeScrollView];
                }
            });
        }];
        
        [self addSubview:_imgView];
        self.contentSize = _imgView.frame.size;
        
        // double tap
        if (_isZoomEnabled) {
            _doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onDoubleTap:)];
            _doubleTap.numberOfTapsRequired = 2;
            [self addGestureRecognizer:_doubleTap];
        }
    }
    return self;
}

- (UITapGestureRecognizer*)getDoubleTapGestureRecognizer {
    if (_isZoomEnabled) {
        return _doubleTap;
    } else {
        return nil;
    }
    
}

-(void)resizeScrollView {
    self.zoomScale = 1.0f;
    
    // calculate imgView frame
    CGRect tmp = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    UIImage *image = _imgView.image;
    
    if (image != nil) {
        // calculate aspect ratios
        float ratioImgV = self.frame.size.width / self.frame.size.height;
        float ratioImg = image.size.width / image.size.height;
        
        if (ratioImgV > ratioImg) {
            // imageView is wider
            tmp.size.width = self.frame.size.height * ratioImg;
        } else {
            // image is wider
            tmp.size.height = self.frame.size.width / ratioImg;
        }
    }
    
    // update imgView
    _imgView.frame = tmp;
    self.contentSize = tmp.size;
    
    [self scrollViewDidZoom:self];
}

- (void) showLoading {
    [_progress show:YES];
    [self bringSubviewToFront:_progress];
    /*
     loadingView.hidden = NO;
     [self.view bringSubviewToFront:loadingView];
     [loadingView startAnimation];
     */
}

- (void) hideLoading {
    [_progress hide:YES];
    /*
     loadingView.hidden = YES;
     [loadingView stopAnimation];
     */
}

#pragma mark - UIScrolView Delegate Functions

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    float yOffset = MAX(0, (self.frame.size.height - _imgView.frame.size.height) / 2);
    float xOffset = MAX(0, (self.frame.size.width - _imgView.frame.size.width) / 2);
    
    _imgView.frame = CGRectMake(xOffset, yOffset, _imgView.frame.size.width, _imgView.frame.size.height);
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return _imgView;
}

#pragma mark gesture recognizers methods

- (void)onDoubleTap:(UIGestureRecognizer *)gesture {
    
    if (self.zoomScale == 1) {
        CGFloat scale = self.maximumZoomScale;
        
        CGRect tmp = [self calculateZoomRect:gesture zoomScale:scale];
        [self zoomToRect:tmp animated:true];
    } else {
        [self setZoomScale:1 animated:true];
    }
}

- (CGRect)calculateZoomRect:(UIGestureRecognizer *)gesture zoomScale:(CGFloat)scale {
    CGPoint point = [gesture locationInView: _imgView];
    
    CGSize size = CGSizeMake(self.frame.size.width / scale, self.frame.size.height / scale);
    CGPoint origin = CGPointMake(point.x - size.width / 2, point.y - size.height / 2);
    
    return CGRectMake(origin.x, origin.y, size.width, size.height);
}


@end
