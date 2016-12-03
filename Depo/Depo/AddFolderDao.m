//
//  AddFolderDao.m
//  Depo
//
//  Created by Mahir on 9/30/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "AddFolderDao.h"
#import "Util.h"

@implementation AddFolderDao

- (void) requestAddFolderToParent:(NSString *) parentUuid withName:(NSString *) folderName {
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:ADD_FOLDER_URL, parentUuid]];
	
    NSDictionary *metadata = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO], @"X-Object-Meta-Favourite", nil];
    NSDictionary *payload = [NSDictionary dictionaryWithObjectsAndKeys:metadata, @"metadata", nil];
    
    NSData *postData = [NSJSONSerialization dataWithJSONObject:payload options:NSJSONWritingPrettyPrinted error:nil];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    request = [self sendPostRequest:request];
    [request setHTTPBody:postData];
    [request setValue:[[Util cleanSpecialCharacters:folderName] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]  forHTTPHeaderField:@"Folder-Name"];
    NSURLSessionDataTask *task = [[DepoHttpManager sharedInstance].urlSession dataTaskWithRequest:request completionHandler:[self createCompletionHandlerWithCompletion:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self requestFailed:response];
            });
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (![self checkResponseHasError:response]) {
                    [self shouldReturnSuccess];
                }
            });
        }
    }]];
    self.currentTask = task;
    [task resume];
}

//- (void)requestFinished:(NSData *)data withResponse:(NSURLResponse *) response {
//    [self shouldReturnSuccess];
//}

@end
