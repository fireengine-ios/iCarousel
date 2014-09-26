//
//  MapUtil.m
//  Depo
//
//  Created by Mahir on 9/26/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "MapUtil.h"

@implementation MapUtil

@synthesize floatingMappingDict;

- (id) init {
    if(self = [super init]) {
        self.floatingMappingDict = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"FloatingMapping" ofType:@"plist"]];
    }
    return self;
}

- (NSArray *) readAddTypesByController:(NSString *) controllerName {
    return [floatingMappingDict objectForKey:controllerName];
}

@end
