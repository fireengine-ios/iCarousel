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

- (void) requestPhotosAndVideosForPage:(int) page andSize:(int) size andSortType:(SortType) sortType {
    [self requestPhotosAndVideosForPage:page andSize:size andSortType:sortType isMinimal:NO];
}

- (void) requestPhotosAndVideosForPage:(int) page andSize:(int) size andSortType:(SortType) sortType isMinimal:(BOOL) minimalFlag {
    sortType = [self resetSortType:sortType];
    
    NSString *parentListingUrl = [NSString stringWithFormat:ELASTIC_LISTING_MAIN_URL, @"content_type", @"image%20OR%20video", [AppUtil serverSortNameByEnum:sortType forPhotosOnly:YES], [AppUtil isAscByEnum:sortType] ? @"ASC":@"DESC", page, size];
    if(minimalFlag) {
        parentListingUrl = [NSString stringWithFormat:@"%@&minified=true", parentListingUrl];
    }
    NSURL *url = [NSURL URLWithString:parentListingUrl];
    
    IGLog(@"[GET] ElasticSearchDao requestPhotosAndVideosForPage called");
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    request = [self sendGetRequest:request];
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

- (void) requestPhotosForPage:(int) page andSize:(int) size andSortType:(SortType) sortType {
    [self requestPhotosForPage:page andSize:size andSortType:sortType isMinimal:NO];
}

- (void) requestPhotosForPage:(int) page andSize:(int) size andSortType:(SortType) sortType isMinimal:(BOOL) minimalFlag {
    sortType = [self resetSortType:sortType];
    
    NSString *parentListingUrl = [NSString stringWithFormat:ELASTIC_LISTING_MAIN_URL, @"content_type", @"image", [AppUtil serverSortNameByEnum:sortType forPhotosOnly:YES], [AppUtil isAscByEnum:sortType] ? @"ASC":@"DESC", page, size];
    if(minimalFlag) {
        parentListingUrl = [NSString stringWithFormat:@"%@&minified=true", parentListingUrl];
    }
    NSURL *url = [NSURL URLWithString:parentListingUrl];

    IGLog(@"[GET] ElasticSearchDao requestPhotosForPage called");
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    request = [self sendGetRequest:request];
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

- (void) requestMusicForPage:(int) page andSize:(int) size andSortType:(SortType) sortType {
    NSString *parentListingUrl = [NSString stringWithFormat:ELASTIC_LISTING_MAIN_URL, @"content_type", @"audio", [AppUtil serverSortNameByEnum:sortType], [AppUtil isAscByEnum:sortType] ? @"ASC":@"DESC", page, size];
    //    NSLog(@"MUSIC REQ URL: %@", parentListingUrl);
    NSURL *url = [NSURL URLWithString:parentListingUrl];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    request = [self sendGetRequest:request];
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

- (void) requestDocForPage:(int) page andSize:(int) size andSortType:(SortType) sortType {
    sortType = [self resetSortType:sortType];
    
    NSString *parentListingUrl = [NSString stringWithFormat:ELASTIC_LISTING_MAIN_URL, @"content_type", @"application%20OR%20text", [AppUtil serverSortNameByEnum:sortType], [AppUtil isAscByEnum:sortType] ? @"ASC":@"DESC", page, size];
    NSURL *url = [NSURL URLWithString:parentListingUrl];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    request = [self sendGetRequest:request];
    NSURLSessionDataTask *task = [[DepoHttpManager sharedInstance].urlSession dataTaskWithRequest:request completionHandler:[self createCompletionHandlerWithCompletion:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self requestFailed:response];
            });
        }
        else {
            [self requestFinished:data];
        }

    }]];
    [task resume];
    self.currentTask = task;
}

- (void) requestCropNShareForPage:(int) page andSize:(int) size andSortType:(SortType) sortType {
    sortType = [self resetSortType:sortType];
    
    NSString *parentListingUrl = [NSString stringWithFormat:ELASTIC_LISTING_MAIN_URL, @"metadata.Cropy", @"true", [AppUtil serverSortNameByEnum:sortType forPhotosOnly:YES], [AppUtil isAscByEnum:sortType] ? @"ASC":@"DESC", page, size];
    NSURL *url = [NSURL URLWithString:parentListingUrl];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    request = [self sendGetRequest:request];
    NSURLSessionDataTask *task = [[DepoHttpManager sharedInstance].urlSession dataTaskWithRequest:request completionHandler:[self createCompletionHandlerWithCompletion:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self requestFailed:response];
            });
        }
        else {
            [self requestFinished:data];
        }

    }]];
    [task resume];
    self.currentTask = task;
}

- (void)requestFinished:(NSData *)data {
    //NSError *error = [request error];
    IGLog(@"ElasticSearchDao request successfully finished");
    NSArray *mainArray = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
    
    NSMutableArray *result = [[NSMutableArray alloc] init];
    if(mainArray != nil && [mainArray isKindOfClass:[NSArray class]]) {
        for(NSDictionary *fileDict in mainArray) {
            if([fileDict isKindOfClass:[NSDictionary class]]) {
                [result addObject:[self parseFile:fileDict]];
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self shouldReturnSuccessWithObject:result];
        });
    }
    else {
        IGLog(@"ElasticSearchDao requestFinished with error");
        [self shouldReturnFailWithMessage:GENERAL_ERROR_MESSAGE];
    }
}

@end
