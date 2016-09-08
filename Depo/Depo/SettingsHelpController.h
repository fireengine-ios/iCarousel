//
//  SettingsHelpController.h
//  Depo
//
//  Created by Salih Topcu on 23.09.2014.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "MyViewController.h"
#import "FaqUrlDao.h"

@interface SettingsHelpController : MyViewController <UIWebViewDelegate>

@property (nonatomic, strong) UIWebView *contentView;
@property (nonatomic, strong) FaqUrlDao *faqUrlDao;

@end
