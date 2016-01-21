//
//  RevisitedCurrentSubscriptionCell.h
//  Depo
//
//  Created by Mahir on 14/01/16.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Subscription.h"

@protocol RevisitedCurrentSubscriptionCellDelegate <NSObject>
- (void) revisitedCurrentSubscriptionCellDidSelectCancelForSubscription:(Subscription *) sRef;
@end

@interface RevisitedCurrentSubscriptionCell : UITableViewCell

@property (nonatomic, weak) id<RevisitedCurrentSubscriptionCellDelegate> delegate;
@property (nonatomic, strong) Subscription *subscription;

- (id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withSubscription:(Subscription *) _subscription;

@end
