//
//  CellographSegmentView.h
//  Depo
//
//  Created by Mahir Tarlan on 18/07/16.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SimpleButton.h"

@protocol CellographSegmentDelegate <NSObject>
- (void) cellographHeaderDidSelectCurrent;
- (void) cellographHeaderDidSelectHistory;
@end

@interface CellographSegmentView : UIView

@property (nonatomic, weak) id<CellographSegmentDelegate> delegate;
@property (nonatomic, strong) SimpleButton *currentButton;
@property (nonatomic, strong) SimpleButton *historyButton;

@end
