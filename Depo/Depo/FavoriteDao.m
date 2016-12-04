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
    
    NSData *postData = [NSJSONSerialization dataWithJSONObject:payloadDict options:NSJSONWritingPrettyPrinted error:nil];
    
//    NSLog(@"Favorite Payload: %@", jsonStr);
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    request = [self sendPostRequest:request];
    [request setHTTPBody:[postData mutableCopy]];
    NSURLSessionDataTask *task = [[DepoHttpManager sharedInstance].urlSession dataTaskWithRequest:request completionHandler:[self createCompletionHandlerWithCompletion:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self requestFailed:response];
            });
        }
        else {
            if (![self checkResponseHasError:response]) {
                [self requestFinished:data];
            }
        }
    }]];
    [task resume];
    self.currentTask = task;
}

- (void) requestMetadata:(int) page andSize:(int) size andSortType:(SortType) sortType {
    NSString *parentListingUrl = [NSString stringWithFormat:ELASTIC_LISTING_MAIN_URL, @"metadata.X-Object-Meta-Favourite", @"true", [AppUtil serverSortNameByEnum:sortType], [AppUtil isAscByEnum:sortType] ? @"ASC":@"DESC", page, size];
    NSURL *url = [NSURL URLWithString:parentListingUrl];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    request = [self sendGetRequest:request];
   
    returnsList = YES;
    NSURLSessionDataTask *task = [[DepoHttpManager sharedInstance].urlSession dataTaskWithRequest:request completionHandler:[self createCompletionHandlerWithCompletion:^(NSData *data, NSURLResponse *response, NSError *error) {
        if ([self checkResponseHasError:response]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self shouldReturnFailWithMessage:GENERAL_ERROR_MESSAGE];
                return ;
            });
        }
        else {
            if (error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self requestFailed:response];
                });
            }
            else {
                if (![self checkResponseHasError:response]) {
                    [self requestFinished:data];
                }
            }
        }
    }]];
    [task resume];
    self.currentTask = task;
    
}

- (void)requestFinished:(NSData *) data {
    if (self.hasError) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self shouldReturnFailWithMessage:GENERAL_ERROR_MESSAGE];
            return;
        });
    }
    if (returnsList) {

        NSArray *mainArray = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        
        NSMutableArray *result = [[NSMutableArray alloc] init];
        if(mainArray != nil && ![mainArray isKindOfClass:[NSNull class]]) {
            for(NSDictionary *fileDict in mainArray) {
                [result addObject:[self parseFile:fileDict]];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [self shouldReturnSuccessWithObject:result];
                
            });
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self shouldReturnFailWithMessage:GENERAL_ERROR_MESSAGE];
            });
        }
    }
    else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self shouldReturnSuccessWithObject:[NSNumber numberWithBool:self.newFavFlag]];
        });
    }
    
//	NSError *error = [request error];
//
//	if (!error) {
//		NSString *responseEnc = [request responseString];
//        } else {
//            [self shouldReturnSuccessWithObject:[NSNumber numberWithBool:self.newFavFlag]];
//        }
//	} else {
//        [self shouldReturnFailWithMessage:GENERAL_ERROR_MESSAGE];
//	}
    
}

@end
