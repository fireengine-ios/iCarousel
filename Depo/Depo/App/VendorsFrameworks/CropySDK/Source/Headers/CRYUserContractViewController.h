//
//  CRYUserContractViewController.h
//  CropyMain
//
//  Created by Ugur Eratalar on 18/07/16.
//  Copyright © 2016 Alper KIRDÖK. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SLDUtils.h"
#import "CRYShareViewController.h"

@interface CRYUserContractViewController : UIViewController {
    
    //** webView
    __weak IBOutlet UIWebView *webViewContract;
    
    //** label
    __weak IBOutlet UILabel *labelHeader;
    __weak IBOutlet UIButton *backButtonOutlet;
}

#pragma mark - Properties
+(CRYUserContractViewController*) getInstance;


/* string */
@property (nonatomic, strong)NSString *htmlString;

/* integer */
@property (nonatomic, assign) NSInteger idFromEulaGetService;

/* viewController */
@property (nonatomic, strong) CRYShareViewController *shareViewController;

#pragma mark - Button Actions
- (IBAction)buttonDissmissWebViewTapped:(id)sender;

@end
