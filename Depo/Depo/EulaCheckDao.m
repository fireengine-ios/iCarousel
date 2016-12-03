//
//  EulaCheckDao.m
//  Depo
//
//  Created by Mahir Tarlan on 31/03/16.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import "EulaCheckDao.h"

@implementation EulaCheckDao

- (void) requestCheckEulaForLocale:(NSString *) locale {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:CHECK_EULA_URL, locale]];
    
    NSString *log = [NSString stringWithFormat:@"[GET] EulaCheckDao requestCheckEulaForLocale %@", locale];
    IGLog(log);

    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    request = [self sendGetRequest:request];
    
    NSURLSessionDataTask *task = [[DepoHttpManager sharedInstance].urlSession dataTaskWithRequest:request completionHandler:[self createCompletionHandlerWithCompletion:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            NSString *log = [NSString stringWithFormat:@"EulaCheckDao requestFailed with error: %@", [error localizedDescription]];
            IGLog(log);

            NSInteger statusCode = [(NSHTTPURLResponse *) response statusCode];
            if (statusCode == 412) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self shouldReturnSuccessWithObject:[NSString stringWithFormat:@"%d",(int)statusCode]];
                });

            }
            else if (statusCode == 403) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self shouldReturnFailWithMessage:FORBIDDEN_ERROR_MESSAGE];
                });
            }
            else if(statusCode == NSURLErrorNotConnectedToInternet) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self shouldReturnFailWithMessage:NSLocalizedString(@"NoConnErrorMessage", @"")];
                });
            }
            else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self shouldReturnFailWithMessage:GENERAL_ERROR_MESSAGE];
                });
            }
        }
        else {
            if (![self checkResponseHasError:response]) {
                NSDictionary *mainDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
                
                if(mainDict != nil && ![mainDict isKindOfClass:[NSNull class]]) {
                    IGLog(@"EulaCheckDao requestFinished successfully");
                    NSString *status = [self strByRawVal:[mainDict objectForKey:@"status"]];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self shouldReturnSuccessWithObject:status];
                    });
                }
                else {
                    IGLog(@"EulaCheckDao requestFinished with error");
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self shouldReturnFailWithMessage:GENERAL_ERROR_MESSAGE];
                    });
                }
            }
        }
    }]];
    self.currentTask = task;
    [task resume];
}

@end
