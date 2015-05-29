//
//  AlbumListDao.m
//  Depo
//
//  Created by Mahir on 10/9/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "AlbumListDao.h"
#import "PhotoAlbum.h"

@implementation AlbumListDao

- (void) requestAlbumListForStart:(int) start andSize:(int) size {
    NSString *albumListUrl = [NSString stringWithFormat:ALBUM_LIST_URL, start, size];
	NSURL *url = [NSURL URLWithString:albumListUrl];
	
	ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setDelegate:self];
    
    [self sendGetRequest:request];
}

- (void)requestFinished:(ASIHTTPRequest *)request {
	NSError *error = [request error];
	if (!error) {
		NSString *responseEnc = [request responseString];
//        NSLog(@"Album List Response: %@", responseEnc);
        
		SBJSON *jsonParser = [SBJSON new];
		NSArray *mainArray = [jsonParser objectWithString:responseEnc];
        
        NSMutableArray *result = [[NSMutableArray alloc] init];
        
        if(mainArray != nil && ![mainArray isKindOfClass:[NSNull class]]) {
            for(NSDictionary *albumDict in mainArray) {
                NSNumber *albumId = [albumDict objectForKey:@"id"];
                NSString *label = [albumDict objectForKey:@"label"];
                NSString *uuid = [albumDict objectForKey:@"uuid"];
                NSNumber *imageCount = [albumDict objectForKey:@"imageCount"];
                NSNumber *videoCount = [albumDict objectForKey:@"videoCount"];
                
                PhotoAlbum *album = [[PhotoAlbum alloc] init];
                album.albumId = [self longByNumber:albumId];
                album.imageCount = [self intByNumber:imageCount];
                album.videoCount = [self intByNumber:videoCount];
                album.label = [self strByRawVal:label];
                album.uuid = [self strByRawVal:uuid];
                
                NSDictionary *coverDict = [albumDict objectForKey:@"coverPhoto"];
                if(coverDict != nil && ![coverDict isKindOfClass:[NSNull class]]) {
                    album.cover = [self parseFile:coverDict];
                }
                [result addObject:album];
            }
        }
        [self shouldReturnSuccessWithObject:result];
	} else {
        [self shouldReturnFailWithMessage:GENERAL_ERROR_MESSAGE];
	}
}

@end
