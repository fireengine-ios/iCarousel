//
//  AlbumAddPhotosDao.m
//  Depo
//
//  Created by Mahir on 13.11.2014.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "AlbumAddPhotosDao.h"

@implementation AlbumAddPhotosDao

- (void) requestAddPhotos:(NSArray *) uuidList toAlbum:(NSString *) albumUuid {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:ALBUM_ADD_PHOTOS_URL, albumUuid]];
    
    SBJSON *json = [SBJSON new];
    NSString *jsonStr = [json stringWithObject:uuidList];
    NSData *postData = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
    
//    NSLog(@"Album Add Photos Payload: %@", jsonStr);
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request addRequestHeader:@"x-meta-strategy" value:@"1"];
    [request addRequestHeader:@"Content-Type" value:@"application/json; encoding=utf-8"];
    [request setPostBody:[postData mutableCopy]];
    [request setDelegate:self];
    
    [self sendPutRequest:request];
}

- (void)requestFinished:(ASIHTTPRequest *)request {
    NSError *error = [request error];
    
    if (!error) {
        NSString *responseEnc = [request responseString];
        
//        NSLog(@"Album Add Photos Response: %@", responseEnc);
        
        [self shouldReturnSuccess];
    } else {
        [self shouldReturnFailWithMessage:GENERAL_ERROR_MESSAGE];
    }
    
}

@end
