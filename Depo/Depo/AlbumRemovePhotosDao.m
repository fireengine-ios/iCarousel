//
//  AlbumRemovePhotosDao.m
//  Depo
//
//  Created by Mahir on 13.11.2014.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "AlbumRemovePhotosDao.h"

@implementation AlbumRemovePhotosDao

- (void) requestRemovePhotos:(NSArray *) uuidList fromAlbum:(NSString *) albumUuid {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:ALBUM_REMOVE_PHOTOS_URL, albumUuid]];
    
    SBJSON *json = [SBJSON new];
    NSString *jsonStr = [json stringWithObject:uuidList];
    NSData *postData = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
    
    NSLog(@"Album Remove Photos Payload: %@", jsonStr);
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setPostBody:[postData mutableCopy]];
    [request setDelegate:self];
    
    [self sendPutRequest:request];
}

- (void)requestFinished:(ASIHTTPRequest *)request {
    NSError *error = [request error];
    
    if (!error) {
        NSString *responseEnc = [request responseString];
        
        NSLog(@"Album Remove Photos Response: %@", responseEnc);
        
        [self shouldReturnSuccess];
    } else {
        [self shouldReturnFailWithMessage:GENERAL_ERROR_MESSAGE];
    }
    
}

@end
