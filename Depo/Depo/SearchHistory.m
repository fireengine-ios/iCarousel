//
//  SearchHistory.m
//  Depo
//
//  Created by Mahir on 17.11.2014.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "SearchHistory.h"

@implementation SearchHistory

@synthesize searchDate;
@synthesize searchText;

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.searchDate forKey:@"searchDate"];
    [encoder encodeObject:self.searchText forKey:@"searchText"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if((self = [super init])) {
        self.searchDate = [decoder decodeObjectForKey:@"searchDate"];
        self.searchText = [decoder decodeObjectForKey:@"searchText"];
    }
    return self;
}

@end
