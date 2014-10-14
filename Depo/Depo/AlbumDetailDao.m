//
//  AlbumDetailDao.m
//  Depo
//
//  Created by Mahir on 10/13/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "AlbumDetailDao.h"

@implementation AlbumDetailDao

- (void) requestDetailOfAlbum:(long) albumId forStart:(int) page andSize:(int) size {
    NSString *albumDetailUrl = [NSString stringWithFormat:ALBUM_DETAIL_URL, (int)albumId, page, size];
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
		NSArray *mainArray = [mainDict objectForKey:@"photoList"];
        
        NSMutableArray *result = [[NSMutableArray alloc] init];
        
        if(mainArray != nil && ![mainArray isKindOfClass:[NSNull class]]) {
            for(NSDictionary *fileDict in mainArray) {
                [result addObject:[self parseFile:fileDict]];
            }
        }

        [self shouldReturnSuccessWithObject:result];
	} else {
        [self shouldReturnFailWithMessage:GENERAL_ERROR_MESSAGE];
	}
}

@end
