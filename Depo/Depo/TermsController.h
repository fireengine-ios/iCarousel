//
//  TermsController.h
//  Depo
//
//  Created by Mahir on 01/02/15.
//  Copyright (c) 2015 com.igones. All rights reserved.
//

#import "MyModalController.h"
#import "CheckButton.h"
#import "ProvisionDao.h"
#import "SimpleButton.h"

@interface TermsController : MyModalController <UIWebViewDelegate, CheckButtonDelegate>

@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) CheckButton *checkButton;
@property (nonatomic, strong) ProvisionDao *provisionDao;
@property (nonatomic, strong) SimpleButton *acceptButton;

@end
