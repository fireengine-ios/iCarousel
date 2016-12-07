//
//  RenameDao.m
//  Depo
//
//  Created by Mahir on 7.11.2014.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "RenameDao.h"

@implementation RenameDao

- (void) requestRenameForFile:(NSString *) uuid withNewName:(NSString *) newName {
    NSString *urlStr = [NSString stringWithFormat:RENAME_URL, uuid];
    NSURL *url = [NSURL URLWithString:[urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request addValue:[newName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] forHTTPHeaderField:@"New-Name"];
    request = [self sendPostRequest:request];
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
            else {
                [self requestFailed:response];
            }
        }
    }]];
    [task resume];
    self.currentTask = task;
}

- (void)requestFinished:(NSData *) data {
    NSDictionary *mainDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
    if (mainDict) {
        NSString *lastModifiedDate = [mainDict objectForKey:@"lastModifiedDate"];
        NSString *name = [mainDict objectForKey:@"name"];
        
        MetaFile *finalFileRef = [[MetaFile alloc] init];
        finalFileRef.name = [self strByRawVal:name];
        finalFileRef.lastModified = [self dateByRawVal:lastModifiedDate];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self shouldReturnSuccessWithObject:finalFileRef];
        });
    }
    else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self shouldReturnFailWithMessage:GENERAL_ERROR_MESSAGE];
        });
    }
    

    //    NSError *error = [request error];
//    if (!error) {
//        NSString *responseEnc = [request responseString];
//        NSLog(@"Rename Response: %@", responseEnc);
        
//    } else {
//    }
    
}

@end
