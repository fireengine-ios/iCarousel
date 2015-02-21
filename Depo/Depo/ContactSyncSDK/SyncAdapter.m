//
//  ApiAdapter.m
//  ContactSyncExample
//
//  Copyright (c) 2015 Valven. All rights reserved.
//

#import "SyncAdapter.h"
#import "SyncSettings.h"
#import "Contact.h"

@implementation SyncAdapter

+ (void)getContact:(NSNumber*)contactId callback:(void (^)(id, BOOL))callback
{
    [SyncAdapter request:[self buildURL:[NSString stringWithFormat:@"contact/%@",contactId]] params:nil headers:nil method:GET callback:callback];
}
+ (void)getContacts:(void (^)(id, BOOL))callback
{
    [SyncAdapter request:[self buildURL:@"contact"] params:nil headers:nil method:GET callback:callback];
}
+ (void)updateContacts:(NSArray*)contacts callback:(void (^)(id, BOOL))callback
{
    NSMutableArray *array = [NSMutableArray new];
    for (Contact *c in contacts){
        [array addObject:[c toJSON]];
    }
    [SyncAdapter request:[self buildURL:@"contacts"] params:@{@"data":array} headers:nil method:POST callback:callback];
}
+ (void)deleteContact:(NSNumber*)contactId callback:(void (^)(id, BOOL))callback
{
    [SyncAdapter request:[self buildURL:[NSString stringWithFormat:@"contact/%@",contactId]] params:nil headers:nil method:DELETE callback:callback];
}
+ (void)deleteContact:(NSNumber*)contactId permanent:(BOOL)permanent callback:(void (^)(id, BOOL))callback
{
    [SyncAdapter request:[self buildURL:[NSString stringWithFormat:@"contact/%@?permanent=%@",contactId, permanent?@"true":@"false"]] params:nil headers:nil method:DELETE callback:callback];
}
+ (void)getServerTime:(void (^)(id, BOOL))callback
{
    [SyncAdapter request:[self buildURL:@"timestamp"] params:nil headers:nil method:GET callback:callback];
}
+ (void)checkStatus:(NSString*)syncId callback:(void (^)(id, BOOL))callback
{
    [SyncAdapter request:[self buildURL:[NSString stringWithFormat:@"sync/status/%@",syncId]] params:nil headers:nil method:GET callback:callback];
}

+ (NSData*)postBody:(NSDictionary*)dict
{
    if (SYNC_IS_NULL(dict)){
        return nil;
    }
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict
                                                    options:0
                                                         error:&error];
    
    if (!jsonData) {
        SYNC_Log(@"Got an error: %@", error);
        [SyncStatus handleNSError:error];
        return nil;
    } else {
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        return [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    }
}

