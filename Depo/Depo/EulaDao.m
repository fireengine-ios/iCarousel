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
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setDelegate:self];
    
    [self sendGetRequest:request];
}

- (void)requestFinished:(ASIHTTPRequest *)request {
    NSError *error = [request error];
    if (!error) {
        NSString *responseStr = [request responseString];
        NSLog(@"EULA Response: %@", responseStr);

        NSString *log = [NSString stringWithFormat:@"EulaDao request finished with response:%@", responseStr];
        IGLog(log);

        SBJSON *jsonParser = [SBJSON new];
        NSDictionary *mainDict = [jsonParser objectWithString:responseStr];
        
        if(mainDict != nil && ![mainDict isKindOfClass:[NSNull class]]) {
            Eula *eula = [[Eula alloc] init];
            eula.eulaId = [self intByNumber:[mainDict objectForKey:@"id"]];
            eula.locale = [self strByRawVal:[mainDict objectForKey:@"locale"]];
            eula.content = [self strByRawVal:[mainDict objectForKey:@"content"]];

            [self shouldReturnSuccessWithObject:eula];
            return;
        }
    }
    IGLog(@"EulaDao request finished with general error");
    [self shouldReturnFailWithMessage:GENERAL_ERROR_MESSAGE];
}

@end
