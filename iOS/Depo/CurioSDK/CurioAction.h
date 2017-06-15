//
//  CurioAction.h
//  CurioSDK
//
//  Changed by Can Ciloglu on 30/01/15.
//  Created by Harun Esur on 18/09/14.
//  Copyright (c) 2014 Turkcell. All rights reserved.
//

typedef NS_ENUM(NSUInteger, CActionType) {
            CActionTypeStartSession = 0,
            CActionTypeEndSession = 1,
            CActionTypeStartScreen = 2,
            CActionTypeEndScreen = 3,
            CActionTypeSendEvent = 4,
            CActionTypeEndEvent = 7,
            CActionTypeUnregister = 999,
};

#define CS_ACTION_TYPE_TO_STR(atype) (atype == CActionTypeStartSession ? @"StartSession" : \
                                        atype == CActionTypeEndSession ? @"EndSession" : \
                                        atype == CActionTypeStartScreen ? @"StartScreen" : \
                                        atype == CActionTypeEndScreen ? @"EndScreen" : \
                                        atype == CActionTypeSendEvent ? @"SendEvent" : \
                                        atype == CActionTypeUnregister ? @"Unregister" : \
                                        atype == CActionTypeEndEvent ? @"EndEvent" : @"")

@interface CurioAction : NSObject

@property (strong, nonatomic) NSString   *aId;
@property int actionType;
@property (strong, nonatomic) NSString   *stamp;
@property (strong, nonatomic) NSString   *title;
@property (strong, nonatomic) NSString   *path;
@property (strong, nonatomic) NSString   *hitCode;
@property (strong, nonatomic) NSString   *eventKey;
@property (strong, nonatomic) NSString   *eventValue;
@property (strong, nonatomic) NSNumber   *isOnline;
@property (strong, nonatomic) NSMutableDictionary   *properties;

/**
        
    Initializes object with properties
 
 */
- (id) init:(NSString *) aId
       type:(NSUInteger) type
      stamp:(NSString *) stamp
      title:(NSString *) title
       path:(NSString *) path
    hitCode:(NSString *) hitCode
   eventKey:(NSString *) eventKey
 eventValue:(NSString *) eventValue;

/**
    Returns properties as NSDictionary object
 
    @return Properties as NSDictionary object
 */
- (NSDictionary *) asDict;

/**
 
    Returns default action properties within NSDictionary
 
 */
+ (NSDictionary *) defaultActionProperties;

/**
    Creates action object for start session action
 
    @return All properties binded CurioAction object for startSession message
 */
+ (CurioAction *) actionStartSession;

/**
 *  Creates action object for end session action
 *
 *  @return All properties binded CurioAction object for endSession message
 */
+ (CurioAction *) actionEndSession;

/**
 *  Creates action object for start screen action
 *
 *
 *  @return All properties binded CurioAction object for endSession message
 */
+ (CurioAction *) actionStartScreen:(NSString *) title path:(NSString *)path ;


/**
 *  Creates action object for end screen action
 *
 *
 *  @return All properties binded CurioAction object for endSession message
 */
+ (CurioAction *) actionEndScreen:(NSString *) hitCode;


/**
 *  Creates action object for sendEvent action
 *
 *  @return  All properties binded CurioAction object for sendEvent message
 */
+ (CurioAction *) actionSendEvent:(NSString *) eventKey path:(NSString *)eventValue;

/**
 *  Creates action object for endEvent action
 *
 *
 *  @return All properties binded CurioAction object for endSession message
 */
+ (CurioAction *) actionEndEvent:(NSString *) hitCode eventDuration:(NSUInteger) eventDuration;

/**
 *  Creates action object for unregister action
 *
 *  @return  All properties binded CurioAction object for unregister message
 */
+ (CurioAction *) actionUnregister;

@end
