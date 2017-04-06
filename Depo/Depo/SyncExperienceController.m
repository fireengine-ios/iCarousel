//
//  SyncExperienceController.m
//  Depo
//
//  Created by RDC on 05/04/2017.
//  Copyright © 2017 com.igones. All rights reserved.
//

#import "SyncExperienceController.h"
#import <AVFoundation/AVFoundation.h>
#import "CustomLabel.h"

#define pageCount 6

@interface SyncExperienceController ()

@property (nonatomic, strong, nullable) void (^completion)(void);
@property (nonatomic, strong) UIScrollView *mainScroll;
@property (nonatomic, strong) UIImageView *bullets;
@property (nonatomic, strong) NSMutableArray *players;
@property (nonatomic, strong) AVPlayer *currentPlayer;
@property (nonatomic) NSInteger currentPage;

@end

@implementation SyncExperienceController

- (instancetype)initWithCompletion:(void (^)(void))completion
{
    self = [super init];
    if (self) {
        self.completion = completion;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // dont assign if you want to loading view in window subview (!)
    self.players = [NSMutableArray new];
    self.view.backgroundColor = [UIColor whiteColor];
    
    // main scroll view
    self.mainScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    self.mainScroll.contentSize = CGSizeMake(self.view.frame.size.width * pageCount, self.view.frame.size.height);
    self.mainScroll.pagingEnabled = YES;
    self.mainScroll.delegate = self;
    self.mainScroll.showsHorizontalScrollIndicator = NO;
    [self.view addSubview:self.mainScroll];
    
    // common frames and sizes
    CGSize scrollSize = self.mainScroll.frame.size;
    
    // page 1
    UIView *page1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, scrollSize.width, scrollSize.height)];
    [self addVideoToPage:page1 videoName:@"1.1 onboarding"];
    [self addLabelToPage:page1 title:@"Easy way to sync your photos" subtitle:@"Neque porro quisquam est qui dolorem ipsum quia dolor sit amet, consectetur, adipisci velit"];
    [self.mainScroll addSubview:page1];
    
    // page 2
    UIView *page2 = [[UIView alloc] initWithFrame:CGRectMake(scrollSize.width, 0, scrollSize.width, scrollSize.height)];
    [self addVideoToPage:page2 videoName:@"1.2 onboarding"];
    [self addLabelToPage:page2 title:@"Easy way to sync your photos" subtitle:@"Neque porro quisquam est qui dolorem ipsum quia dolor sit amet, consectetur, adipisci velit"];
    [self.mainScroll addSubview:page2];
    
    // page 3
    UIView *page3 = [[UIView alloc] initWithFrame:CGRectMake(2 * scrollSize.width, 0, scrollSize.width, scrollSize.height)];
    [self addVideoToPage:page3 videoName:@"1.3 onboarding"];
    [self addLabelToPage:page3 title:@"Easy way to sync your photos" subtitle:@"Neque porro quisquam est qui dolorem ipsum quia dolor sit amet, consectetur, adipisci velit"];
    [self.mainScroll addSubview:page3];
    
    // page 4
    UIView *page4 = [[UIView alloc] initWithFrame:CGRectMake(3 * scrollSize.width, 0, scrollSize.width, scrollSize.height)];
    [self addVideoToPage:page4 videoName:@"1.4 onboarding"];
    [self addLabelToPage:page4 title:@"Easy way to sync your photos" subtitle:@"Neque porro quisquam est qui dolorem ipsum quia dolor sit amet, consectetur, adipisci velit"];
    [self.mainScroll addSubview:page4];
    
    // page 5
    UIView *page5 = [[UIView alloc] initWithFrame:CGRectMake(4 * scrollSize.width, 0, scrollSize.width, scrollSize.height)];
    [self addVideoToPage:page5 videoName:@"1.5 onboarding"];
    [self addLabelToPage:page5 title:@"Easy way to sync your photos" subtitle:@"Neque porro quisquam est qui dolorem ipsum quia dolor sit amet, consectetur, adipisci velit"];
    [self.mainScroll addSubview:page5];
    
    // page 6
    UIView *page6 = [[UIView alloc] initWithFrame:CGRectMake(5 * scrollSize.width, 0, scrollSize.width, scrollSize.height)];
    [self addVideoToPage:page6 videoName:@"1.6 onboarding"];
    [self addLabelToPage:page6 title:@"Easy way to sync your photos" subtitle:@"Neque porro quisquam est qui dolorem ipsum quia dolor sit amet, consectetur, adipisci velit"];
    [self.mainScroll addSubview:page6];
    
    // getStarted button
    UIButton *getStartedButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [getStartedButton setFrame:CGRectMake((scrollSize.width - 190) / 2.0,
                              self.view.frame.size.height -20 -50,
                              190,
                              50)];
    [getStartedButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [getStartedButton setTitle:NSLocalizedString(@"GetStarted", @"") forState:UIControlStateNormal];
    [getStartedButton setBackgroundImage:[UIImage imageNamed:@"Button.png"] forState:UIControlStateNormal];
    [getStartedButton addTarget:self action:@selector(getStartedButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [getStartedButton.titleLabel setFont:[UIFont systemFontOfSize:13]];
    [page6 addSubview:getStartedButton];
    
    // page indicator bullets
    self.bullets = [[UIImageView alloc] initWithFrame:CGRectMake((scrollSize.width - 116) / 2.0,
                                                                 getStartedButton.frame.origin.y - 15 -11,
                                                                 116,
                                                                 11)];
    self.bullets.image = [UIImage imageNamed:@"Bullets 1.1.png"];
    [self.view addSubview:self.bullets];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.currentPlayer = self.players[0];
    [self.currentPlayer seekToTime:kCMTimeZero];
    [self.currentPlayer play];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotate {
    return NO;
}

#pragma mark - View Operations

- (void)addVideoToPage:(UIView*)page videoName:(NSString*)videoName {
    NSURL *videoURL = [[NSBundle mainBundle] URLForResource:videoName withExtension:@"mp4"];
    AVPlayer *player = [AVPlayer playerWithURL:videoURL];
    [self.players addObject:player];
    AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:player];
    playerLayer.frame = CGRectMake(0, 0, page.frame.size.width, page.frame.size.width);
    [page.layer addSublayer:playerLayer];
}

- (void)addLabelToPage:(UIView*)page title:(NSString*)title subtitle:(NSString*)subtitle {
    CustomLabel *titleLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(0,
                                                                       self.view.frame.size.width, // player height
                                                                       page.frame.size.width,
                                                                       60)
                                                   withFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:18]
                                                  withColor:[UIColor blackColor]
                                                   withText:title
                                              withAlignment:NSTextAlignmentCenter];
    [page addSubview:titleLabel];
    
    CustomLabel *subTitleLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(20,
                                                                          titleLabel.frame.origin.y + titleLabel.frame.size.height,
                                                                          page.frame.size.width - 40,
                                                                          60)
                                                      withFont:[UIFont fontWithName:@"TurkcellSaturaMed" size:18]
                                                     withColor:[UIColor grayColor]
                                                      withText:subtitle
                                                 withAlignment:NSTextAlignmentCenter];
    subTitleLabel.numberOfLines = 3;
    [page addSubview:subTitleLabel];
}

#pragma mark - Actions

- (void)getStartedButtonClicked:(UIButton*) sender {
    [self dismissViewControllerAnimated:YES completion:nil];
    self.completion();
}

#pragma mark - ScrollView Delegate Functions

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSInteger page = lround(self.mainScroll.contentOffset.x / self.mainScroll.frame.size.width);
    NSLog(@"page is %li", page);
    if (page < 0 || page >= [self.players count]) {
        return;
    }
    
    // return if page is same
    if (self.currentPage == page) {
        return;
    } else {
        self.currentPage = page;
    }
    
    // stop previous
    [self.currentPlayer pause];
    [self.currentPlayer seekToTime:kCMTimeZero];
    
    // play current
    self.currentPlayer = self.players[page];
    [self.currentPlayer seekToTime:kCMTimeZero];
    [self.currentPlayer play];
    
    // change bullets
    self.bullets.image = [UIImage imageNamed:[NSString stringWithFormat:@"Bullets 1.%li.png", self.currentPage +1]];
}


@end
