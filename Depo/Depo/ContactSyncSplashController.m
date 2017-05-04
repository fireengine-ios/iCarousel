//
//  ContactSyncSplashController.m
//  Depo
//
//  Created by RDC on 04/05/2017.
//  Copyright © 2017 com.igones. All rights reserved.
//

#import "ContactSyncSplashController.h"
#import "Util.h"

#define pageCount 5

@interface ContactSyncSplashController ()

@property (nonatomic, strong) UIScrollView *mainScroll;
@property (nonatomic, strong) UIPageControl *pageControl;
@property (nonatomic) NSInteger currentPage;

@end

@implementation ContactSyncSplashController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // main scroll view
    self.mainScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    self.mainScroll.contentSize = CGSizeMake(self.view.frame.size.width * pageCount, self.view.frame.size.height);
    self.mainScroll.pagingEnabled = YES;
    self.mainScroll.delegate = self;
    self.mainScroll.showsHorizontalScrollIndicator = NO;
    [self.view addSubview:self.mainScroll];
    
    // common frames and sizes
    CGSize scrollSize = self.mainScroll.frame.size;
    NSString *locale = [[Util readLocaleCode] isEqualToString:@"tr"] ? @"tr" : @"en";
    
    // page 1
    UIImageView *page = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, scrollSize.width, scrollSize.height)];
    NSString *imageName = [locale isEqualToString:@"tr"] ? @"Lifebox-1.0@3x.png" : @"Lifebox-1.0 Eng@3x.png";
    page.image = [UIImage imageNamed:imageName];
    [self.mainScroll addSubview:page];
    
    page = [[UIImageView alloc] initWithFrame:CGRectMake(scrollSize.width, 0, scrollSize.width, scrollSize.height)];
    imageName = [locale isEqualToString:@"tr"] ? @"Lifebox-1@3x.png" : @"Lifebox-1 Eng@3x.png";
    page.image = [UIImage imageNamed:imageName];
    [self.mainScroll addSubview:page];
    
    page = [[UIImageView alloc] initWithFrame:CGRectMake(2 * scrollSize.width, 0, scrollSize.width, scrollSize.height)];
    imageName = [locale isEqualToString:@"tr"] ? @"Lifebox-2@3x.png" : @"Lifebox-2 Eng@3x.png";
    page.image = [UIImage imageNamed:imageName];
    [self.mainScroll addSubview:page];
    
    page = [[UIImageView alloc] initWithFrame:CGRectMake(3 * scrollSize.width, 0, scrollSize.width, scrollSize.height)];
    imageName = [locale isEqualToString:@"tr"] ? @"Lifebox-3.0@3x.png" : @"Lifebox-3.0 Eng@3x.png";
    page.image = [UIImage imageNamed:imageName];
    [self.mainScroll addSubview:page];
    
    page = [[UIImageView alloc] initWithFrame:CGRectMake(4 * scrollSize.width, 0, scrollSize.width, scrollSize.height)];
    imageName = [locale isEqualToString:@"tr"] ? @"Lifebox-3@3x.png" : @"Lifebox-3 Eng@3x.png";
    page.image = [UIImage imageNamed:imageName];
    [self.mainScroll addSubview:page];
    
    // page control
    self.pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake((scrollSize.width - 116) / 2.0,
                                                                        scrollSize.height - 20,
                                                                       116,
                                                                       10)];
    self.pageControl.numberOfPages = pageCount;
    self.pageControl.pageIndicatorTintColor = [Util UIColorForHexColor:@"BAD6EE"];
    self.pageControl.currentPageIndicatorTintColor = [Util UIColorForHexColor:@"26B5EE"];
    self.pageControl.transform = CGAffineTransformMakeScale(1.5, 1.5);
    [self.view addSubview:self.pageControl];
    
    // cancel button
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(5 * scrollSize.width - 60, 20, 60, 60);
    [btn setImage:[UIImage imageNamed:@"icon_ustbar_close@3x.png"] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(dismissSplashPage:) forControlEvents:UIControlEventTouchUpInside];
    [self.mainScroll addSubview:btn];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (void)dismissSplashPage:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - ScrollView Delegate Functions

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    NSInteger page = lround(self.mainScroll.contentOffset.x / self.mainScroll.frame.size.width);
    // change bullets
    self.pageControl.currentPage = page;
    
    if (self.mainScroll.contentOffset.x > (self.mainScroll.frame.size.width * 4) + 40) {
        [self dismissWindowDirection:DismissDirectionLeft completion:nil];
    }
}


@end
