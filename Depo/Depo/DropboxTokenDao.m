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
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setDelegate:self];
    [request setRequestMethod:@"POST"];
    [request addRequestHeader:@"Authorization" value:authorizationHeaderValue];
    request.timeOutSeconds = 30;
    [request startAsynchronous];
}

- (void)requestFinished:(ASIHTTPRequest *)request {
    NSError *error = [request error];
    if (!error) {
        NSString *responseStr = [request responseString];
        NSLog(@"Dropbox Token Response: %@", responseStr);
        SBJSON *jsonParser = [SBJSON new];
        NSDictionary *mainDict = [jsonParser objectWithString:responseStr];
        if(mainDict != nil && ![mainDict isKindOfClass:[NSNull class]]) {
            NSString *token = [mainDict objectForKey:@"access_token"];
            [self shouldReturnSuccessWithObject:token];
            return;
        }
    }
    [self shouldReturnFailWithMessage:GENERAL_ERROR_MESSAGE];
}

- (void)requestFailed:(ASIHTTPRequest *)request {
    [self shouldReturnFailWithMessage:GENERAL_ERROR_MESSAGE];
}

@end
