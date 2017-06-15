//
//  ContactSyncFooterElement.h
//  Depo
//
//  Created by Turan Yilmaz on 27/03/2017.
//  Copyright © 2017 com.igones. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomLabel.h"

@interface ContactSyncFooterElement : UIView

- (id) initWithFrame:(CGRect)frame withTitle:(NSString *) title;

@property (nonatomic,strong) CustomLabel *countLabel;

@end
