//
//  VideofyPreparationInfoView.h
//  Depo
//
//  Created by Mahir Tarlan on 10/07/16.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol VideofyPreparationInfoDelegate <NSObject>
- (void) videofyPreparationViewShouldDismiss;
@end

@interface VideofyPreparationInfoView : UIView

@property (nonatomic, weak) id<VideofyPreparationInfoDelegate> delegate;

@end
