//
//  CurioActionToolkit.h
//  CurioSDK
//
//  Created by Harun Esur on 19/09/14.
//  Copyright (c) 2014 Turkcell. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CurioActionToolkit : NSObject

/**
 Returns shared instance of CurioActionToolkit
 
 @return CurioActionToolkit shared instance
 */
+ (CS_INSTANCETYPE) shared;

/**
 
 Converts action arrays into Offline Cache Requests (OCR) parameters. Documented as below;
 
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
- (NSDictionary *) actionsToOCRPostParameters:(NSArray *) actions;


/**

 Converts action arrays into Periodic Dispatch Request (PDR) parameters. Documented as below;
 
 SessionCode
 SessionTimeout
 VisitorCode
 TrackingCode
 JSON Data 	[
 {type:2 (startScreen), timestamp:123456789, title, path, hitCode},
 {type:3 (endScreen), timestamp:123456789, title, path, hitCode},
 {type:4 (sendEvent), timestamp:123456789, eventKey, eventValue}
 
 */
- (NSDictionary *) actionsToPDRPostParameters:(NSArray *) actions;

/**
 
 Converts action object into online post request parameters. Documented as below;
 
 For startSession requests
 
 ApiKey
 SessionCode
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
 
 For endSession requests
 
 SessionCode
 SessionTimeout
 VisitorCode
 TrackingCode

 For startScreen requests
 
 SessionCode
 SessionTimeout
 VisitorCode
 TrackingCode
 Title
 Path

 For endScreen requests
 
 SessionCode
 SessionTimeout
 VisitorCode
 TrackingCode
 Title
 Path
 HitCode

 For sendEvent requests
 
 SessionCode
 SessionTimeout
 VisitorCode
 TrackingCode
 eventKey
 eventValue


 
 */
- (NSDictionary *) actionToOnlinePostParameters:(CurioAction *) action;

@end
