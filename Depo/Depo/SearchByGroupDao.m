//
//  SearchByGroupDao.m
//  Depo
//
//  Created by Mahir Tarlan on 24/04/16.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import "SearchByGroupDao.h"

@implementation SearchByGroupDao

- (void) requestImagesByGroupByPage:(int) page bySize:(int) size byLevel:(int) level byGroupDate:(NSString *) groupDate byGroupSize:(NSNumber *) groupSize bySort:(SortType) sortType {
    NSString *sortOrder = sortType == SortTypeDateAsc ? @"ASC" : @"DESC";
    NSString *urlStr = [NSString stringWithFormat:@"%@?fieldName=content_type&fieldValue=%@&sortOrder=%@&page=%d&size=%d&level=%d&%@&%@", SEARCH_BY_GROUP_URL, @"image%20OR%20video", sortOrder, page, size, level, groupDate != nil ? [NSString stringWithFormat:@"groupDate=%@", groupDate] : @"", groupSize != nil ? [NSString stringWithFormat:@"groupSize=%d", [groupSize intValue]]: @""];
    NSURL *url = [NSURL URLWithString:urlStr];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    //    request.tag = REQ_TAG_FOR_GROUPED_PHOTOS;
    request = [self sendGetRequest:request];
    
    NSURLSessionDataTask *task = [[DepoHttpManager sharedInstance].urlSession dataTaskWithRequest:request completionHandler:[self createCompletionHandlerWithCompletion:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self requestFailed:response];
            });
        }
        else {
            if (![self checkResponseHasError:response]) {
                NSArray *mainArray = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
                if(mainArray != nil && ![mainArray isKindOfClass:[NSNull class]]) {
                    NSMutableArray *result = [[NSMutableArray alloc] init];
                    for(NSDictionary *fileGroupDict in mainArray) {
                        [result addObject:[self parseFileInfoGroup:fileGroupDict]];
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
                [self requestFailed:response];
            }
        }
    }]];
    self.currentTask = task;
    [task resume];
}

//- (void)requestFinished:(ASIHTTPRequest *)request {
//    NSError *error = [request error];
//    if (!error) {
//        NSString *responseStr = [request responseString];
//        NSLog(@"Search By Group Response: %@", responseStr);
//        SBJSON *jsonParser = [SBJSON new];
//        NSArray *mainArray = [jsonParser objectWithString:responseStr];
//        if(mainArray != nil && ![mainArray isKindOfClass:[NSNull class]]) {
//            NSMutableArray *result = [[NSMutableArray alloc] init];
//            for(NSDictionary *fileGroupDict in mainArray) {
//                [result addObject:[self parseFileInfoGroup:fileGroupDict]];
//            }
//            [self shouldReturnSuccessWithObject:result];
//            return;
//        }
//    }
//    [self shouldReturnFailWithMessage:GENERAL_ERROR_MESSAGE];
//}

@end
