//
//  SyncLogger.h
//  ContactSyncExample
//
//  Copyright (c) 2015 Valven. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SyncLogger : NSObject

- (void)startLogging:(NSString*)prefix;
- (void)log:(NSString*)msg;
- (void)stopLogging;

+ (id) shared;

@end
