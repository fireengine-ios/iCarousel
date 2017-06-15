//
//  MoveModalFooterView.h
//  Depo
//
//  Created by Mahir on 02/11/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MoveModalFooterDelegate <NSObject>
- (void) moveModalFooterDidSelectMove;
@end

@interface MoveModalFooterView : UIView

@property (nonatomic, strong) id<MoveModalFooterDelegate> delegate;

@end
