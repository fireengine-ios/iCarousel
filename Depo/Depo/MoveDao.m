//
//  MoveDao.m
//  Depo
//
//  Created by Mahir on 02/11/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "MoveDao.h"

@implementation MoveDao

- (void) requestMoveFiles:(NSArray *) fileList toFolder:(NSString *) folderUuid {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:MOVE_URL, folderUuid]];
    
    SBJSON *json = [SBJSON new];
    NSString *jsonStr = [json stringWithObject:fileList];
    NSData *postData = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
    
    NSLog(@"Move Payload: %@", jsonStr);
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setPostBody:[postData mutableCopy]];
    [request setDelegate:self];
    
    [self sendPostRequest:request];
}

- (void)requestFinished:(ASIHTTPRequest *)request {
    NSError *error = [request error];
    if (!error) {
        NSString *responseEnc = [request responseString];
        NSLog(@"Move Response: %@", responseEnc);
        [self shouldReturnSuccess];
    } else {
        [self shouldReturnFailWithMessage:GENERAL_ERROR_MESSAGE];
    }
    
}

@end
