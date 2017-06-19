//
//  FeedbackDao.h
//  Depo
//
//  Created by Mahir Tarlan on 18/04/16.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import "BaseDao.h"

@interface FeedbackDao : BaseDao

- (void) requestSendFeedbackWithType:(FeedBackType) type andMessage:(NSString *) message;

@end
