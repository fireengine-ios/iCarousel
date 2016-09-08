//
//  SettingsHelpController.m
//  Depo
//
//  Created by Salih Topcu on 23.09.2014.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "SettingsHelpController.h"

@interface SettingsHelpController ()

@end

@implementation SettingsHelpController

@synthesize contentView;
@synthesize faqUrlDao;

- (id)init {
    self = [super init];
    if (self) {
        self.title = NSLocalizedString(@"FAQ", @"");
    }
    return self;
}

- (void) viewDidLoad {
    [super viewDidLoad];

    contentView  = [[UIWebView alloc] initWithFrame:CGRectMake(0, self.topIndex, self.view.frame.size.width, self.view.frame.size.height - self.topIndex)];
    //    webView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    contentView.scalesPageToFit = YES;
    contentView.delegate = self;
    [self.view addSubview:contentView];
    
    faqUrlDao = [[FaqUrlDao alloc] init];
    faqUrlDao.delegate = self;
    faqUrlDao.successMethod = @selector(faqUrlSuccessCallback:);
    faqUrlDao.failMethod = @selector(faqUrlFailCallback:);
    
    [faqUrlDao requestFaqUrl];
    [self showLoading];
}

- (void) faqUrlSuccessCallback:(NSString *) urlToCall {
    NSURL *url = [NSURL URLWithString:urlToCall];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [contentView loadRequest:request];
}

- (void) faqUrlFailCallback:(NSString *) errorMessage {
    [self hideLoading];
}

- (void) webViewDidStartLoad:(UIWebView *)webView {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [self showLoading];
}

- (void) webViewDidFinishLoad:(UIWebView *)webView {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [self hideLoading];
    
    if ([contentView respondsToSelector:@selector(scrollView)]) {
        UIScrollView *scroll = [contentView scrollView];
        float zoom = contentView.bounds.size.width/scroll.contentSize.width;
        [scroll setZoomScale:zoom animated:YES];
    }
}

- (void) webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [self hideLoading];
    //error message
}


/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
