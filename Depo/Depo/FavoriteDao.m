//
//  FavoriteDao.m
//  Depo
//
//  Created by Mahir on 10/24/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "FavoriteDao.h"
#import "AppUtil.h"

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

- (void) requestMetadata:(int) page andSize:(int) size andSortType:(SortType) sortType {
    NSString *parentListingUrl = [NSString stringWithFormat:ELASTIC_LISTING_MAIN_URL, @"metadata.X-Object-Meta-Favourite", @"true", [AppUtil serverSortNameByEnum:sortType], [AppUtil isAscByEnum:sortType] ? @"ASC":@"DESC", page, size];
    NSURL *url = [NSURL URLWithString:parentListingUrl];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setDelegate:self];
    
    returnsList = YES;
    
    [self sendGetRequest:request];
}

- (void)requestFinished:(ASIHTTPRequest *)request {
	NSError *error = [request error];
	
	if (!error) {
		NSString *responseEnc = [request responseString];
        if (returnsList) {
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
            [self shouldReturnSuccess];
        }
	} else {
        [self shouldReturnFailWithMessage:GENERAL_ERROR_MESSAGE];
	}
    
}

@end
