//
//  DepoAdapter.m
//  ContactSyncExample
//
//  Created by Furkan Bahceci on 14.01.2020.
//  Copyright © 2020 Valven. All rights reserved.
//

#import "DepoAdapter.h"
#import "SyncSettings.h"
#import "SyncAdapter.h"

@implementation DepoAdapter

+ (void)getUploadURL:(void (^)(id _Nonnull, BOOL))callback {
    NSDictionary* headers = @{
        @"Accept": @"application/json",
        @"Content-Type":@"application/json",
        @"X-Auth-Token": [SyncSettings shared].token};
    
    [DepoAdapter request:[self buildURL:@"api/container/baseUrl"] params:nil headers:headers method:GET callback:callback];
}

+ (void)uploadVCF:(NSString *)deviceId url:(NSString *)url source:(NSString *)source callback:(void (^)(id _Nonnull, BOOL))callback {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd_hh-mm-ss"];
    NSString* fileName = [NSString stringWithFormat:@"CONTACTS_%@_%@.vcf", [formatter stringFromDate:[NSDate date]], deviceId];
    SYNC_Log(@"File name: %@", fileName);
    
    fileName = [fileName stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    NSDictionary* headers = @{
        @"Accept": @"application/json",
        @"X-Auth-Token": [SyncSettings shared].token,
        @"Content-Type":@"text/vcf",
        @"x-meta-strategy":@"1",
        @"X-Object-Meta-Special-Folder":@"CONTACT_BACKUPS",
        @"X-Object-Meta-File-Name": fileName
    };
    
    NSDictionary* params = @{@"content": source};

    [DepoAdapter request:[NSString stringWithFormat:@"%@/%@", url, [[NSUUID UUID] UUIDString]] params:params headers:headers method:PUT callback:callback];
}

+ (void)request:(NSString*)url params:(NSDictionary*)params headers:(NSDictionary*)headers method:(HttpMethod)method callback:(void (^)(id, BOOL))callback
{
    NSURL *urlAddress = [NSURL URLWithString:url];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:urlAddress];
    [request setHTTPShouldHandleCookies:NO];
    [request setTimeoutInterval:1800.0];
    
    switch (method) {
        case GET:
            [request setHTTPMethod:@"GET"];
            break;
        case PUT:
            // VCF upload
            [request setHTTPMethod:@"PUT"];
            [request setHTTPBody:[DepoAdapter postBody:params]];
        default:
            break;
    }
    
    if (headers){
        for (NSString *key in headers){
            [self addHeader:key value:headers[key] request:request];
        }
    }
    
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
            isSuccess = [DepoAdapter checkResponse:(NSHTTPURLResponse *)response data:data];
            
            if (data!=nil){
                NSString *responseBody = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                if (!SYNC_STRING_IS_NULL_OR_EMPTY(responseBody)) {
                    responseObject = [NSJSONSerialization JSONObjectWithData: [responseBody dataUsingEncoding:NSUTF8StringEncoding] options: NSJSONReadingMutableContainers error: &error];
                }
            }
            
            NSDictionary *responseHeaders = nil;
            if ([response respondsToSelector:@selector(allHeaderFields)]) {
                responseHeaders = [(NSHTTPURLResponse *)response allHeaderFields];
            }
        } else {
            if (data!=nil){
                NSString *responseBody = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                responseObject = [NSJSONSerialization JSONObjectWithData: [responseBody dataUsingEncoding:NSUTF8StringEncoding] options: NSJSONReadingMutableContainers error: &error];
            }
            fail(responseObject, error);
            return;
        }
        
        if (isSuccess){
            if (error!=nil){
                fail(responseObject, error);
            } else {
                BOOL hasError = FALSE;
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

+ (NSData*)postBody:(NSDictionary*)dict
{
    if (SYNC_IS_NULL(dict)){
        return nil;
    }
    
    return [dict[@"content"] dataUsingEncoding:NSUTF8StringEncoding];
}

+ (BOOL) checkResponse:(NSHTTPURLResponse *) response data:(NSData *) data {
    SYNC_Log(@"Status code: %@ %ld",response.URL,(long)[((NSHTTPURLResponse *)response) statusCode]);
    
    if (response.statusCode >= 200 || response.statusCode < 300) {
        // Everything went well
        return TRUE;
    } else {
        // problem
        return FALSE;
    }
}

+ (NSString *)buildURL:(NSString *)part
{
    NSMutableString *buffer = [[NSMutableString alloc] initWithString:[SyncSettings shared].DEPO_URL];
    
    if (![buffer hasSuffix:@"/"]){
        [buffer appendString:@"/"];
    }
    [buffer appendString:part];
    return [buffer copy];
}

@end
