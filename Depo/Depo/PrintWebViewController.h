//
//  PrintViewController.h
//  Depo
//
//  Created by Gürhan KODALAK on 28/07/15.
//  Copyright (c) 2015 com.igones. All rights reserved.
//


#import <UIKit/UIKit.h>

@interface PrintWebViewController : UIViewController <UIWebViewDelegate>

- (id) initWithUrl:(NSString *) url withFileList:(NSArray *) fileList;

@end
