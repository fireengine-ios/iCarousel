//
//  MD5.m
//  Depo_LifeTech
//
//  Created by Alexander Gurin on 9/19/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

#import "MD5.h"

@implementation MD5

- (NSString*)hexMD5fromData:(NSData*) data {
    
    unsigned char md5Buffer[CC_MD5_DIGEST_LENGTH];
    CC_LONG lenght = (CC_LONG) data.length;
    CC_MD5(data.bytes, lenght, md5Buffer);
    
    return  [self hexStringFrom: md5Buffer];
}

- (NSString*)hexMD5fromFileUrl:(NSURL*) url {
    
    int bufferSize = CC_MD5_BLOCK_BYTES/2 * 1024 * 1024;
    
    CC_MD5_CTX hashObject;
    CC_MD5_Init(&hashObject);
    
    NSError * error = nil;
    NSFileHandle * handler = [NSFileHandle fileHandleForReadingFromURL:url
                                                                 error:&error];
    NSData * data = nil;
    do {
        data = [handler readDataOfLength:bufferSize];
        CC_MD5_Update(&hashObject, data.bytes, (CC_LONG) data.length);
    } while (error == nil && data.length > 0);
    
    unsigned char md5resultBuffer[CC_MD5_DIGEST_LENGTH];
    CC_MD5_Final(md5resultBuffer, &hashObject);
    
    return [self hexStringFrom:md5resultBuffer];
}

- (NSString*)hexStringFrom:(unsigned char*) hash {
    int size = CC_MD5_DIGEST_LENGTH;
    NSMutableString * result = [NSMutableString stringWithCapacity:size*2];
    
    for (int i = 0; i< size; i++) {
        [result appendFormat:@"%02x",hash[i]];
    }
    return  result;
}

@end