+ (BOOL) checkResponse:(NSHTTPURLResponse *) response data:(NSData *) data {
    SYNC_Log(@"Status code: %@ %ld %@",response.URL,(long)[((NSHTTPURLResponse *)response) statusCode],[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    
    if (response.statusCode == 200) {
        // Everything went well
        return TRUE;
    } else {
        // problem
        return FALSE;
    }
}

+ (void)request:(NSString*)url params:(NSDictionary*)params headers:(NSDictionary*)headers method:(HttpMethod)method callback:(void (^)(id, BOOL))callback
{
    NSURL *urlAddress;
    if (method == GET){
        if (SYNC_IS_NULL(params) || [params count]==0){
            urlAddress = [NSURL URLWithString:url];
        } else {
            urlAddress = [NSURL URLWithString:[NSString stringWithFormat:@"%@?%@",url,[SyncAdapter serializeParams:params]]];
        }
    } else {
        urlAddress = [NSURL URLWithString:url];
    }
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:urlAddress];
    [request setHTTPShouldHandleCookies:NO];
    [request setTimeoutInterval:1800.0];
    
    switch (method) {
        case GET:
            [request setHTTPMethod:@"GET"];
            break;
        case POST:
            [request setHTTPMethod:@"POST"];
            [request setHTTPBody:[SyncAdapter postBody:params]];
            break;
        case PUT:
            [request setHTTPMethod:@"PUT"];
            [request setHTTPBody:[SyncAdapter postBody:params]];
            break;
        case DELETE:
            [request setHTTPMethod:@"DELETE"];
            [request setHTTPBody:[SyncAdapter postBody:params]];
            break;
        case PATCH:
            [request setHTTPMethod:@"PATCH"];
            [request setHTTPBody:[SyncAdapter postBody:params]];
        default:
            break;
    }
    
    if (headers){
        for (NSString *key in headers){
            [self addHeader:key value:headers[key] request:request];
        }
    }
    
    [self addHeader:@"Content-Type" value:@"application/json" request:request];
    [self addHeader:@"Cache-Control" value:@"no-cache" request:request];
    [self addHeader:@"User-Agent" value:SYNC_USER_AGENT request:request];
    [self addHeader:SYNC_HEADER_AUTH_TOKEN value:[SyncSettings shared].token request:request];
    
    [self addHeader:SYNC_HEADER_CLIENT_VERSION value:SYNC_VERSION request:request];
    
    void (^success)(id responseObject) = ^(id responseObject){
        SYNC_Log(@"url response: %@ %@", url, responseObject);
        if (callback)
            callback(responseObject, TRUE);
    };
    
    void (^fail)(id responseObject, NSError *error) = ^(id responseObject, NSError *error){
        SYNC_Log(@"Error: %@", error);
        
        [SyncStatus handleNSError:error];
        
        if (callback)
            callback(responseObject, FALSE);
    };
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        BOOL isSuccess = FALSE;
        id responseObject;
        NSError *error = connectionError;
        if (error==nil){
            isSuccess = [SyncAdapter checkResponse:(NSHTTPURLResponse *)response data:data];
            
            if (data!=nil){
                NSString *responseBody = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                responseObject = [NSJSONSerialization JSONObjectWithData: [responseBody dataUsingEncoding:NSUTF8StringEncoding] options: NSJSONReadingMutableContainers error: &error];
            }
            
            NSDictionary *responseHeaders = nil;
            if ([response respondsToSelector:@selector(allHeaderFields)]) {
                responseHeaders = [(NSHTTPURLResponse *)response allHeaderFields];
            }
            if (!SYNC_IS_NULL(responseHeaders)){
                if (!SYNC_IS_NULL(responseHeaders[SYNC_HEADER_MSISDN])){
                    [SyncSettings shared].msisdn = responseHeaders[SYNC_HEADER_MSISDN];
                }
            }
        } else {
            fail(nil, error);
        }
        
        if (isSuccess && responseObject!=nil){
            if (error!=nil){
                fail(responseObject, error);
            } else {
                BOOL hasError = FALSE;
                if (SYNC_IS_NULL(responseObject) || ![responseObject isKindOfClass:[NSDictionary class]]){
                    hasError = TRUE;
                }
                if (!hasError)
                    success(responseObject);
                else
                    fail(responseObject, nil);
            }
        } else {
            fail(nil, error);
        }
    }];
}

+(void) addHeader:(NSString *)key value:(NSString *)value request:(NSMutableURLRequest *) request{
    if (!SYNC_IS_NULL(value)){
        [request setValue:value forHTTPHeaderField:key];
    }
}

+ (NSString *)buildURL:(NSString *)part
{
    NSMutableString *buffer = [[NSMutableString alloc] initWithString:[SyncSettings shared].endpointUrl];
    
    if (![buffer hasSuffix:@"/"]){
        [buffer appendString:@"/"];
    }
    [buffer appendString:part];
    return [buffer copy];
}

+ (NSString *)serializeParams:(NSDictionary *)params {
    /*
     
     Convert an NSDictionary to a query string
     
     */
    
    NSMutableArray* pairs = [NSMutableArray array];
    for (NSString* key in [params keyEnumerator]) {
        id value = [params objectForKey:key];
        if ([value isKindOfClass:[NSDictionary class]]) {
            for (NSString *subKey in value) {
                NSString* escaped_value = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                                              (CFStringRef)[value objectForKey:subKey],
                                                                                              NULL,
                                                                                              (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                              kCFStringEncodingUTF8));
                [pairs addObject:[NSString stringWithFormat:@"%@[%@]=%@", key, subKey, escaped_value]];
            }
        } else if ([value isKindOfClass:[NSArray class]]) {
            for (NSString *subValue in value) {
                NSString* escaped_value = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                                              (CFStringRef)subValue,
                                                                                              NULL,
                                                                                              (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                              kCFStringEncodingUTF8));
                [pairs addObject:[NSString stringWithFormat:@"%@[]=%@", key, escaped_value]];
            }
        } else {
            NSString* escaped_value = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL,
                    (CFStringRef)SYNC_AS_STRING(params[key]),
                        NULL,
                            (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                kCFStringEncodingUTF8));
            [pairs addObject:[NSString stringWithFormat:@"%@=%@", key, escaped_value]];
        }
    }
    return [pairs componentsJoinedByString:@"&"];
}

@end


