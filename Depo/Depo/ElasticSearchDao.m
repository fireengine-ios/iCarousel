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

- (void) requestPhotosForPage:(int) page andSize:(int) size andSortType:(SortType) sortType {
    [self requestPhotosForPage:page andSize:size andSortType:sortType isMinimal:NO];
}

- (void) requestPhotosForPage:(int) page andSize:(int) size andSortType:(SortType) sortType isMinimal:(BOOL) minimalFlag {
    sortType = [self resetSortType:sortType];
    
    NSString *parentListingUrl = [NSString stringWithFormat:ELASTIC_LISTING_MAIN_URL, @"content_type", @"image%20OR%20video", [AppUtil serverSortNameByEnum:sortType forPhotosOnly:YES], [AppUtil isAscByEnum:sortType] ? @"ASC":@"DESC", page, size];
    if(minimalFlag) {
        parentListingUrl = [NSString stringWithFormat:@"%@&minified=true", parentListingUrl];
    }
    NSURL *url = [NSURL URLWithString:parentListingUrl];

    IGLog(@"[GET] ElasticSearchDao requestPhotosForPage called");

    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setDelegate:self];
    
    [self sendGetRequest:request];
}

- (void) requestMusicForPage:(int) page andSize:(int) size andSortType:(SortType) sortType {
    NSString *parentListingUrl = [NSString stringWithFormat:ELASTIC_LISTING_MAIN_URL, @"content_type", @"audio", [AppUtil serverSortNameByEnum:sortType], [AppUtil isAscByEnum:sortType] ? @"ASC":@"DESC", page, size];
    //    NSLog(@"MUSIC REQ URL: %@", parentListingUrl);
    NSURL *url = [NSURL URLWithString:parentListingUrl];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setDelegate:self];
    
    [self sendGetRequest:request];
}

- (void) requestDocForPage:(int) page andSize:(int) size andSortType:(SortType) sortType {
    sortType = [self resetSortType:sortType];
    
    NSString *parentListingUrl = [NSString stringWithFormat:ELASTIC_LISTING_MAIN_URL, @"content_type", @"application%20OR%20text", [AppUtil serverSortNameByEnum:sortType], [AppUtil isAscByEnum:sortType] ? @"ASC":@"DESC", page, size];
    NSURL *url = [NSURL URLWithString:parentListingUrl];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setDelegate:self];
    
    [self sendGetRequest:request];
}

- (void) requestCropNShareForPage:(int) page andSize:(int) size andSortType:(SortType) sortType {
    sortType = [self resetSortType:sortType];
    
    NSString *parentListingUrl = [NSString stringWithFormat:ELASTIC_LISTING_MAIN_URL, @"metadata.Cropy", @"true", [AppUtil serverSortNameByEnum:sortType forPhotosOnly:YES], [AppUtil isAscByEnum:sortType] ? @"ASC":@"DESC", page, size];
    NSURL *url = [NSURL URLWithString:parentListingUrl];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setDelegate:self];
    
    [self sendGetRequest:request];
}

- (void)requestFinished:(ASIHTTPRequest *)request {
    NSError *error = [request error];
    
    if (!error) {
        NSString *responseEnc = [request responseString];
        
        IGLog(@"ElasticSearchDao request successfully finished");

                NSLog(@"Elastic Search Response: %@", responseEnc);
        
        SBJSON *jsonParser = [SBJSON new];
        NSArray *mainArray = [jsonParser objectWithString:responseEnc];
        
        NSMutableArray *result = [[NSMutableArray alloc] init];
        if(mainArray != nil && [mainArray isKindOfClass:[NSArray class]]) {
            for(NSDictionary *fileDict in mainArray) {
                if([fileDict isKindOfClass:[NSDictionary class]]) {
                    [result addObject:[self parseFile:fileDict]];
                }
            }
        }
        [self shouldReturnSuccessWithObject:result];
    } else {
        IGLog(@"ElasticSearchDao requestFinished with error");
        [self shouldReturnFailWithMessage:GENERAL_ERROR_MESSAGE];
    }
    
}

@end
