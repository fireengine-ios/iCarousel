//
//  RequestBaseUrlDao.m
//  Depo
//
//  Created by Mahir on 9/22/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "RequestBaseUrlDao.h"
#import "AppDelegate.h"
#import "AppSession.h"
#import "AppUtil.h"
#import "SyncUtil.h"
#import "SharedUtil.h"

@implementation RequestBaseUrlDao

- (void) requestBaseUrl {
	NSURL *url = [NSURL URLWithString:USER_BASE_URL];
	
	ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setDelegate:self];
    
    [self sendGetRequest:request];
}

- (void)requestFinished:(ASIHTTPRequest *)request {
	NSError *error = [request error];
	
	if (!error) {
		NSString *responseEnc = [request responseString];
		
        NSLog(@"User Base Url Response: %@", responseEnc);
        
		SBJSON *jsonParser = [SBJSON new];
		NSDictionary *mainDict = [jsonParser objectWithString:responseEnc];
        if(mainDict != nil && ![mainDict isKindOfClass:[NSNull class]]) {
            NSString *baseUrlValue = [mainDict objectForKey:@"value"];
            APPDELEGATE.session.baseUrl = [self strByRawVal:baseUrlValue];
            APPDELEGATE.session.baseUrlConstant = [AppUtil userUniqueValueByBaseUrl:[self strByRawVal:baseUrlValue]];
            [SharedUtil writeSharedBaseUrl:APPDELEGATE.session.baseUrl];
            [SyncUtil writeBaseUrlConstant:APPDELEGATE.session.baseUrlConstant];
            [SyncUtil writeBaseUrlConstantForLocPopup:APPDELEGATE.session.baseUrlConstant];
            
        }
        
        [self shouldReturnSuccess];
		
	} else {
        [self shouldReturnFailWithMessage:GENERAL_ERROR_MESSAGE];
	}
    
}

@end
