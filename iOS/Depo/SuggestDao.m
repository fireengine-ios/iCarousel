//
//  SuggestDao.m
//  Depo
//
//  Created by Seyma Tanoglu on 21/12/16.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import "SuggestDao.h"
#import "AppDelegate.h"
#import "SearchHistory.h"

@implementation SuggestDao

- (void) requestSuggestion:(NSString*) key {
    NSString *urlStr = [NSString stringWithFormat:SUGGEST_URL, key] ;
    NSString *encodedURLString = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:encodedURLString];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    
    [request setHTTPMethod:@"GET"];
    [request setTimeoutInterval:30];
    [request addValue:@"application/json; encoding=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setValue:APPDELEGATE.session.authToken forHTTPHeaderField:@"X-Auth-Token"];
    
    NSURLSessionDataTask *task = [[DepoHttpManager sharedInstance].urlSession dataTaskWithRequest:request completionHandler:[self createCompletionHandlerWithCompletion:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self requestFailed:response];
            });
        }
        else {
            if (![self checkResponseHasError:response]) {
                if (data && ![data isKindOfClass:[NSNull class]]) {
                    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                    if(dict) {
                        NSLog(@"suggestions: %@", dict);
                        NSMutableArray* list = [[NSMutableArray alloc] init];
                        for (NSDictionary* d in dict) {
                            SearchHistory *s = [[SearchHistory alloc] init];
                            s.searchText = d[@"highlightedText"];
                            if (s.searchText == nil) {
                                s.searchText = d[@"text"];
                            }
                            NSString* type = [d objectForKey:@"type"];
                            if ([type isKindOfClass:[NSNull class]]) type = @"";
                            s.type = type;
                            [list addObject:s];
                        }
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self shouldReturnSuccessWithObject:list];
                        });
                    }
                    else {
                        NSString* logText = [NSString stringWithFormat: @"suggestions returned null: %@", data];
                        IGLog(logText);
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self shouldReturnFailWithMessage:GENERAL_ERROR_MESSAGE];
                        });
                        
                    }
                }
            }
        }
    }]];
    self.currentTask = task;
    [task resume];
}

@end
