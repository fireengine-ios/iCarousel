//
//  CurioPostOffice.m
//  CurioSDK
//
//  Changed by Can Ciloglu on 30/01/15.
//  Created by Harun Esur on 19/09/14.
//  Copyright (c) 2014 Turkcell. All rights reserved.
//

#import "CurioSDK.h"

#include <pthread.h>

@implementation CurioPostOffice

static NSOperationQueue *opQueue;
static pthread_mutex_t mutex;

+ (CS_INSTANCETYPE) shared {
    
    static dispatch_once_t once;
    
    static id instance;
    
    dispatch_once(&once, ^{
        instance = [self new];
    });
    
    return instance;
}

- (void) checkForSuccessfullyPostedSessionCode:(NSString *) sessionCode {
    if (![[CurioSDK shared] sessionCodeRegisteredOnServer]) {
        
        BOOL registeredOnRemote = [sessionCode isEqualToString:[[CurioSDK shared] sessionCode]];
        
        [[CurioSDK shared] setSessionCodeRegisteredOnServer:registeredOnRemote];
        
        if (registeredOnRemote) {
            CS_Log_Info(@"%@ session activated on remote server",[[CurioSDK shared] sessionCode]);
            
            [[NSNotificationCenter defaultCenter] postNotificationName:CS_NOTIF_REGISTERED_NEW_SESSION_CODE object:nil];
        }
    }
    
}

- (BOOL) checkResponse:(NSHTTPURLResponse *) response url:(NSString *) url data:(NSData *) data
      postedParameters:(NSDictionary *) postedParameters
                action:(CurioAction *) action{
    
    
    BOOL ret = FALSE;
    
    last_responseCode = (int)response.statusCode;
    
    CS_Log_Info(@"\r\rRESPONSE for URL: %@,\rStatus code: %ld,\rResponse string: %@\r\r",url,(long)[((NSHTTPURLResponse *)response) statusCode],[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);

    if (response.statusCode == 200) {
        // Everything went well
        if (action != nil && action.actionType == CActionTypeStartScreen) {
            // Check for hit code
            NSString *screenClass = [action.properties objectForKey:CS_CUSTOM_VAR_SCREENCLASS];
            
            if (screenClass) {
                
                NSDictionary *ret =  [[CurioUtil shared] fromJson:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] percentEncoded:FALSE];
                
                NSString *hitCode = [NSString stringWithFormat:@"%@",[ret objectForKey:CS_HTTP_JSON_VARNAME_HITCODE]];
                
                CS_Log_Info(@"Retrieved hit code %@ for screen %@",hitCode,screenClass);
                
                [[CurioSDK shared].memoryStore setObject:hitCode
                                                  forKey:[NSString stringWithFormat:@"HC%@",screenClass]];
            }
            
        } else if (action != nil && action.actionType == CActionTypeSendEvent) {
            // Check for hit code
            NSString *eventKeyAndValue = [action.properties objectForKey:CS_CUSTOM_VAR_EVENTCLASS];
            
            if (eventKeyAndValue) {
                
                NSDictionary *ret =  [[CurioUtil shared] fromJson:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] percentEncoded:FALSE];
                
                NSString *hitCode = [NSString stringWithFormat:@"%@",[ret objectForKey:CS_HTTP_JSON_VARNAME_EVENTCODE]];
                
                CS_Log_Info(@"Retrieved hit code %@ for screen %@",hitCode,eventKeyAndValue);
                
                [[CurioSDK shared].memoryStore setObject:hitCode
                                                  forKey:[NSString stringWithFormat:@"HC%@",eventKeyAndValue]];
            }
        }
        
        // Means we are successfully posted online post request
        if (action != nil) {
            //CS_Log_Debug(@"%@",action.properties);
            
            NSObject *sessionCode = [[action properties] objectForKey:CS_HTTP_PARAM_SESSION_CODE];
            if (sessionCode != nil) {
            
                [self checkForSuccessfullyPostedSessionCode:(NSString *) sessionCode];
            
            }
        } else
        // Means we have successfully posted OCR or PDR request
        {
            
            if (postedParameters != nil) {
                
                NSObject *data = [postedParameters objectForKey: CURKeyData];
                BOOL activated = FALSE;
                
                
                // OCR Check
                if (data != nil) {
                
                    NSArray *dictArr = (NSArray *) [[CurioUtil shared] fromJson:(NSString *)data percentEncoded:YES];
                    
                    for (NSDictionary *d in dictArr) {
                        
                        // We are just checking for OCR request session code
                        NSObject *sessionCode = [d objectForKey:CS_HTTP_JSON_VARNAME_SESSIONCODE];
                        
                        if (sessionCode != nil) {
                        
                            
                
                            [self checkForSuccessfullyPostedSessionCode:(NSString *) sessionCode];
                            
                            activated = TRUE;
                            
                        }
                    }
                }
                
                
                // PDR Check
                if (!activated) {
                    
                    NSObject *sessionCode = [postedParameters objectForKey:CS_HTTP_JSON_VARNAME_SESSIONCODE];
                    
                    if (sessionCode != nil) {
                        
                        [self checkForSuccessfullyPostedSessionCode:(NSString *) sessionCode];
                        
                    }
                    
                }
            }
        }
        
        
        return TRUE;
        
    } else if (response.statusCode == 401) {
        // UNAUTHORIZED
        
        CS_Log_Warning(@"Got UNAUTHORIZED code 401");
        
    } else if (response.statusCode == 412) {
        // Precondition failed
        // Wrong api-tracking etc.
        
        
    } else {
        // Another problem
        
        
    }
    
    return ret;
    
}

