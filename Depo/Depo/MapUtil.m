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
@synthesize curioMappingDict;

- (id) init {
    if(self = [super init]) {
        self.floatingMappingDict = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"FloatingMapping" ofType:@"plist"]];
        self.curioMappingDict = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"CurioMapping" ofType:@"plist"]];
    }
    return self;
}

- (NSArray *) readAddTypesByController:(NSString *) controllerName {
    return [floatingMappingDict objectForKey:controllerName];
}

- (NSString *) readCurioValueByController:(NSString *) controllerName {
    return [curioMappingDict objectForKey:controllerName];
}

@end
