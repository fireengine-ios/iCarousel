//
//  FeedbackChoiceCell.h
//  Depo
//
//  Created by Mahir Tarlan on 18/04/16.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppConstants.h"

@interface FeedbackChoiceCell : UITableViewCell

- (id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withType:(FeedBackType) choiceType;

@end
