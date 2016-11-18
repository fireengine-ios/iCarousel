//
//  CurioActionToolkit.m
//  CurioSDK
//
//  Changed by Can Ciloglu on 30/01/15.
//  Created by Harun Esur on 19/09/14.
//  Copyright (c) 2014 Turkcell. All rights reserved.
//

#import "CurioSDK.h"

/**
 
    Contains various functions to ease for conversions
    of Action objects into dictionary object to transform
    into API request models.
 
 */
@implementation CurioActionToolkit



+ (CS_INSTANCETYPE) shared {
    static dispatch_once_t once;
    
    static id instance;
    
    dispatch_once(&once, ^{
        instance = [self new];
    });
    
    return instance;
}

/**
 
    Converts action arrays into Offline Cache Requests (OCR). Documented as below
 
    ApiKey
    SessionTimeout
    VisitorCode
    TrackingCode
    ScreenWidth
    ScreenHeight
    ActivityWidth
    ActivityHeight
    Language
    SimOperator
    SimContryIso
    NetworkOperatorName
    connType
    Brand
    Model
    Os
    OsVer
    SdkVer
    AppVersion
    JSON Data 	[
        {type:0 (startSession), timestamp:123456789, sessionCode},
        {type:1 (endSession), timestamp:123456789, sessionCode},
        {type:2 (startScreen), timestamp:123456789, sessionCode, title, path, hitCode},
        {type:3 (endScreen), timestamp:123456789, sessionCode , title, path, hitCode},
        {type:4 (sendEvent), timestamp:123456789, sessionCode , eventKey, eventValue}

 
 
 */
- (NSDictionary *) actionsToOCRPostParameters:(NSArray *) actions {
    
    NSMutableDictionary *ret = [NSMutableDictionary new];
    
    
    [ret addEntriesFromDictionary:[CurioAction defaultActionProperties]];
    
    // For offline there is not session code, every session code binded within its
    // own record
    [ret removeObjectForKey:CS_HTTP_PARAM_SESSION_CODE];
    
    NSMutableArray *dataArray = [NSMutableArray new];
    
    for (CurioAction *action in actions) {
        
        NSMutableDictionary *actDict = [NSMutableDictionary new];
        
        [actDict setObject:[NSNumber numberWithInt:action.actionType] forKey:CS_HTTP_JSON_VARNAME_TYPE];
        [actDict setObject:action.stamp forKey:CS_HTTP_JSON_VARNAME_TIMESTAMP];
        [actDict setObject:CS_NULL_IF_NIL([action.properties objectForKey:CS_HTTP_PARAM_SESSION_CODE]) forKey:CS_HTTP_PARAM_SESSION_CODE];
        
        if (action.actionType == CActionTypeStartScreen) {
            
            [actDict setObject:action.title forKey:CS_HTTP_JSON_VARNAME_PAGETITLE];
            [actDict setObject:action.path forKey:CS_HTTP_JSON_VARNAME_PATH];
            [actDict setObject:action.hitCode forKey:CS_HTTP_JSON_VARNAME_HITCODE];
            
        } else if (action.actionType == CActionTypeEndScreen) {
            
            [actDict setObject:action.title forKey:CS_HTTP_JSON_VARNAME_PAGETITLE];
            [actDict setObject:action.path forKey:CS_HTTP_JSON_VARNAME_PATH];
            [actDict setObject:action.hitCode forKey:CS_HTTP_JSON_VARNAME_HITCODE];
            
        } else if (action.actionType == CActionTypeSendEvent) {
            
            [actDict setObject:action.eventKey forKey:CS_HTTP_JSON_VARNAME_EVENT_KEY];
            [actDict setObject:action.eventValue forKey:CS_HTTP_JSON_VARNAME_EVENT_VALUE];
            [actDict setObject:action.hitCode forKey:CS_HTTP_JSON_VARNAME_EVENTCODE];
            
        } else if (action.actionType == CActionTypeEndEvent) {
            
            [actDict setObject:action.eventKey forKey:CS_HTTP_JSON_VARNAME_EVENT_KEY];
            [actDict setObject:action.eventValue forKey:CS_HTTP_JSON_VARNAME_EVENT_VALUE];
            [actDict setObject:CS_NULL_IF_NIL([action.properties objectForKey:CS_HTTP_JSON_VARNAME_EVENT_DURATION]) forKey:CS_HTTP_JSON_VARNAME_EVENT_DURATION];
            [actDict setObject:action.hitCode forKey:CS_HTTP_JSON_VARNAME_EVENTCODE];
            
        }
        
        [dataArray addObject:actDict];
        
    }
    
    [ret setObject:[[CurioUtil shared] toJson:dataArray enablePercentEncoding:FALSE] forKey: CURKeyData];
    
    return ret;

}

