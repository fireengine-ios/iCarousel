//
//  VideofyFooterView.h
//  Depo
//
//  Created by Mahir Tarlan on 08/07/16.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol VideofyFooterDelegate <NSObject>
- (void) videofyFooterDeleteClicked;
- (void) videofyFooterMusicClicked;
@end

@interface VideofyFooterView : UIView

@property (nonatomic, weak) id<VideofyFooterDelegate> delegate;

@end
