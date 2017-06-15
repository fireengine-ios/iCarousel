//
//  MapUtil.h
//  Depo
//
//  Created by Mahir on 9/26/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MapUtil : NSObject

@property (nonatomic, strong) NSDictionary *floatingMappingDict;
@property (nonatomic, strong) NSDictionary *curioMappingDict;

- (NSArray *) readAddTypesByController:(NSString *) controllerName;
- (NSString *) readCurioValueByController:(NSString *) controllerName;

@end
