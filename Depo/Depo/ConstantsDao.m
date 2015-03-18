//
//  ConstantsDao.m
//  Depo
//
//  Created by Mahir on 18/03/15.
//  Copyright (c) 2015 com.igones. All rights reserved.
//

#import "ConstantsDao.h"
#import "AppDelegate.h"

@implementation ConstantsDao

- (void) requestConstants {
    NSURL *url = [NSURL URLWithString:CONSTANTS_URL];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setDelegate:self];
    
    [self sendGetRequest:request];
}

- (void)requestFinished:(ASIHTTPRequest *)request {
    NSError *error = [request error];
    
    if (!error) {
        NSString *responseStr = [request responseString];
        SBJSON *jsonParser = [SBJSON new];
        NSDictionary *mainDict = [jsonParser objectWithString:responseStr];
        if(mainDict != nil && ![mainDict isKindOfClass:[NSNull class]]) {
            NSString *mobileUploadFolderName = [mainDict objectForKey:@"mobileUploadsFolderName"];
            if(mobileUploadFolderName != nil && ![mobileUploadFolderName isKindOfClass:[NSNull class]]) {
                APPDELEGATE.session.mobileUploadsFolderName = mobileUploadFolderName;
                [self shouldReturnSuccess];
                return;
            }
        }
    }
    [self shouldReturnFailWithMessage:GENERAL_ERROR_MESSAGE];
}

@end
