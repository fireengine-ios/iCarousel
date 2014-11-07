//
//  FavoriteDao.m
//  Depo
//
//  Created by Mahir on 10/24/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "FavoriteDao.h"

@implementation FavoriteDao

@synthesize newFavFlag;

- (void) requestMetadataForFiles:(NSArray *) uuidList shouldFavorite:(BOOL) favoriteFlag {
    self.newFavFlag = favoriteFlag;
    
	NSURL *url = [NSURL URLWithString:FAVORITE_URL];
	
    NSDictionary *metadataDict = [NSDictionary dictionaryWithObjectsAndKeys:favoriteFlag?@"true":@"false", @"X-Object-Meta-Favourite", nil];
    NSDictionary *payloadDict = [NSDictionary dictionaryWithObjectsAndKeys:uuidList, @"file-list", metadataDict, @"metadata", nil];
    
    SBJSON *json = [SBJSON new];
    NSString *jsonStr = [json stringWithObject:payloadDict];
    NSData *postData = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
    
    NSLog(@"Favorite Payload: %@", jsonStr);
    
	ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setPostBody:[postData mutableCopy]];
    [request setDelegate:self];
    
    [self sendPostRequest:request];
}

- (void)requestFinished:(ASIHTTPRequest *)request {
	NSError *error = [request error];
	
	if (!error) {
		NSString *responseEnc = [request responseString];
		
        NSLog(@"Favorite Response: %@", responseEnc);
        
        [self shouldReturnSuccessWithObject:[NSNumber numberWithBool:self.newFavFlag]];
	} else {
        [self shouldReturnFailWithMessage:GENERAL_ERROR_MESSAGE];
	}
    
}

@end
