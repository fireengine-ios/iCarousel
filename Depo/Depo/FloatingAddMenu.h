//
//  FloatingAddMenu.h
//  Depo
//
//  Created by Mahir on 9/25/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AddTypeButton.h"

@protocol FloatingAddDelegate <NSObject>
- (void) floatingMenuDidTriggerAddFolder;
- (void) floatingMenuDidTriggerAddAlbum;
- (void) floatingMenuDidTriggerAddMusic;
- (void) floatingMenuDidTriggerAddPhoto;
- (void) floatingMenuDidTriggerCamera;
@end

@interface FloatingAddMenu : UIView {
    int buttonHeight;
}

@property (nonatomic, strong) id<FloatingAddDelegate> delegate;
@property (nonatomic, strong) NSMutableArray *buttons;
@property (nonatomic) CGPoint initialPoint;

- (id)initWithFrame:(CGRect)frame withBasePoint:(CGPoint) basePoint;
- (void) loadButtons:(NSArray *) buttonTypes;
- (void) presentWithAnimation;
- (void) dismissWithAnimation;

@end
