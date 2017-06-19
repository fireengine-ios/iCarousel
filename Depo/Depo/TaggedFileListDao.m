//
//  TaggedFileListDao.m
//  Depo
//
//  Created by Mahir Tarlan on 19/07/16.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import "TaggedFileListDao.h"

@implementation TaggedFileListDao

- (void) requestTaggedCellographFiles:(NSString *) tagVal {
    NSString *urlStr = [NSString stringWithFormat:TAGGED_FILE_LIST_URL, tagVal, @"metadata.Image-DateTime", @"ASC", 0, 1000];
    NSURL *url = [NSURL URLWithString:urlStr];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    request = [self sendGetRequest:request];
    
    NSURLSessionDataTask *task = [[DepoHttpManager sharedInstance].urlSession dataTaskWithRequest:request completionHandler:[self createCompletionHandlerWithCompletion:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            IGLog(@"TaggedFileListDao request failed with general error");
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self requestFailed:response];
            });
        }
        else {
            if (![self checkResponseHasError:response]) {
                IGLog(@"TaggedFileListDao request finished successfully");
                NSArray *mainArray = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
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
                [self requestFailed:response];
            }
        }
    }]];
    self.currentTask = task;
    [task resume];
}

@end
