//
//  AutoSyncOffHeaderView.h
//  Depo
//
//  Created by Mahir Tarlan on 10/01/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AutoSyncOffHeaderDelegate <NSObject>
- (void) autoSyncOffHeaderViewSettingsClicked;
- (void) autoSyncOffHeaderViewCloseClicked;
@end

@interface AutoSyncOffHeaderView : UIView

@property (nonatomic, weak) id<AutoSyncOffHeaderDelegate> delegate;

@end
