//
//  EulaDao.m
//  Depo
//
//  Created by Mahir Tarlan on 31/03/16.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import "EulaDao.h"
#import "Eula.h"

@implementation EulaDao

- (void) requestEulaForLocale:(NSString *) locale {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:EULA_URL, locale]];
    
    IGLog(@"[GET] EulaDao requestEulaForLocale called");

    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    request = [self sendGetRequest:request];
    
    NSURLSessionDataTask *task = [[DepoHttpManager sharedInstance].urlSession dataTaskWithRequest:request completionHandler:[self createCompletionHandlerWithCompletion:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self requestFailed:response];
            });
        }
        else {
            if (![self checkResponseHasError:response]) {
                NSDictionary *mainDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
                if(mainDict != nil && ![mainDict isKindOfClass:[NSNull class]]) {
                    IGLog(@"EulaDao request finished successfully");
                    
                    Eula *eula = [[Eula alloc] init];
                    eula.eulaId = [self intByNumber:[mainDict objectForKey:@"id"]];
                    eula.locale = [self strByRawVal:[mainDict objectForKey:@"locale"]];
                    eula.content = [self strByRawVal:[mainDict objectForKey:@"content"]];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self shouldReturnSuccessWithObject:eula];
                    });
                }
                else {
                    IGLog(@"EulaDao request finished with general error");
                    
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