- (BOOL) postRequest:(CPostType) postType parameters:(NSDictionary *)parameters action:(CurioAction *) action {
    
    @synchronized(self) {
 
        NSString *suffix =     postType == CPostTypeOCR ? CS_SERVER_URL_SUFFIX_OFFLINE_CACHE :
        postType == CPostTypePDR ? CS_SERVER_URL_SUFFIX_PERIODIC_BATCH :
        postType == CPostTypeStartScreen ? CS_SERVER_URL_SUFFIX_SCREEN_START :
        postType == CPostTypeStartSession ? CS_SERVER_URL_SUFFIX_SESSION_START :
        postType == CPostTypeSendEvent ? CS_SERVER_URL_SUFFIX_SEND_EVENT :
        postType == CPostTypeEndSession ? CS_SERVER_URL_SUFFIX_SESSION_END :
        postType == CPostTypeEndScreen ? CS_SERVER_URL_SUFFIX_SCREEN_END :
        postType == CPostTypeUnregister ? CS_SERVER_URL_SUFFIX_UNREGISTER :
        postType == CPostTypeEndEvent ? CS_SERVER_URL_SUFFIX_END_EVENT : @"";

        NSString *sUrl = [NSString stringWithFormat:@"%@%@",[[CurioSettings shared] serverUrl],suffix];
    
        //CS_Log_Info(@"URL: %@ %@",sUrl,CS_RM_STR_NEWLINE(parameters));
        NSString *postBody = [[CurioUtil shared] dictToPostBody:parameters];

        NSURL *url = [NSURL URLWithString:sUrl];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
        [request setHTTPMethod:@"POST"];
        [request setHTTPShouldHandleCookies:NO];
        [request setValue:CS_OPT_USER_AGENT forHTTPHeaderField:@"User-Agent"];
        [request setHTTPBody:[postBody dataUsingEncoding:NSUTF8StringEncoding]];
        [request setTimeoutInterval:30.0];
        
        CS_Log_Debug(@"\r\rPOST REQUEST;\rURL: %@,\rPost body:\r%@\r\r",sUrl,[postBody stringByReplacingOccurrencesOfString:@"&" withString:@"\r"]);
    
        NSURLResponse * response = nil;
        NSError * error = nil;
        NSData * data  = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];

        BOOL responseOk = [self checkResponse:(NSHTTPURLResponse *)response url:sUrl data:data postedParameters:parameters action:action];
        
        if(responseOk){
            [CurioSDK shared].retryCount = 0;
        }
        
        if (postType == CPostTypeUnregister) {
            [[NSNotificationCenter defaultCenter] postNotificationName:CS_NOTIF_UNREGISTER
                                                                object:nil
                                                              userInfo:responseOk ? @{CURKeyStatus: CURKeyOK, CURKeyResponse: @"Unregistered Successfully"} : @{CURKeyStatus: CURKeyNOK, CURKeyResponse: error ? error.description : @""}];
        }
        
        if (error != nil) {
            CS_Log_Warning(@"Warning: %ld , %@",(long)error.code, error.localizedDescription);
            last_errorCode = (long) error.code;
        } else {
            last_errorCode = 0;
        }
        
        return error == nil && responseOk;
        
    }
}

