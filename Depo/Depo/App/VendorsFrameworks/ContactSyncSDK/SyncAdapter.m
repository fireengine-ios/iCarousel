//
//  ApiAdapter.m
//  ContactSyncExample
//
//  Copyright (c) 2015 Valven. All rights reserved.
//

#import "SyncAdapter.h"
#import "SyncSettings.h"
#import "Contact.h"
#import "GZIP.h"


@implementation SyncAdapter

+ (void)getLastBackup:(void (^)(id, BOOL))callback
{
    [SyncAdapter request:[self buildURL:@"lastBackup"] params:nil headers:nil method:GET callback:callback];
}

+ (void)getContact:(NSNumber*)contactId callback:(void (^)(id, BOOL))callback
{
    [SyncAdapter request:[self buildURL:[NSString stringWithFormat:@"contact/%@",contactId]] params:nil headers:nil method:GET callback:callback];
}
+ (void)getUpdatedContacts:(NSNumber *)lastSyncTime deviceId:(NSString *)deviceId callback:(void (^)(id, BOOL))callback
{
    NSMutableDictionary *dict = [NSMutableDictionary new];
    [dict setObject:[lastSyncTime stringValue] forKey:@"timestamp"];
    [dict setObject:deviceId forKey:@"deviceId"];
    [SyncAdapter request:[self buildURL:@"getUpdatedContacts"] params:dict headers:nil method:GET callback:callback];
}


+ (void)sendStats:(NSString*)key start:(NSInteger)start result:(NSInteger)result created:(NSInteger)created updated:(NSInteger)updated deleted:(NSInteger)deleted  status:(NSInteger)status errorCode:(NSString*)errorCode errorMsg:(NSString*)errorMsg callback:(void (^)(id, BOOL))callback{
    [self sendStats:key start:start result:result created:created updated:updated deleted:deleted status:status errorCode:errorCode errorMsg:errorMsg operation:nil callback:callback];
}

+ (void)sendStats:(NSString*)key start:(NSInteger)start result:(NSInteger)result created:(NSInteger)created updated:(NSInteger)updated deleted:(NSInteger)deleted  status:(NSInteger)status errorCode:(NSString*)errorCode errorMsg:(NSString*)errorMsg operation:(NSString*) operation callback:(void (^)(id, BOOL))callback
{
    if (SYNC_IS_NULL(key)){
        callback(nil, FALSE);
        return;
    }
    NSMutableDictionary *mutableData = [[NSMutableDictionary alloc] init];
    
    NSDictionary *data = @{@"key":key, @"start":@(start), @"result":@(result), @"created":@(created), @"updated":@(updated), @"deleted":@(deleted), @"status":@(status)};
    
    [mutableData addEntriesFromDictionary:data];
    
    if(errorCode != nil){
        [mutableData setObject:errorCode forKey:@"errorCode"];
    }
    if(errorMsg != nil){
        [mutableData setObject:errorMsg forKey:@"errorMsg"];
    }
    if(operation != nil){
        [mutableData setObject:operation forKey:@"operation"];
    }

    [SyncAdapter request:[self buildURL:@"stats"] params:mutableData headers:nil method:POST callback:callback];
}

+(void)restoreContactsWithTimestamp:(long long)timestamp deviceId:(NSString *)deviceId callback:(void (^)(id, BOOL))callback{
    NSNumber *timestampNS = [NSNumber numberWithLongLong:timestamp];
    NSDictionary *restoreData = @{@"timestamp":timestampNS, @"deviceId":deviceId};
    [SyncAdapter request:[self buildURL:@"restore"] params:restoreData headers:nil method:POST callback:callback];
}

