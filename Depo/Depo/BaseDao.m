//
//  BaseDao.m
//  Depo
//
//  Created by Mahir Tarlan
//  Copyright (c) 2014 iGones. All rights reserved.
//

#import "BaseDao.h"
#import "AppDelegate.h"
#import "AppUtil.h"

@implementation BaseDao

@synthesize delegate, successMethod, failMethod;

- (NSString *) hasFinishedSuccessfully:(NSDictionary *) mainDict {
    if(mainDict == nil) {
        return GENERAL_ERROR_MESSAGE;
    } else {
        NSDictionary *resultDict = [mainDict objectForKey:@"result"];
        if(resultDict == nil) {
            return GENERAL_ERROR_MESSAGE;
        } else {
            NSNumber *isSuccess = [resultDict objectForKey:@"success"];
            NSString *message = [resultDict objectForKey:@"errorDescription"];
            if(!isSuccess) {
                if(message != nil) {
                    return message;
                } else {
                    return GENERAL_ERROR_MESSAGE;
                }
            }
        }
    }
    return nil;
}

- (void) sendPostRequest:(ASIFormDataRequest *) request {
    [request setRequestMethod:@"POST"];
    [request addRequestHeader:@"Accept" value:@"application/json"];
    [request addRequestHeader:@"Content-Type" value:@"application/json; encoding=utf-8"];
    if(APPDELEGATE.session.authToken) {
        [request addRequestHeader:APPDELEGATE.session.authToken value:@"X-Auth-Token"];
    }
    [request startAsynchronous];
}

- (void) sendGetRequest:(ASIFormDataRequest *) request {
    [request setRequestMethod:@"GET"];
    [request addRequestHeader:@"Accept" value:@"application/json"];
    [request addRequestHeader:@"Content-Type" value:@"application/json; encoding=utf-8"];
    if(APPDELEGATE.session.authToken) {
        [request addRequestHeader:@"X-Auth-Token" value:APPDELEGATE.session.authToken];
    }
    [request startAsynchronous];
}

- (void)requestFailed:(ASIHTTPRequest *)request {
    if([request.error code] == ASIConnectionFailureErrorType){
        [self shouldReturnFailWithMessage:NO_CONN_ERROR_MESSAGE];
    } else {
        [self shouldReturnFailWithMessage:GENERAL_ERROR_MESSAGE];
    }
}

- (BOOL) boolByNumber:(NSNumber *) numberObj {
    if(numberObj != nil && ![numberObj isKindOfClass:[NSNull class]]) {
        return  [numberObj boolValue];
    }
    return NO;
}

- (int) intByNumber:(NSNumber *) numberObj {
    if(numberObj != nil && ![numberObj isKindOfClass:[NSNull class]]) {
        return  [numberObj intValue];
    }
    return 0;
}

- (float) floatByNumber:(NSNumber *) numberObj {
    if(numberObj != nil && ![numberObj isKindOfClass:[NSNull class]]) {
        return  [numberObj floatValue];
    }
    return 0;
}

- (long) longByNumber:(NSNumber *) numberObj {
    if(numberObj != nil && ![numberObj isKindOfClass:[NSNull class]]) {
        return  [numberObj longValue];
    }
    return 0;
}

- (NSString *) strByRawVal:(NSString *) rawStr {
    if(rawStr == nil || [rawStr isKindOfClass:[NSNull class]])
        return nil;
    return rawStr;
}

- (NSDate *) dateByRawVal:(NSString *) rawStr {
    if(rawStr == nil || [rawStr isKindOfClass:[NSNull class]])
        return nil;
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS"];
    return [df dateFromString:rawStr];
}

- (void) shouldReturnSuccess {
    SuppressPerformSelectorLeakWarning([delegate performSelector:successMethod]);
}

- (void) shouldReturnSuccessWithObject:(id) obj {
    SuppressPerformSelectorLeakWarning([delegate performSelector:successMethod withObject:obj]);
}

- (void) shouldReturnFailWithMessage:(NSString *) errorMessage {
    SuppressPerformSelectorLeakWarning([delegate performSelector:failMethod withObject:errorMessage]);
}

@end