- (void) postRequestWithParameters:(NSDictionary *)parameters
                            suffix:(NSString *)suffix
                           success:(void(^)(id responseObject))success
                           failure:(void(^)(NSError *error))failure {
    
    @synchronized(self) {
        
        NSString *sUrl = [NSString stringWithFormat:@"%@%@",[[CurioSettings shared] serverUrl],suffix];
        
        CS_Log_Info(@"URL: %@ %@",sUrl,CS_RM_STR_NEWLINE(parameters));
        
        NSURL *url = [NSURL URLWithString:sUrl];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
        [request setHTTPMethod:@"POST"];
        [request setHTTPShouldHandleCookies:NO];
        [request setValue:CS_OPT_USER_AGENT forHTTPHeaderField:@"User-Agent"];
        [request setHTTPBody:[[[CurioUtil shared] dictToPostBody:parameters] dataUsingEncoding:NSUTF8StringEncoding]];
        [request setTimeoutInterval:30.0];
        
        NSURLResponse * response = nil;
        NSError * error = nil;
        NSData * data  = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        
        if (error != nil) {
            CS_Log_Warning(@"Warning: %ld , %@",(long)error.code, error.localizedDescription);
            failure(error);
        } else {
            NSDictionary *ret =  [[CurioUtil shared] fromJson:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] percentEncoded:FALSE error:&error];
            if (error != nil) {
                CS_Log_Warning(@"Error: %ld , %@",(long)error.code, error.localizedDescription);
                failure(error);
            } else {
                success(ret);
            }
        }
    }
}

