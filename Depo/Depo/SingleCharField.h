//
//  SingleCharField.h
//  Depo
//
//  Created by Mahir on 12/01/16.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SingleCharFieldBackDelegate <NSObject>
- (void) emptyBackClickedForField:(int) fieldTag;
@end

@interface SingleCharField : UITextField

@property (nonatomic, weak) id<SingleCharFieldBackDelegate> backDelegate;

@end
