//
//  BaseViewController.m
//  Depo
//
//  Created by mahir tarlan
//  Copyright (c) 2013 igones. All rights reserved.
//

#import "BaseViewController.h"
#import "MyViewController.h"
#import "HomeController.h"
#import "SettingsController.h"
#import "AppSession.h"
#import "AppDelegate.h"
#import "AppUtil.h"

#define kMenuOpenOriginX 276

@interface BaseViewController ()

@end

@implementation BaseViewController

@synthesize scroll;
@synthesize nav;
@synthesize menuOpen;
@synthesize menu;
@synthesize baseProgress;
@synthesize transparentView;

- (id)initWithRootViewController:(MyViewController *) rootViewController {
    self = [super init];
    if (self) {

        tokenDao = [[RequestTokenDao alloc] init];
//        tokenDao.delegate = self;
//        tokenDao.successMethod = @selector(requestTokenSuccessCallback:);
//        tokenDao.failMethod = @selector(requestTokenFailCallback:);
        
        scroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        scroll.scrollEnabled = NO;
        [scroll setShowsHorizontalScrollIndicator:NO];
        [scroll setShowsVerticalScrollIndicator:NO];
        
        menu = [[SlidingMenu alloc] initWithFrame:CGRectMake(0, 0, kMenuOpenOriginX, self.view.frame.size.height)];
        menu.delegate = self;
        menu.closeDelegate = self;
        [scroll addSubview:menu];
        
        nav = [[MyNavigationController alloc] initWithRootViewController:rootViewController];
        nav.view.frame = CGRectMake(kMenuOpenOriginX, 0, self.view.frame.size.width, self.view.frame.size.height);
        rootViewController.nav = nav;
        rootViewController.myDelegate = self;
        [scroll addSubview:nav.view];
        
        transparentView = [[UIView alloc] initWithFrame:CGRectMake(kMenuOpenOriginX, 0, self.view.frame.size.width, self.view.frame.size.height)];
        transparentView.hidden = YES;
        [scroll addSubview:transparentView];

        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
        tapGestureRecognizer.numberOfTapsRequired = 1;
        tapGestureRecognizer.enabled = YES;
        [transparentView addGestureRecognizer:tapGestureRecognizer];

        scroll.contentSize = CGSizeMake(kMenuOpenOriginX + 320, scroll.frame.size.height);
        [self.view addSubview:scroll];
        
        baseProgress = [[MBProgressHUD alloc] initWithFrame:self.view.frame];
        baseProgress.opacity = 0.4f;
        [self.view addSubview:baseProgress];

        UISwipeGestureRecognizer *recognizerLeft = [[UISwipeGestureRecognizer alloc]
                                                    initWithTarget:self action:@selector(swipeLeft:)];
        recognizerLeft.direction = UISwipeGestureRecognizerDirectionLeft;
        [self.view addGestureRecognizer:recognizerLeft];
        
        UISwipeGestureRecognizer *recognizerRight = [[UISwipeGestureRecognizer alloc]
                                                     initWithTarget:self action:@selector(swipeRight:)];
        recognizerRight.direction = UISwipeGestureRecognizerDirectionRight;
        [self.view addGestureRecognizer:recognizerRight];
        
        [tokenDao requestTokenForMsisdn:@"5322109090" andPassword:@"5322109090"];
    }
    return self;
}

- (void) singleTap:(UITapGestureRecognizer *) tapRecognizer {
    if (menuOpen) {
        [self showMenu];
    }
}

- (void)swipeLeft:(UISwipeGestureRecognizer*)recognizer {
    CGPoint p = [recognizer locationInView:self.view];
    
    if (menuOpen && p.x > kMenuOpenOriginX) {
        [self showMenu];
    }
}

- (void)swipeRight:(UISwipeGestureRecognizer*)recognizer {
    if (!menuOpen)
        [self showMenu];
}

- (void)showMenu {
    [[NSNotificationCenter defaultCenter] postNotificationName:MENU_CLOSED_NOTIFICATION object:nil];
    CGPoint newOffset = CGPointMake(menuOpen ? kMenuOpenOriginX : 0.0, 0.0);
    
    [UIView animateWithDuration:0.3
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.scroll.contentOffset = newOffset;
                     }
                     completion:^(BOOL finished) {
                         menuOpen = !menuOpen;
                         transparentView.hidden = !menuOpen;
                     }];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    transparentView.hidden = YES;
    self.scroll.contentOffset = CGPointMake(kMenuOpenOriginX, 0.0);
    menuOpen = NO;
}

- (void) viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    transparentView.hidden = YES;
    self.scroll.contentOffset = CGPointMake(kMenuOpenOriginX, 0.0);
    menuOpen = NO;
}

#pragma mark SlidingMenuDelegate

- (void) didTriggerHome {
    HomeController *home = [[HomeController alloc] init];
    home.nav = self.nav;
    home.myDelegate = self;
    [self.nav setViewControllers:@[home] animated:NO];
}

- (void) didTriggerLogin {
}

- (void) didTriggerLogout {
}

- (void) didTriggerFavorites {
}

- (void) didTriggerFiles {
}

- (void) didTriggerPhotos {
}

- (void) didTriggerMusic {
}

- (void) didTriggerDocs {
}

- (void) didTriggerSearch {
}

- (void) didTriggerProfile {
    SettingsController *settings = [[SettingsController alloc] init];
    settings.nav = self.nav;
    settings.myDelegate = self;
    [self.nav setViewControllers:@[settings] animated:NO];
}

- (void) showBaseLoading {
    [baseProgress show:YES];
    [self.view bringSubviewToFront:baseProgress];
}

- (void) hideBaseLoading {
    [baseProgress hide:YES];
}

#pragma mark SlidingMenuCloseDelegate

- (void) shouldClose {
    [[NSNotificationCenter defaultCenter] postNotificationName:MENU_CLOSED_NOTIFICATION object:nil];
    [UIView animateWithDuration:0.3
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.scroll.contentOffset = CGPointMake(kMenuOpenOriginX, 0.0);
                     }
                     completion:^(BOOL finished) {
                         transparentView.hidden = YES;
                         menuOpen = NO;
                     }];
}

- (void) shouldToggleMenu {
    [self showMenu];
}

- (void) shouldTriggerLoggedInPage {
    HomeController *home = [[HomeController alloc] init];
    home.nav = self.nav;
    home.myDelegate = self;
    [self.nav setViewControllers:@[home] animated:NO];
}

- (void) shouldTriggerLogin {
    [self didTriggerLogin];
}

- (void) logoutSuccessCallback {
}

- (void) logoutFailCallback:(NSString *) errorMessage {
    [self hideBaseLoading];
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotate {
    if ([[self nav] respondsToSelector:@selector(shouldAutorotate)])
        return [[self nav] shouldAutorotate];
    else
        return NO;
}

- (NSUInteger)supportedInterfaceOrientations {
    if ([[self nav] respondsToSelector:@selector(supportedInterfaceOrientations)])
        return [[self nav] supportedInterfaceOrientations];
    else
        return [super supportedInterfaceOrientations];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    if ([[self nav] respondsToSelector:@selector(shouldAutorotateToInterfaceOrientation:)])
        return [[self nav] shouldAutorotateToInterfaceOrientation:interfaceOrientation];
    else
        return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