- (void) postRequestResultWithParameters:(NSDictionary *)parameters
                            suffix:(NSString *)suffix
                            success:(void(^)(void))success
                           failure:(void(^)(NSError *error))failure {
    
    @synchronized(self) {
        
        NSString *sUrl = [NSString stringWithFormat:@"%@%@",[[CurioSettings shared] serverUrl],suffix];
        
        CS_Log_Info(@"URL: %@ %@",sUrl,CS_RM_STR_NEWLINE(parameters));
        
        NSURL *url = [NSURL URLWithString:sUrl];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
        [request setHTTPMethod:@"POST"];
        [request setHTTPShouldHandleCookies:NO];
        [request setValue:CS_OPT_USER_AGENT forHTTPHeaderField:@"User-Agent"];
        [request setHTTPBody:[[[CurioUtil shared] dictToPostBody:parameters] dataUsingEncoding:NSUTF8StringEncoding]];
        [request setTimeoutInterval:30.0];
        
        NSHTTPURLResponse * response = nil;
        NSError * error = nil;
        [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        
        if (error != nil) {
            CS_Log_Warning(@"Warning: %ld , %@",(long)error.code, error.localizedDescription);
            failure(error);
        } else {
            if (response.statusCode == 200) {
                success();
            }else {
                CS_Log_Warning(@"Error: %ld , %@",(long)error.code, error.localizedDescription);
                failure(error);
            }
        }
    }
}


- (BOOL) postAction:(CurioAction *)action {
    
    
    CPostType type = action.actionType == CActionTypeStartSession ? CPostTypeStartSession :
    action.actionType == CActionTypeStartScreen ? CPostTypeStartScreen :
    action.actionType == CActionTypeEndScreen ? CPostTypeEndScreen :
    action.actionType == CActionTypeEndSession ? CPostTypeEndSession :
    action.actionType == CActionTypeSendEvent ? CPostTypeSendEvent :
    action.actionType == CActionTypeUnregister ? CPostTypeUnregister :
    action.actionType == CActionTypeEndEvent ? CPostTypeEndEvent : 0;
    
    
    return [self postRequest:type parameters:[[CurioActionToolkit shared] actionToOnlinePostParameters:action] action:action];
}


- (BOOL) postPeriodicDispatchActions:(NSArray *)actions {
    
    
    return [self postRequest:CPostTypePDR parameters:[[CurioActionToolkit shared] actionsToPDRPostParameters:actions] action:nil];
}

- (BOOL) postOfflineActions:(NSArray *)actions {
    
    
    return [self postRequest:CPostTypeOCR parameters:[[CurioActionToolkit shared] actionsToOCRPostParameters:actions] action:nil];
}

- (BOOL) tryToFixResponseProblems:(CurioPostOfficeRetryBlock) retryBlock {
    
    // Precondition failed
    if (last_responseCode == 412) {
        
        CS_Log_Error(@"Invalid Api Key and/or Tracking Code !!!");
        return FALSE;
    }
    
    // Timeout mode
    if (last_errorCode == -1001) {
        CS_Log_Error(@"On timeouts, there is no need to retry !!!");
        return FALSE;
    }
    
    BOOL fixed =false;
    for (int i=0;i<CS_OPT_MAX_POST_OFFICE_RETRY_COUNT;i++) {
        
        
        CS_Log_Info(@"Re-trying to fix problem.. attempt no: %d last response code: %d",i+1,last_responseCode);
        // It is UNAUTHORIZED.
        // Probably lost session on server side
        // Try to re-enable session
        if (last_responseCode == 401 || last_responseCode == 0) {
            
            [[CurioSDK shared] reGenerateSessionCode];
            
            CurioAction *startSession = [CurioAction actionStartSession];
            
            if ([self postAction:startSession]) {
                if (retryBlock()) {
                    
                    CS_Log_Info(@"Session Re-Created on server.");
                    fixed = true;
                    [[NSNotificationCenter defaultCenter] postNotificationName:CS_NOTIF_REGISTERED_NEW_SESSION_CODE object:nil];
                    break;
                    
                }
            } else {
                
                CS_Log_Error(@"Could not fix response problem. Last status code: %d",last_responseCode);
                
            }
        } else {
            if (retryBlock()) {
                CS_Log_Info(@"Retry worked... problem fixed.");
                [[NSNotificationCenter defaultCenter] postNotificationName:CS_NOTIF_REGISTERED_NEW_SESSION_CODE object:nil];
                fixed = true;
            }
        }
        
    }
    
    if (!fixed) {
        CS_Log_Warning(@"No luck at fixing problem. Status code: %d",last_responseCode);
    }
    
    return fixed;
    
}

- (void) flushAwaitingOfflineActions:(NSMutableArray *)oactions {
    
    if (oactions.count  > 0 && [[CurioSDK shared] retryCount] < CURMaxRequestRetryCount) {
        
        [CurioSDK shared].retryCount++;
        
        if ([self postOfflineActions:oactions]) {
            [[CurioDBToolkit shared] deleteRecords:oactions];
            [oactions removeAllObjects];
        } else {
            // A Problem with offline post
            [self tryToFixResponseProblems:^BOOL{
                if ([self postOfflineActions:oactions]) {
                    [[CurioDBToolkit shared] deleteRecords:oactions];
                    [oactions removeAllObjects];
                    return TRUE;
                }
                
                return FALSE;
            }];
        }
    }
    
}

- (void) flushAwaitingPDRActions:(NSMutableArray *)pactions {
    
    if (pactions.count > 0 && [[CurioSDK shared] retryCount] < CURMaxRequestRetryCount) {
        
        [CurioSDK shared].retryCount++;
        
        if ([self postPeriodicDispatchActions:pactions]) {
            [[CurioDBToolkit shared] deleteRecords:pactions];
            [pactions removeAllObjects];
        } else {
            // A Problem with pdr post
            [self tryToFixResponseProblems:^BOOL{
                if ([self postPeriodicDispatchActions:pactions]) {
                    [[CurioDBToolkit shared] deleteRecords:pactions];
                    [pactions removeAllObjects];
                    
                    return TRUE;
                }
                return FALSE;
            }];
        }
    }
    
}

- (void) tryToPostAwaitingActions:(BOOL) canRunOnMainThread {
    
    if (pthread_mutex_trylock(&mutex) != 0)
    {
        return;
    }
    
    
    // To make sure we are not running
    // in main thread
    if ([NSThread isMainThread] && canRunOnMainThread) {
        
        pthread_mutex_unlock(&mutex);
        
        [opQueue addOperationWithBlock:^{
            [self tryToPostAwaitingActions:canRunOnMainThread];
        }];
        
        
        return;
    }
    
    NSArray *actions = [[CurioDBToolkit shared] getActions:CS_OPT_MAX_ACTION_TO_READ_PER_POST];
    
    // We are not online so we should mark records we fetched
    // as offline records because it should be sent as offline
    // cache records next time
    if (![[CurioNetwork shared] isOnline]) {
        
        [[CurioDBToolkit shared] markAsOfflineRecords:actions];
        NSMutableArray *offlineActions = [NSMutableArray new];
        [offlineActions addObjectsFromArray:actions];
        [self flushAwaitingOfflineActions:offlineActions];
    } else {
        // We are online... it is good to go
        NSMutableArray *offlineActions = [NSMutableArray new];
        NSMutableArray *pdrActions = [NSMutableArray new];
        
        int _curActioNum = 0;
        
        for (CurioAction *action in actions) {
            
            _curActioNum++;
            
            CS_Log_Debug(@"Processing actions %d of %lu - %@",_curActioNum,(unsigned long)[actions count],(CS_NSN_IS_TRUE(action.isOnline) ? @"ONLINE" : @"OFFLINE"));
            
            if (CS_NSN_IS_TRUE(action.isOnline)) {
                
                [self flushAwaitingOfflineActions:offlineActions];
                
                if (CS_NSN_IS_TRUE([[CurioSettings shared] periodicDispatchEnabled])
                    && action.actionType != CActionTypeStartSession
                    && action.actionType != CActionTypeEndSession
                    && action.actionType != CActionTypeUnregister) {
                    
                    [pdrActions addObject:action];
                    
                } else  {
                    
                    // ONLINE POST IN ONLINE STATE
                    if ([self postAction:action]) {
                        [[CurioDBToolkit shared] deleteRecords:[NSArray arrayWithObject:action]];
                    } else  {
                        
                        // A Problem with online post
                        BOOL fixed = (action.actionType == CActionTypeEndSession) ? FALSE :
                        [self tryToFixResponseProblems:^BOOL{
                            if ([self postAction:action]) {
                                [[CurioDBToolkit shared] deleteRecords:[NSArray arrayWithObject:action]];
                                
                                return TRUE;
                            }
                            
                            return FALSE;
                        }];
                        
                        if (!fixed) {
                            [[CurioDBToolkit shared] markAsOfflineRecords:[NSArray arrayWithObject:action]];
                            break;
                        }
                    }
                }
            } else {
                [self flushAwaitingPDRActions:pdrActions];
                
                [offlineActions addObject:action];
            }
            
        }
        
        [self flushAwaitingOfflineActions:offlineActions];
        [self flushAwaitingPDRActions:pdrActions];
    }
    
    pthread_mutex_unlock(&mutex);
    
    
    // If we read as max as we could that means
    // there may be more records to work on
    // So in case that there is, we are running same function again
    CS_Log_Debug(@"Actions count: %lu, RetryCount: %lu", (unsigned long)actions.count, (unsigned long)[CurioSDK shared].retryCount);
    if (actions.count == CS_OPT_MAX_ACTION_TO_READ_PER_POST && [CurioSDK shared].retryCount < CURMaxRequestRetryCount) {
        CS_Log_Debug(@"Trying to post rest of the actions...");
        [self tryToPostAwaitingActions:canRunOnMainThread];
    }
    
    
    
}

- (void) newActionNotified_background:(id) sender {
    
    if (!CS_NSN_IS_TRUE([[CurioSettings shared] periodicDispatchEnabled])) {
        [self tryToPostAwaitingActions:FALSE];
    }
}

- (void) newActionNotified:(id) sender {
    
    
    [self performSelectorInBackground:@selector(newActionNotified_background:) withObject:sender];
    
}

- (id) init {
    if ((self = [super init])) {
        
        
        if (opQueue == nil) {
            
            pthread_mutex_init(&mutex, NULL);
            
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newActionNotified:) name:CS_NOTIF_NEW_ACTION object:nil];
            
            opQueue = [NSOperationQueue new];
            [opQueue setMaxConcurrentOperationCount:2];
            
            [opQueue addOperationWithBlock:^{
                
                while (1) {
                    
                    if (CS_NSN_IS_TRUE([[CurioSettings shared] periodicDispatchEnabled])) {
                        
                        [NSThread sleepForTimeInterval:[[[CurioSettings shared] dispatchPeriod] intValue] * 60];
                        
                        [self tryToPostAwaitingActions:FALSE];
                    } else {
                        
                        [NSThread sleepForTimeInterval:60];
                    }
                }
            }];
        }
    }
    return self;
}



@end
