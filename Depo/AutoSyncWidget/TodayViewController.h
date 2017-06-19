//
//  TodayViewController.h
//  AutoSyncWidget
//
//  Created by Mahir on 02/04/15.
//  Copyright (c) 2015 com.igones. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MMWormhole.h"

@interface TodayViewController : UIViewController

@property (nonatomic, strong) IBOutlet UILabel *topLabel;
@property (nonatomic, strong) IBOutlet UILabel *bottomLabel;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *progress;
@property (nonatomic, strong) IBOutlet UIImageView *tickView;
@property (nonatomic, strong) MMWormhole *wormhole;
@property (nonatomic) int finishedCount;
@property (nonatomic) int totalCount;

@end
