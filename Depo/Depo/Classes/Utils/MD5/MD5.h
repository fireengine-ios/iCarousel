//
//  MD5.h
//  Depo_LifeTech
//
//  Created by Alexander Gurin on 9/19/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonDigest.h>


@interface MD5 : NSObject

- (NSString*)hexMD5fromData:(NSData*) data;

- (NSString*)hexMD5fromFileUrl:(NSURL*) url;

@end
