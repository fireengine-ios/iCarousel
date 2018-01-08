//
//  MyTextView.h
//  CropyMain
//
//  Created by Selim Savsar on 09/03/17.
//  Copyright © 2017 Alper KIRDÖK. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MyTextViewProtocol

- (void)textViewBeganWithEvent: (UIEvent *)event Touches: (NSSet *)touches;
- (void)textViewMovedWithEvent: (UIEvent *)event Touches: (NSSet *)touches;
- (void)textViewEndedWithEvent: (UIEvent *)event Touches: (NSSet *)touches;


@end

@interface MyTextView : UITextView

@property (nonatomic, assign) id<MyTextViewProtocol> delegate;

@end
