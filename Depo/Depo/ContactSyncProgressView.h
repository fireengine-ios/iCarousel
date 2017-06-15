//
//  ContactSyncProgressView.h
//  Depo
//
//  Created by Turan Yilmaz on 26/03/2017.
//  Copyright © 2017 com.igones. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XYPieChart.h"
#import "CustomLabel.h"
#import "CircleProgressBar.h"

@interface ContactSyncProgressView : UIView

- (id) initWithFrame:(CGRect)frame;

@property (nonatomic,strong) CircleProgressBar *progressBar;
@property (nonatomic,strong) XYPieChart *pieChart;
@property (nonatomic,strong) NSMutableArray *statusList;
@property (nonatomic,strong) NSArray *statusColors;
@property (nonatomic,strong) CustomLabel *percentLabel;
@property (nonatomic,strong) CustomLabel *progressLabel;

@end
