//
//  SyncExperienceController.h
//  Depo
//
//  Created by RDC on 05/04/2017.
//  Copyright © 2017 com.igones. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SyncExperienceController : UIViewController <UIScrollViewDelegate>

- (instancetype)initWithCompletion:(void (^)(void))completion;

@end
