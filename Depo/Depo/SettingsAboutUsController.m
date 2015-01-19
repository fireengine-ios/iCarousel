//
//  SettingsAboutUsController.m
//  Depo
//
//  Created by Salih Topcu on 05.01.2015.
//  Copyright (c) 2015 com.igones. All rights reserved.
//

#import "SettingsAboutUsController.h"

@interface SettingsAboutUsController ()

@end

@implementation SettingsAboutUsController

- (id)init
{
    self = [super init];
    if (self) {
        self.title = NSLocalizedString(@"AboutUs", @"");
    }
    
    return self;
}

- (void) viewWillAppear:(BOOL)animated {
    UIWebView *webView  = [[UIWebView alloc] initWithFrame:CGRectMake(0, self.topIndex, 320, self.view.frame.size.height - self.topIndex)];
    webView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    webView.scalesPageToFit = YES;
    webView.autoresizesSubviews = YES;
    webView.delegate = self;
    [self.view addSubview:webView];
    NSURL *url = [NSURL URLWithString:@"http://m.turkcell.com.tr/tr/hakkimizda"];
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
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [self hideLoading];
    //error message
}

@end
