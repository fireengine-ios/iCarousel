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
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request addRequestHeader:@"New-Name" value:[newName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    [request setDelegate:self];
    
    [self sendPostRequest:request];
}

- (void)requestFinished:(ASIHTTPRequest *)request {
    NSError *error = [request error];
    if (!error) {
        NSString *responseEnc = [request responseString];
//        NSLog(@"Rename Response: %@", responseEnc);
        
        SBJSON *jsonParser = [SBJSON new];
        NSDictionary *mainDict = [jsonParser objectWithString:responseEnc];
        
        NSString *lastModifiedDate = [mainDict objectForKey:@"lastModifiedDate"];
        NSString *name = [mainDict objectForKey:@"name"];
        
        MetaFile *finalFileRef = [[MetaFile alloc] init];
        finalFileRef.name = [self strByRawVal:name];
        finalFileRef.lastModified = [self dateByRawVal:lastModifiedDate];

        [self shouldReturnSuccessWithObject:finalFileRef];
    } else {
        [self shouldReturnFailWithMessage:GENERAL_ERROR_MESSAGE];
    }
    
}

@end
