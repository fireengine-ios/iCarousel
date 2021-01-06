//
//  BackupVersion.h
//  ContactSyncExample
//
//  Created by Enes Kokturk on 16.09.2020.
//  Copyright © 2020 Valven. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BackupVersion : NSObject

@property (strong) NSString *created;
@property (strong) NSString *modified;
@property BOOL isLast;
@property (strong) NSNumber *objectId;
@property (strong) NSString *key;
@property (strong) NSString *total;


- (instancetype)initWithDictionary:(NSDictionary*)json;

@end
