//
//  AlbumDetailDao.m
//  Depo
//
//  Created by Mahir on 10/13/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "AlbumDetailDao.h"
#import "PhotoAlbum.h"

@implementation AlbumDetailDao

- (void) requestDetailOfAlbum:(NSString *) albumUuid forStart:(int) page andSize:(int) size {
    NSString *albumDetailUrl = [NSString stringWithFormat:ALBUM_DETAIL_URL, albumUuid, page, size];
	NSURL *url = [NSURL URLWithString:albumDetailUrl];
    
    NSLog(@"Album Detail URL: %@", albumDetailUrl);
	
	ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setDelegate:self];
    
    [self sendGetRequest:request];
}

- (void)requestFinished:(ASIHTTPRequest *)request {
	NSError *error = [request error];
	if (!error) {
		NSString *responseEnc = [request responseString];
        NSLog(@"Album Detail Response: %@", responseEnc);
        
		SBJSON *jsonParser = [SBJSON new];
		NSDictionary *mainDict = [jsonParser objectWithString:responseEnc];

        PhotoAlbum *result = [[PhotoAlbum alloc] init];
        if(mainDict != nil && ![mainDict isKindOfClass:[NSNull class]]) {
            NSString *label = [mainDict objectForKey:@"label"];
            NSString *uuid = [mainDict objectForKey:@"uuid"];
            NSNumber *imageCount = [mainDict objectForKey:@"imageCount"];
            NSNumber *videoCount = [mainDict objectForKey:@"videoCount"];
            NSString *lastModifiedDate = [mainDict objectForKey:@"lastModifiedDate"];
            
            result.imageCount = [self intByNumber:imageCount];
            result.videoCount = [self intByNumber:videoCount];
            result.label = [self strByRawVal:label];
            result.uuid = [self strByRawVal:uuid];
            result.lastModifiedDate = [self dateByRawVal:lastModifiedDate];
            
            NSArray *mainArray = [mainDict objectForKey:@"photoList"];
            
            NSMutableArray *content = [[NSMutableArray alloc] init];
            if(mainArray != nil && ![mainArray isKindOfClass:[NSNull class]]) {
                for(NSDictionary *fileDict in mainArray) {
                    [content addObject:[self parseFile:fileDict]];
                }
            }
            result.content = content;
        }
        [self shouldReturnSuccessWithObject:result];
	} else {
        [self shouldReturnFailWithMessage:GENERAL_ERROR_MESSAGE];
	}
}

@end