+ (void)partialBackup:(NSString*)key deviceId:(NSString *)deviceId dirtyContacts:(NSArray*)dirtyContacts deletedContacts:(NSArray *)deletedContacts duplicates:(NSArray *)duplicates step:(NSNumber *)step totalStep:(NSNumber *)totalStep callback:(void (^)(id, BOOL))callback
{
    NSMutableArray *array = [NSMutableArray new];
    for (Contact *c in dirtyContacts){
        [array addObject:[c toJSON:false]];
    }
    NSDictionary *backupData = @{@"dirty":array, @"deviceId":deviceId, @"step": step, @"totalStep": totalStep};
    
    if (SYNC_STRING_IS_NULL_OR_EMPTY(key)){
        key = @"-1";
    }
    [SyncAdapter request:[self buildURL:[NSString stringWithFormat:@"v2/backup/%@",key]] params:backupData headers:nil method:POST callback:callback];
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

+ (void)sendLog:(NSData*)data file:(NSString*)file
{
    [SyncAdapter gzippedRequest:[self buildURL:@"saveLog"] data:data headers:@{@"FileName":file} callback:nil];
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
    /*
     * This line can be used to print post body data with JSon object.
     */
    //NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    //SYNC_Log(@"%@", jsonString);
    
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
    SYNC_Log(@"Status code: %@ %ld",response.URL,(long)[((NSHTTPURLResponse *)response) statusCode]);
    
    if (response.statusCode == 200) {
        // Everything went well
        return TRUE;
    } else {
        // problem
        return FALSE;
    }
}

+ (void)gzippedRequest:(NSString*)url data:(NSData*)data headers:(NSDictionary*)headers callback:(void (^)(id, BOOL))callback
{
    NSData *requestBodyData = [data gzippedData];
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)requestBodyData.length];
    
    NSLog(@"POST : %@",postLength);
    
    NSURL *urlAddress = [NSURL URLWithString:url];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:urlAddress];
    [request setHTTPMethod:@"POST"];
    [request setHTTPShouldHandleCookies:NO];
    [request setTimeoutInterval:1800.0];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"gzip" forHTTPHeaderField:@"Content-Encoding"];
    [request setHTTPBody:requestBodyData];
    
    if (headers){
        for (NSString *key in headers){
            [self addHeader:key value:headers[key] request:request];
        }
    }
    
    [self addHeader:@"Accept" value:@"application/json" request:request];
    [self addHeader:@"X-Requested-With" value:@"XMLHttpRequest" request:request];
    [self addHeader:@"User-Agent" value:SYNC_USER_AGENT request:request];
    [self addHeader:SYNC_HEADER_AUTH_TOKEN value:[SyncSettings shared].token request:request];
    [self addHeader:SYNC_HEADER_CLIENT_VERSION value:SYNC_VERSION request:request];
    
    void (^success)(id responseObject) = ^(id responseObject){
        NSLog(@"url response: %@ %@", url, responseObject);
        if (callback)
            callback(responseObject, TRUE);
    };
    
    void (^fail)(id responseObject, NSError *error) = ^(id responseObject, NSError *error){
        NSLog(@"Error: %@", error);
        
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
    
    [self addHeader:@"Accept" value:@"application/json" request:request];
    [self addHeader:@"X-Requested-With" value:@"XMLHttpRequest" request:request];
    [self addHeader:@"Content-Type" value:@"application/json; charset=utf-8" request:request];
    [self addHeader:@"Cache-Control" value:@"no-cache" request:request];
    [self addHeader:@"User-Agent" value:SYNC_USER_AGENT request:request];
    [self addHeader:SYNC_HEADER_AUTH_TOKEN value:[SyncSettings shared].token request:request];
    [self addHeader:SYNC_HEADER_CLIENT_VERSION value:SYNC_VERSION request:request];
    
    void (^success)(id responseObject) = ^(id responseObject){
        SYNC_Log(@"url response: %@", url);
        
        dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            if (callback)
                callback(responseObject, TRUE);
        });
    };
    
    void (^fail)(id responseObject, NSError *error) = ^(id responseObject, NSError *error){
        SYNC_Log(@"Error: %@", error);

        dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            [SyncStatus handleNSError:error];
            
            if (callback)
                callback(responseObject, FALSE);
        });
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
                    SYNC_Log(@"msisdn: %@",[SyncSettings shared].msisdn);
                }
            }
        } else {
            if (data!=nil){
                NSString *responseBody = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                responseObject = [NSJSONSerialization JSONObjectWithData: [responseBody dataUsingEncoding:NSUTF8StringEncoding] options: NSJSONReadingMutableContainers error: &error];
            }
            fail(responseObject, error);
            return;
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
            fail(responseObject, error);
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
     * Convert an NSDictionary to a query string
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
