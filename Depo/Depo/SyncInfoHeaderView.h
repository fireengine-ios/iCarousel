//
//  SyncInfoHeaderView.h
//  Depo
//
//  Created by Mahir on 28/03/15.
//  Copyright (c) 2015 com.igones. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomLabel.h"

@interface SyncInfoHeaderView : UIView

@property (nonatomic, strong) CustomLabel *infoLabel;
@property (nonatomic, strong) UIActivityIndicatorView *indicator;

- (void) reCheckInfo;
- (void) show;
- (void) hide;

@end
