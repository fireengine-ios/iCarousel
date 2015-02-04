//
//  SyncRecord.h
//  ContactSyncExample
//
//  Copyright (c) 2015 Turkcell. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "SyncConstants.h"


@interface SyncRecord : NSObject

@property (nonatomic, strong) NSNumber * localId;
@property (nonatomic, strong) NSNumber * remoteId;
@property (nonatomic, strong) NSNumber * localUpdateDate;
@property (nonatomic, strong) NSNumber * remoteUpdateDate;

- (NSDictionary *) asDict;

@end
