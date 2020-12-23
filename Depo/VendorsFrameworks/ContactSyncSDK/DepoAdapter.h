//
//  DepoAdapter.h
//  ContactSyncExample
//
//  Created by Furkan Bahceci on 14.01.2020.
//  Copyright © 2020 Valven. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DepoAdapter : NSObject

+ (void)getUploadURL:(void (^)(id, BOOL))callback;
+ (void)uploadVCF:(NSString*)deviceId url:(NSString*)url source:(NSString*)source callback:(void (^)(id, BOOL))callback;

@end

NS_ASSUME_NONNULL_END
