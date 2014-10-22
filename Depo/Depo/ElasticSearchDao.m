//
//  ElasticSearchDao.m
//  Depo
//
//  Created by Mahir on 10/20/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "ElasticSearchDao.h"
#import "AppUtil.h"
#import "FileDetail.h"

@implementation ElasticSearchDao

- (void) requestPhotosForPage:(int) page andSize:(int) size {
    NSString *parentListingUrl = [NSString stringWithFormat:IMG_LISTING_MAIN_URL, @"content_type", @"image%20OR%20video", @"metadata.X-Object-Meta-Image-DateTime", page, size];
	NSURL *url = [NSURL URLWithString:parentListingUrl];
	
	ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setDelegate:self];
    
    [self sendGetRequest:request];
}

- (void)requestFinished:(ASIHTTPRequest *)request {
	NSError *error = [request error];
	
	if (!error) {
		NSString *responseEnc = [request responseString];
		
        NSLog(@"Elastic Search Response: %@", responseEnc);
        
		SBJSON *jsonParser = [SBJSON new];
		NSArray *mainArray = [jsonParser objectWithString:responseEnc];
        
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
