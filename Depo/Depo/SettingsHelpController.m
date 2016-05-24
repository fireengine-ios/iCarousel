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

- (id)init
{
    self = [super init];
    if (self) {
        self.title = NSLocalizedString(@"FAQ", @"");
    }
    
    return self;
}

- (void) viewWillAppear:(BOOL)animated {
    UIWebView *webView  = [[UIWebView alloc] initWithFrame:CGRectMake(0, self.topIndex, self.view.frame.size.width, self.view.frame.size.height - self.topIndex)];
//    webView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    webView.scalesPageToFit = YES;
    webView.autoresizesSubviews = YES;
    webView.delegate = self;
    [self.view addSubview:webView];
    NSURL *url = [NSURL URLWithString:@"http://trcll.im/zbQxU"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [webView loadRequest:request];
}

- (void) viewWillDisappear:(BOOL)animated {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void) webViewDidStartLoad:(UIWebView *)webView {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [self showLoading];
}

- (void) webViewDidFinishLoad:(UIWebView *)webView {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [self hideLoading];
    
    if ([webView respondsToSelector:@selector(scrollView)]) {
        UIScrollView *scroll = [webView scrollView];
        float zoom = webView.bounds.size.width/scroll.contentSize.width;
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
