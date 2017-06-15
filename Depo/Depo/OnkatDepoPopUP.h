//
//  OnkatDepoPopUP.h
//  Depo
//
//  Created by Gürhan KODALAK on 24/06/15.
//  Copyright (c) 2015 com.igones. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol OnKatViewDeleagate <NSObject>
- (void) dismissOnKatView;
@end

@interface OnkatDepoPopUP : UIView

@property (nonatomic,strong) id<OnKatViewDeleagate> delegate;


- (id) initWithFrame:(CGRect)frame ;

@end
