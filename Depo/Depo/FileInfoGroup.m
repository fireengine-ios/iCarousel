//
//  FileInfoGroup.m
//  Depo
//
//  Created by Mahir Tarlan on 25/04/16.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import "FileInfoGroup.h"

@implementation FileInfoGroup

@synthesize uniqueKey;
@synthesize rangeRefDate;
@synthesize refDate;
@synthesize rangeStart;
@synthesize rangeEnd;
@synthesize yearStr;
@synthesize monthStr;
@synthesize dayStr;
@synthesize locationInfo;
@synthesize customTitle;
@synthesize fileInfo;
@synthesize fileHashList;
@synthesize groupKey;
@synthesize sequence;
@synthesize groupType;

- (id) init {
    if(self = [super init]) {
        self.fileHashList = [[NSMutableArray alloc] init];
    }
    return self;
}

@end