- (NSDictionary *) actionsToPDRPostParameters:(NSArray *) actions {
    
    NSMutableDictionary *ret = [NSMutableDictionary new];
    
    NSDictionary *defaultProperties = [CurioAction defaultActionProperties];
    
    [ret setObject:CS_NULL_IF_NIL([defaultProperties objectForKey:CS_HTTP_PARAM_SESSION_CODE]) forKey:CS_HTTP_PARAM_SESSION_CODE];
    [ret setObject:CS_ZERO_IF_NIL([defaultProperties objectForKey:CS_HTTP_PARAM_SESSION_TIMEOUT])  forKey:CS_HTTP_PARAM_SESSION_TIMEOUT];
    [ret setObject:CS_NULL_IF_NIL([defaultProperties objectForKey:CS_HTTP_PARAM_VISITOR_CODE])  forKey:CS_HTTP_PARAM_VISITOR_CODE];
    [ret setObject:CS_NULL_IF_NIL([defaultProperties objectForKey:CS_HTTP_PARAM_TRACKING_CODE])  forKey:CS_HTTP_PARAM_TRACKING_CODE];
    
    NSMutableArray *dataArray = [NSMutableArray new];
    
    for (CurioAction *action in actions) {
        //Every action must have a hitCode
        if (action.hitCode.length < 1) {
            CS_Log_Warning(@"Every action must have a hitCode");
            continue;
        }
        
        NSMutableDictionary *actDict = [NSMutableDictionary new];
        
        [actDict setObject:[NSNumber numberWithInt:action.actionType] forKey:CS_HTTP_JSON_VARNAME_TYPE];
        [actDict setObject:action.stamp forKey:CS_HTTP_JSON_VARNAME_TIMESTAMP];
        [actDict setObject:CS_NULL_IF_NIL([action.properties objectForKey:CS_HTTP_PARAM_SESSION_CODE]) forKey:CS_HTTP_PARAM_SESSION_CODE];
        
        if (action.actionType == CActionTypeStartScreen) {
            
            [actDict setObject:action.title forKey:CS_HTTP_JSON_VARNAME_PAGETITLE];
            [actDict setObject:action.path forKey:CS_HTTP_JSON_VARNAME_PATH];
            [actDict setObject:action.hitCode forKey:CS_HTTP_JSON_VARNAME_HITCODE];
            
        } else if (action.actionType == CActionTypeEndScreen) {
            
            [actDict setObject:action.title forKey:CS_HTTP_JSON_VARNAME_PAGETITLE];
            [actDict setObject:action.path forKey:CS_HTTP_JSON_VARNAME_PATH];
            [actDict setObject:action.hitCode forKey:CS_HTTP_JSON_VARNAME_HITCODE];
            
        } else if (action.actionType == CActionTypeSendEvent) {

            [actDict setObject:action.eventKey forKey:CS_HTTP_JSON_VARNAME_EVENT_KEY];
            [actDict setObject:action.eventValue forKey:CS_HTTP_JSON_VARNAME_EVENT_VALUE];
            [actDict setObject:action.hitCode forKey:CS_HTTP_JSON_VARNAME_EVENTCODE];
            
        } else if (action.actionType == CActionTypeEndEvent) {
            
            [actDict setObject:action.eventKey forKey:CS_HTTP_JSON_VARNAME_EVENT_KEY];
            [actDict setObject:action.eventValue forKey:CS_HTTP_JSON_VARNAME_EVENT_VALUE];
            [actDict setObject:CS_NULL_IF_NIL([action.properties objectForKey:CS_HTTP_JSON_VARNAME_EVENT_DURATION]) forKey:CS_HTTP_JSON_VARNAME_EVENT_DURATION];
            [actDict setObject:action.hitCode forKey:CS_HTTP_JSON_VARNAME_EVENTCODE];
            
        }
        
        [dataArray addObject:actDict];
    }
    
    [ret setObject:[[CurioUtil shared] toJson:dataArray enablePercentEncoding:FALSE] forKey: CURKeyData];
    
    return ret;
}

