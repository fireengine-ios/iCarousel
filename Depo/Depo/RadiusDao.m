//
//  RadiusDao.m
//  Depo
//
//  Created by Mahir on 27/01/15.
//  Copyright (c) 2015 com.igones. All rights reserved.
//

#import "RadiusDao.h"
#import "AppUtil.h"
#import "CacheUtil.h"
#import "AppDelegate.h"
#import "AppSession.h"

@implementation RadiusDao

- (void) requestRadiusLogin {
    NSURL *url = [NSURL URLWithString:RADIUS_URL];
    
    NSDictionary *deviceInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                [[UIDevice currentDevice] identifierForVendor].UUIDString, @"uuid",
                                [[UIDevice currentDevice] name], @"name",
                                (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? @"IPAD" : @"IPHONE"), @"deviceType",
//                                ([AppUtil readFirstVisitOverFlag] ? @"false" : @"true"), @"newDevice",
                                nil];
    
    NSLog(@"Device Info: %@", deviceInfo);
    
    SBJSON *json = [SBJSON new];
    NSString *jsonStr = [json stringWithObject:deviceInfo];
    NSData *postData = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
    
    NSLog(@"Radius Login Req: %@", jsonStr);
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setPostBody:[postData mutableCopy]];
    [request setDelegate:self];
    
    [self sendPostRequest:request];
}

- (void)requestFinished:(ASIHTTPRequest *)request {
    NSError *error = [request error];
    if (!error) {
        NSDictionary *headerParams = [request responseHeaders];
        NSString *authToken = [headerParams objectForKey:@"X-Auth-Token"];
        NSString *rememberMeToken = [headerParams objectForKey:@"X-Remember-Me-Token"];
        
        NSLog(@"Radius Login Response Headers: %@", headerParams);
        
        if(rememberMeToken != nil && ![rememberMeToken isKindOfClass:[NSNull class]]) {
            [CacheUtil writeRememberMeToken:rememberMeToken];
        }
        
        if(authToken != nil && ![authToken isKindOfClass:[NSNull class]]) {
            APPDELEGATE.session.authToken = authToken;
            [self shouldReturnSuccess];
        } else {
            [self shouldReturnFailWithMessage:TOKEN_ERROR_MESSAGE];
        }
    } else {
        [self shouldReturnFailWithMessage:GENERAL_ERROR_MESSAGE];
    }
    
}

@end
