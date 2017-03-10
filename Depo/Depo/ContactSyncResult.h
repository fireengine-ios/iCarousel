//
//  ContactSyncResult.h
//  Depo
//
//  Created by Mahir on 08/02/15.
//  Copyright (c) 2015 com.igones. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppConstants.h"

@interface ContactSyncResult : NSObject <NSCoding>

@property (nonatomic) int clientUpdateCount;
@property (nonatomic) int serverUpdateCount;
@property (nonatomic) int clientNewCount;
@property (nonatomic) int serverNewCount;
@property (nonatomic) int clientDeleteCount;
@property (nonatomic) int serverDeleteCount;
@property (nonatomic) int totalContactOnServer;
@property (nonatomic) int totalContactOnClient;

@property (nonatomic) ContactSyncType syncType;

+ (instancetype)loadData;
- (void)saveData;

@end
