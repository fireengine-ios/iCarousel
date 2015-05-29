//
//  DeleteAlbumsDao.m
//  Depo
//
//  Created by Mahir on 13.11.2014.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "DeleteAlbumsDao.h"

@implementation DeleteAlbumsDao

- (void) requestDeleteAlbums:(NSArray *) uuidList {
    NSURL *url = [NSURL URLWithString:DELETE_ALBUM_URL];
    
    SBJSON *json = [SBJSON new];
    NSString *jsonStr = [json stringWithObject:uuidList];
    NSData *postData = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
    
//    NSLog(@"Album Delete Payload: %@", jsonStr);
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setPostBody:[postData mutableCopy]];
    [request setDelegate:self];
    
    [self sendDeleteRequest:request];
}

- (void)requestFinished:(ASIHTTPRequest *)request {
    NSError *error = [request error];
    
    if (!error) {
        NSString *responseEnc = [request responseString];
        
//        NSLog(@"Album Delete Response: %@", responseEnc);
        
        [self shouldReturnSuccess];
    } else {
        [self shouldReturnFailWithMessage:GENERAL_ERROR_MESSAGE];
    }
    
}

@end