- (NSDictionary *) actionToOnlinePostParameters:(CurioAction *) action {
    
    NSMutableDictionary *ret = [NSMutableDictionary new];
  
    NSMutableDictionary *actionProps = [action properties];
    
    
    // If session code is different than current one
    // And there is no action to manipulate session
    // then refresh session code for online post
    if (action.actionType != CActionTypeStartSession &&
        action.actionType != CActionTypeEndSession &&
        ![(NSString *)[actionProps objectForKey:CS_HTTP_PARAM_SESSION_CODE] isEqualToString:[[CurioSDK shared] sessionCode]] ) {
        
        [actionProps setObject:CS_NULL_IF_NIL([[CurioSDK shared] sessionCode]) forKey:CS_HTTP_PARAM_SESSION_CODE];
    }
    
    if (action.actionType == CActionTypeStartSession) {
        
        [ret addEntriesFromDictionary:actionProps];
        
    } else if (action.actionType == CActionTypeStartScreen) {
        
        [ret setObject:CS_NULL_IF_NIL([actionProps objectForKey:CS_HTTP_PARAM_SESSION_CODE]) forKey:CS_HTTP_PARAM_SESSION_CODE];
        [ret setObject:CS_ZERO_IF_NIL([actionProps objectForKey:CS_HTTP_PARAM_SESSION_TIMEOUT]) forKey:CS_HTTP_PARAM_SESSION_TIMEOUT];
        [ret setObject:CS_NULL_IF_NIL([actionProps objectForKey:CS_HTTP_PARAM_VISITOR_CODE]) forKey:CS_HTTP_PARAM_VISITOR_CODE];
        [ret setObject:CS_NULL_IF_NIL([actionProps objectForKey:CS_HTTP_PARAM_TRACKING_CODE]) forKey:CS_HTTP_PARAM_TRACKING_CODE];
        [ret setObject:CS_SET_IF_NOT_NIL(action.title,@"NULL") forKey:CS_HTTP_PARAM_TITLE];
        [ret setObject:CS_SET_IF_NOT_NIL(action.path,@"NULL") forKey:CS_HTTP_PARAM_PATH];
        
    } else if (action.actionType == CActionTypeEndScreen) {
        
        [ret setObject:CS_NULL_IF_NIL([actionProps objectForKey:CS_HTTP_PARAM_SESSION_CODE]) forKey:CS_HTTP_PARAM_SESSION_CODE];
        [ret setObject:CS_ZERO_IF_NIL([actionProps objectForKey:CS_HTTP_PARAM_SESSION_TIMEOUT]) forKey:CS_HTTP_PARAM_SESSION_TIMEOUT];
        [ret setObject:CS_NULL_IF_NIL([actionProps objectForKey:CS_HTTP_PARAM_VISITOR_CODE]) forKey:CS_HTTP_PARAM_VISITOR_CODE];
        [ret setObject:CS_NULL_IF_NIL([actionProps objectForKey:CS_HTTP_PARAM_TRACKING_CODE]) forKey:CS_HTTP_PARAM_TRACKING_CODE];
        [ret setObject:CS_SET_IF_NOT_NIL(action.title,@"NULL") forKey:CS_HTTP_PARAM_TITLE];
        [ret setObject:CS_SET_IF_NOT_NIL(action.path,@"NULL") forKey:CS_HTTP_PARAM_PATH];
        [ret setObject:CS_SET_IF_NOT_NIL(action.hitCode,@"NULL") forKey:CS_HTTP_PARAM_HIT_CODE];
        
    } else if (action.actionType == CActionTypeSendEvent) {
        
        [ret setObject:CS_NULL_IF_NIL([actionProps objectForKey:CS_HTTP_PARAM_SESSION_CODE]) forKey:CS_HTTP_PARAM_SESSION_CODE];
        [ret setObject:CS_ZERO_IF_NIL([actionProps objectForKey:CS_HTTP_PARAM_SESSION_TIMEOUT]) forKey:CS_HTTP_PARAM_SESSION_TIMEOUT];
        [ret setObject:CS_NULL_IF_NIL([actionProps objectForKey:CS_HTTP_PARAM_VISITOR_CODE]) forKey:CS_HTTP_PARAM_VISITOR_CODE];
        [ret setObject:CS_NULL_IF_NIL([actionProps objectForKey:CS_HTTP_PARAM_TRACKING_CODE]) forKey:CS_HTTP_PARAM_TRACKING_CODE];
        [ret setObject:CS_SET_IF_NOT_NIL(action.eventKey,@"NULL") forKey:CS_HTTP_PARAM_EVENT_KEY];
        [ret setObject:CS_SET_IF_NOT_NIL(action.eventValue,@"NULL") forKey:CS_HTTP_PARAM_EVENT_VALUE];
        
    } else if (action.actionType == CActionTypeEndEvent) {
        //TODO
        [ret setObject:CS_NULL_IF_NIL([actionProps objectForKey:CS_HTTP_PARAM_SESSION_CODE]) forKey:CS_HTTP_PARAM_SESSION_CODE];
        [ret setObject:CS_ZERO_IF_NIL([actionProps objectForKey:CS_HTTP_PARAM_SESSION_TIMEOUT]) forKey:CS_HTTP_PARAM_SESSION_TIMEOUT];
        [ret setObject:CS_NULL_IF_NIL([actionProps objectForKey:CS_HTTP_PARAM_VISITOR_CODE]) forKey:CS_HTTP_PARAM_VISITOR_CODE];
        [ret setObject:CS_NULL_IF_NIL([actionProps objectForKey:CS_HTTP_PARAM_TRACKING_CODE]) forKey:CS_HTTP_PARAM_TRACKING_CODE];
        [ret setObject:CS_SET_IF_NOT_NIL(action.eventKey,@"NULL") forKey:CS_HTTP_PARAM_EVENT_KEY];
        [ret setObject:CS_SET_IF_NOT_NIL(action.eventValue,@"NULL") forKey:CS_HTTP_PARAM_EVENT_VALUE];
        [ret setObject:CS_SET_IF_NOT_NIL([action.properties objectForKey:CS_HTTP_PARAM_EVENT_DURATION],@"NULL") forKey:CS_HTTP_PARAM_EVENT_DURATION];
        [ret setObject:CS_SET_IF_NOT_NIL(action.hitCode,@"NULL") forKey:CS_HTTP_PARAM_EVENT_CODE];
        
    } else if (action.actionType == CActionTypeEndSession) {
        
        [ret setObject:CS_NULL_IF_NIL([actionProps objectForKey:CS_HTTP_PARAM_SESSION_CODE]) forKey:CS_HTTP_PARAM_SESSION_CODE];
        [ret setObject:CS_ZERO_IF_NIL([actionProps objectForKey:CS_HTTP_PARAM_SESSION_TIMEOUT]) forKey:CS_HTTP_PARAM_SESSION_TIMEOUT];
        [ret setObject:CS_NULL_IF_NIL([actionProps objectForKey:CS_HTTP_PARAM_VISITOR_CODE]) forKey:CS_HTTP_PARAM_VISITOR_CODE];
        [ret setObject:CS_NULL_IF_NIL([actionProps objectForKey:CS_HTTP_PARAM_TRACKING_CODE]) forKey:CS_HTTP_PARAM_TRACKING_CODE];
    } else if (action.actionType == CActionTypeUnregister) {
    
        [ret setObject:CS_NULL_IF_NIL([actionProps objectForKey:CS_HTTP_PARAM_SESSION_CODE]) forKey:CS_HTTP_PARAM_SESSION_CODE];
        [ret setObject:CS_ZERO_IF_NIL([actionProps objectForKey:CS_HTTP_PARAM_SESSION_TIMEOUT]) forKey:CS_HTTP_PARAM_SESSION_TIMEOUT];
        [ret setObject:CS_NULL_IF_NIL([actionProps objectForKey:CS_HTTP_PARAM_VISITOR_CODE]) forKey:CS_HTTP_PARAM_VISITOR_CODE];
        [ret setObject:CS_NULL_IF_NIL([actionProps objectForKey:CS_HTTP_PARAM_TRACKING_CODE]) forKey:CS_HTTP_PARAM_TRACKING_CODE];
        [ret setObject:CS_NULL_IF_NIL([actionProps objectForKey:CURHttpParamCustomId]) forKey:CURHttpParamCustomId];
    }
    
    return ret;
}

@end
