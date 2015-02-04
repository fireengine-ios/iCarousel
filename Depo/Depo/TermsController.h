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

@interface TermsController : MyModalController <UIWebViewDelegate>

@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) CheckButton *checkButton;
@property (nonatomic, strong) ProvisionDao *provisionDao;

@end
