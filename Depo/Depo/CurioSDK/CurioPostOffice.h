//
//  CurioPostOffice.h
//  CurioSDK
//
//  Changed by Can Ciloglu on 30/01/15.
//  Created by Harun Esur on 19/09/14.
//  Copyright (c) 2014 Turkcell. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, CPostType) {
    CPostTypeOCR = 0,
    CPostTypePDR = 1,
    CPostTypeStartScreen = 2,
    CPostTypeEndScreen = 3,
    CPostTypeSendEvent = 4,
    CPostTypeStartSession = 5,
    CPostTypeEndSession = 6,
    CPostTypeUnregister = 7,
    CPostTypeEndEvent = 8,
};


typedef BOOL(^CurioPostOfficeRetryBlock)(void);

@interface CurioPostOffice : NSObject {
    
    int last_responseCode;
    long last_errorCode;

}

/**
 Returns shared instance of CurioPostOffice
 
 @return CurioPostOffice shared instance
 */
+ (CS_INSTANCETYPE) shared;

/**
 *  Tries to post awaiting actions stored in DB if possible
 *
 *  @param canRunOnMainThread If true, it will block process if you are calling on main thread.
 */
- (void) tryToPostAwaitingActions:(BOOL) canRunOnMainThread;

- (void) postRequestWithParameters:(NSDictionary *)parameters
                            suffix:(NSString *)suffix
                           success:(void(^)(id responseObject))success
                           failure:(void(^)(NSError *error))failure;

- (void) postRequestResultWithParameters:(NSDictionary *)parameters
                                  suffix:(NSString *)suffix
                                 success:(void(^)(void))success
                                 failure:(void(^)(NSError *error))failure;
@end
