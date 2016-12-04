//
//  UpdateEmailDao.m
//  Depo
//
//  Created by Mahir on 20/01/16.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import "UpdateEmailDao.h"

@implementation UpdateEmailDao

- (void) requestUpdateEmail:(NSString *) emailVal {
    NSURL *url = [NSURL URLWithString:EMAIL_UPDATE_URL];
    
    NSData *postData = [emailVal dataUsingEncoding:NSUTF8StringEncoding];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    
    request = [self sendPostRequest:request];
    [request setHTTPBody:postData];
    
    NSURLSessionDataTask *task = [[DepoHttpManager sharedInstance].urlSession dataTaskWithRequest:request completionHandler:[self createCompletionHandlerWithCompletion:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self requestFailed:response];
            });
        }
        else {
            if (![self checkResponseHasError:response]) {
                NSString *statusVal = @"";
                
                NSDictionary *mainDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
                if(mainDict && [mainDict isKindOfClass:[NSDictionary class]]) {
                    if([mainDict objectForKey:@"status"] != nil && [[mainDict objectForKey:@"status"] isKindOfClass:[NSString class]]) {
                        statusVal = [mainDict objectForKey:@"status"];
                    } else if([mainDict objectForKey:@"status"] != nil && [[mainDict objectForKey:@"status"] isKindOfClass:[NSNumber class]]) {
                        //TODO normalde status "OK" gibi string gelmeli. Fakat sunucu tarafindaki bir sorundan dolayını bu kontrol eklendi
                        NSNumber *status = [mainDict objectForKey:@"status"];
                        if([status intValue] != 200 && [status intValue] != 0) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [self shouldReturnFailWithMessage:GENERAL_ERROR_MESSAGE];
                                return ;
                            });
                        }
                    }
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self shouldReturnSuccessWithObject:statusVal];
                });
            }
        }
    }]];
    self.currentTask = task;
    [task resume];

}

@end
