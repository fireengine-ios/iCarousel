//
//  PreLoginController.h
//  Depo
//
//  Created by Mahir on 4.12.2014.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "MyViewController.h"

@interface PreLoginController : MyViewController <UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *infoScroll;
@property (nonatomic, strong) UIPageControl *pageControl;

@end
