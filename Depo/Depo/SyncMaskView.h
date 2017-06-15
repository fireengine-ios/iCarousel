//
//  SyncMaskView.h
//  Depo
//
//  Created by Mahir Tarlan on 22/03/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SyncMaskViewDelegate <NSObject>
- (void) syncMaskViewShouldClose;
@end

@interface SyncMaskView : UIView

@property (nonatomic, weak) id<SyncMaskViewDelegate> delegate;

@end
