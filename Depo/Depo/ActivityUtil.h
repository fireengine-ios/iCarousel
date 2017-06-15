//
//  ActivityUtil.h
//  Depo
//
//  Created by Mahir on 3.12.2014.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Activity.h"

@interface ActivityUtil : NSObject

+ (void) enrichTitleForActivity:(Activity *) activity;
+ (NSMutableArray *) mergedActivityList:(NSMutableArray *) currentList withAdditionalList:(NSArray *) newList;

@end
