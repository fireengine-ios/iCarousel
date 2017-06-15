//
//  DropboxTokenDao.m
//  Depo
//
//  Created by Mahir Tarlan on 22/04/16.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import "DropboxTokenDao.h"

@implementation DropboxTokenDao

- (void) requestTokenWithCurrentToken:(NSString *) currentToken withConsumerKey:(NSString *) consumerKey withAppSecret:(NSString *) appSecret withAuthTokenSecret:(NSString *) authTokenSecret {
    NSURL *url = [NSURL URLWithString:@"https://api.dropboxapi.com/1/oauth2/token_from_oauth1"];

    NSString *authorizationHeaderValue = [NSString stringWithFormat:@"OAuth oauth_version=\"1.0\", oauth_signature_method=\"PLAINTEXT\", oauth_consumer_key=\"%@\", oauth_token=\"%@\", oauth_signature=\"%@&%@\"", consumerKey, currentToken, appSecret, authTokenSecret];

    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    //    request.tag = REQ_TAG_FOR_DROPBOX;

    
    [request setHTTPMethod:@"POST"];
    [request addValue:authorizationHeaderValue forHTTPHeaderField:@"Authorization"];
    [request setTimeoutInterval:30];
    
    NSURLSessionDataTask *task = [[DepoHttpManager sharedInstance].urlSession dataTaskWithRequest:request completionHandler:[self createCompletionHandlerWithCompletion:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self shouldReturnFailWithMessage:GENERAL_ERROR_MESSAGE];
            });
        }
        else {
            if (![self checkResponseHasError:response]) {
                NSDictionary *mainDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
                if(mainDict != nil && ![mainDict isKindOfClass:[NSNull class]]) {
                    NSString *token = [mainDict objectForKey:@"access_token"];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self shouldReturnSuccessWithObject:token];
                    });
                }
                else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self shouldReturnFailWithMessage:GENERAL_ERROR_MESSAGE];
                    });
                    
                }
            }
            else {
                [self requestFailed:response];
            }
        }
    }]];
    self.currentTask = task;
    [task resume];
}

@end
