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
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    request = [self sendPostRequest:request];
    
    NSURLSessionDataTask *task = [[DepoHttpManager sharedInstance].urlSession dataTaskWithRequest:request completionHandler:[self createCompletionHandlerWithCompletion:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self requestFailed:response];
            });
        }
        else {
            if (![self checkResponseHasError:response]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSDictionary *mainDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
                    if(mainDict != nil && ![mainDict isKindOfClass:[NSNull class]]) {
                        NSString *mobileUploadFolderName = [mainDict objectForKey:@"mobileUploadsFolderName"];
                        if(mobileUploadFolderName != nil && ![mobileUploadFolderName isKindOfClass:[NSNull class]]) {
                            APPDELEGATE.session.mobileUploadsFolderName = mobileUploadFolderName;
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [self shouldReturnSuccess];
                            });
                        }
                    }
                    else{
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self shouldReturnFailWithMessage:GENERAL_ERROR_MESSAGE];
                        });
                    }
                });
            }
        }
    }]];
    self.currentTask = task;
    [task resume];
}

@end
