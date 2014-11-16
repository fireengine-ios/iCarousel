//
//  AlbumRemovePhotosDao.m
//  Depo
//
//  Created by Mahir on 13.11.2014.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "AlbumRemovePhotosDao.h"
#import "PhotoAlbum.h"

@implementation AlbumRemovePhotosDao

- (void) requestRemovePhotos:(NSArray *) uuidList fromAlbum:(NSString *) albumUuid {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:ALBUM_REMOVE_PHOTOS_URL, albumUuid]];
    
    SBJSON *json = [SBJSON new];
    NSString *jsonStr = [json stringWithObject:uuidList];
    NSData *postData = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
    
    NSLog(@"Album Remove Photos Payload: %@", jsonStr);
    
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
        
        NSLog(@"Album Remove Photos Response: %@", responseEnc);
        
        SBJSON *jsonParser = [SBJSON new];
        NSDictionary *mainDict = [jsonParser objectWithString:responseEnc];
        
        PhotoAlbum *album = [[PhotoAlbum alloc] init];

        if(mainDict != nil && ![mainDict isKindOfClass:[NSNull class]]) {
            NSString *label = [mainDict objectForKey:@"label"];
            NSString *uuid = [mainDict objectForKey:@"uuid"];
            NSNumber *imageCount = [mainDict objectForKey:@"imageCount"];
            NSNumber *videoCount = [mainDict objectForKey:@"videoCount"];
            
            album.imageCount = [self intByNumber:imageCount];
            album.videoCount = [self intByNumber:videoCount];
            album.label = [self strByRawVal:label];
            album.uuid = [self strByRawVal:uuid];
            
            NSDictionary *coverDict = [mainDict objectForKey:@"coverPhoto"];
            if(coverDict != nil && ![coverDict isKindOfClass:[NSNull class]]) {
                album.cover = [self parseFile:coverDict];
            }
        }

        [self shouldReturnSuccessWithObject:album];
    } else {
        [self shouldReturnFailWithMessage:GENERAL_ERROR_MESSAGE];
    }
    
}

@end
