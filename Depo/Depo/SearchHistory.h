//
//  SearchHistory.h
//  Depo
//
//  Created by Mahir on 17.11.2014.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SearchHistory : NSObject

@property (nonatomic, strong) NSDate *searchDate;
@property (nonatomic, strong) NSString *searchText;
@property (nonatomic, strong) NSString *type;

@end
