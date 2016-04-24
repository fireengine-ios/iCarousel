//
//  SearchByGroupDao.m
//  Depo
//
//  Created by Mahir Tarlan on 24/04/16.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import "SearchByGroupDao.h"

@implementation SearchByGroupDao

- (void) requestImagesByGroupByPage:(int) page bySize:(int) size byLevel:(int) level byGroupDate:(NSString *) groupDate {
    NSString *urlStr = [NSString stringWithFormat:@"%@?fieldName=content_type&fieldValue=%@&sortOrder=DESC&page=%d&size=%d&level=%d&groupDate=%@", SEARCH_BY_GROUP_URL, @"image%20OR%20video", page, size, level, groupDate];
    NSURL *url = [NSURL URLWithString:urlStr];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setDelegate:self];
    
    [self sendGetRequest:request];
}

- (void)requestFinished:(ASIHTTPRequest *)request {
    NSError *error = [request error];
    if (!error) {
        NSString *responseStr = [request responseString];
        NSLog(@"Search By Group Response: %@", responseStr);
        SBJSON *jsonParser = [SBJSON new];
        NSDictionary *mainDict = [jsonParser objectWithString:responseStr];
        if(mainDict != nil && ![mainDict isKindOfClass:[NSNull class]]) {
            [self shouldReturnSuccessWithObject:nil];
            return;
        }
    }
    [self shouldReturnFailWithMessage:GENERAL_ERROR_MESSAGE];
}

@end
