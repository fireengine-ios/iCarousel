//
//  SubscriptionsService.swift
//  Depo_LifeTech
//
//  Created by Bondar Yaroslav on 9/21/17.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Foundation

protocol SubscriptionsService {
    func activeSubscriptions(success: SuccessResponse?, fail: @escaping FailResponse,isLogin: Bool?)
    
    /// MAYBE WILL BE NEED
    //func currentSubscription(success: SuccessResponse?, fail: @escaping FailResponse)
    //func cancel(subscription: SubscriptionPlanBaseResponse, success: SuccessResponse?, fail: @escaping FailResponse)
}

class SubscriptionsServiceIml: BaseRequestService, SubscriptionsService {
    
    func activeSubscriptions(success: SuccessResponse?, fail: @escaping FailResponse, isLogin: Bool? = false) {
        debugLog("SubscriptionsServiceIml activeSubscriptions")
        
        let param = isLogin ?? false ? ActiveSubscriptionV2Parameters() : ActiveSubscriptionParameters()
        let handler = BaseResponseHandler<ActiveSubscriptionResponse, ObjectRequestResponse>(success: success, fail: fail)
        executeGetRequest(param: param, handler: handler)
    }

    /// MAYBE WILL BE NEED
//    func currentSubscription(success: SuccessResponse?, fail: @escaping FailResponse) {
//        let param = CurrentSubscriptionParameters()
//        let handler = BaseResponseHandler<CurrentSubscriptionResponse, ObjectRequestResponse>(success: success, fail: fail)
//        executeGetRequest(param: param, handler: handler)
//    }
    
    /// MAYBE WILL BE NEED
//    func cancel(subscription: SubscriptionPlanBaseResponse, success: SuccessResponse?, fail: @escaping FailResponse) {
//        
//        //    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
//        //    [request addRequestHeader:@"createdDate" value:subscription.createdDate];
//        //    [request addRequestHeader:@"lastModifiedDate" value:subscription.lastModifiedDate];
//        //    [request addRequestHeader:@"createdBy" value:subscription.createdBy];
//        //    [request addRequestHeader:@"lastModifiedBy" value:subscription.lastModifiedBy];
//        //    [request addRequestHeader:@"isCurrentSubscription" value:subscription.isCurrentSubscription ? @"1" : @"0"];
//        //    [request addRequestHeader:@"status" value:subscription.status];
//        //
//        //    NSDictionary *planDict = [NSDictionary dictionaryWithObjectsAndKeys:subscription.plan.name, @"name", subscription.plan.displayName, @"displayName", subscription.plan.description, @"description", subscription.plan.price, @"price", subscription.plan.isDefault ? @"1" : @"2", @"isDefault", subscription.plan.role, @"role", subscription.plan.slcmOfferId, @"sclmOfferId", subscription.plan.cometOfferId, @"cometOfferId", subscription.plan.quota, @"quota", nil];
//        //    NSLog(@"PlanDictionary: %@", planDict);
//        //    [request addRequestHeader:@"subscriptionPlan" value:[NSString stringWithFormat:@"my dictionary is %@", planDict]];
//        //
//        //    [request setPostBody:[postData mutableCopy]];
//        //    [request setDelegate:self];
//        //    [self sendPostRequest:request];
//        
//        let param = CancelSubscriptionParameters()
//        let handler = BaseResponseHandler<CancelSubscriptionResponse, ObjectRequestResponse>(success: success, fail: fail)
//        executePostRequest(param: param, handler: handler)
//    }
}
