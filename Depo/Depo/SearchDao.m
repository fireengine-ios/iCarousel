//
//  SearchDao.m
//  Depo
//
//  Created by NCO on 10/24/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "SearchDao.h"
#import "AppUtil.h"
#import "FileDetail.h"

@implementation SearchDao

- (void) requestMetadata:(NSString *)text andPage:(int)page andSize:(int)size andSortType:(SortType)sortType andSearchListType:(int)searchListType {
    NSString *parentListingUrl;
    if (searchListType == SearchListTypeAllFiles)
        parentListingUrl = [NSString stringWithFormat:ADVANCED_SEARCH_URL, text, [AppUtil serverSortNameByEnum:sortType], [AppUtil isAscByEnum:sortType] ? @"ASC":@"DESC", page, size];
    else if (searchListType == SearchListTypePhotosAndVides)
        parentListingUrl = [NSString stringWithFormat:ADVANCED_SEARCH_URL_WITH_CATEGORY, text, [AppUtil serverSortNameByEnum:sortType], [AppUtil isAscByEnum:sortType] ? @"ASC":@"DESC", page, size, @"photos_and_videos"];
    else if (searchListType == SearchListTypeMusics)
        parentListingUrl = [NSString stringWithFormat:ADVANCED_SEARCH_URL_WITH_CATEGORY, text, [AppUtil serverSortNameByEnum:sortType], [AppUtil isAscByEnum:sortType] ? @"ASC":@"DESC", page, size, @"musics"];
    else if (searchListType == SearchListTypeDocumnets)
        parentListingUrl = [NSString stringWithFormat:ADVANCED_SEARCH_URL_WITH_CATEGORY, text, [AppUtil serverSortNameByEnum:sortType], [AppUtil isAscByEnum:sortType] ? @"ASC":@"DESC", page, size, @"documents"];
    
    NSURL *url = [NSURL URLWithString:[parentListingUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setDelegate:self];
    
    returnsList = YES;
    
    [self sendGetRequest:request];
}

- (void)requestFinished:(ASIHTTPRequest *)request {
    NSError *error = [request error];
    
    if (!error) {
        NSString *responseEnc = [request responseString];
        
//        NSLog(@"Search: %@", responseEnc);
        
        SBJSON *jsonParser = [SBJSON new];
        NSDictionary *mainDict = [jsonParser objectWithString:responseEnc];
        
        if(mainDict != nil && ![mainDict isKindOfClass:[NSNull class]]) {
            NSDictionary *mainArray = [mainDict objectForKey:@"found_items"];
            
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
    } else {
        [self shouldReturnFailWithMessage:GENERAL_ERROR_MESSAGE];
    }
}

@end
