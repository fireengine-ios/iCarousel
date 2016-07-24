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
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setDelegate:self];
    
    [self sendGetRequest:request];
}

- (void)requestFinished:(ASIHTTPRequest *)request {
    NSError *error = [request error];
    
    if (!error) {
        NSString *responseEnc = [request responseString];
        IGLog(@"TaggedFileListDao request finished successfully");
        SBJSON *jsonParser = [SBJSON new];
        NSArray *mainArray = [jsonParser objectWithString:responseEnc];
        
        NSMutableArray *result = [[NSMutableArray alloc] init];
        if(mainArray != nil && ![mainArray isKindOfClass:[NSNull class]]) {
            for(NSDictionary *fileDict in mainArray) {
                [result addObject:[self parseFile:fileDict]];
            }
        }
        [self shouldReturnSuccessWithObject:result];
    } else {
        IGLog(@"TaggedFileListDao request failed with general error");
        [self shouldReturnFailWithMessage:GENERAL_ERROR_MESSAGE];
    }
    
}

@end
