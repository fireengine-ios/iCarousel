//
//  CellographOrdersDao.m
//  Depo
//
//  Created by Mahir Tarlan on 19/07/16.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import "CellographOrdersDao.h"

@implementation CellographOrdersDao

- (void) requestOrdersForId:(NSString *) cellographId {
    NSString *urlStr = [NSString stringWithFormat:@"http://api.cellograf.com/get/?method=getOrder&Cellograf_ID=%@", cellographId];
    NSURL *url = [NSURL URLWithString:urlStr];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setDelegate:self];
    [request setRequestMethod:@"GET"];
    [request setTimeOutSeconds:30];
    [request addRequestHeader:@"Accept" value:@"application/json"];
    [request addRequestHeader:@"Content-Type" value:@"application/json; encoding=utf-8"];
    [request startAsynchronous];
}

- (void) requestFinished:(ASIHTTPRequest *)request {
    NSError *error = [request error];
    if (!error) {
        NSString *responseStr = [request responseString];
        NSLog(@"CellographOrdersDao requestOrdersForId Response: %@", responseStr);
        IGLog(@"CellographOrdersDao requestOrdersForId request finished successfully");
        [self shouldReturnSuccess];
        return;
    }
    IGLog(@"CellographOrdersDao requestOrdersForId failed with general error");
    [self shouldReturnFailWithMessage:GENERAL_ERROR_MESSAGE];
}

@end
