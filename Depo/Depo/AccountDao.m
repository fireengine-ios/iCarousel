//
//  AccountDao.m
//  Depo
//
//  Created by Salih Topcu on 05.01.2015.
//  Copyright (c) 2015 com.igones. All rights reserved.
//

#import "AccountDao.h"
#import "AppUtil.h"

@implementation AccountDao

- (void) requestCurrentAccount {
    requestMethod = RequestMethodGetCurrentSubscription;
    NSURL *url = [NSURL URLWithString:GET_CURRENT_SUBSCRIPTION_URL];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setDelegate:self];
    [self sendGetRequest:request];
}

- (void) requestOffers {
    requestMethod = RequestMethodGetOffers;
    NSURL *url = [NSURL URLWithString:GET_SUBSCRIPTION_OFFERS_URL];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setDelegate:self];
    [self sendGetRequest:request];
}

- (void) requestActivateOffer: (Offer *)offer {
    requestMethod = RequestMethodActivateOffer;
    NSURL *url = [NSURL URLWithString:REQUEST_ACTIVATE_OFFER_URL];
    
//    NSDictionary *metadata = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO], @"X-Object-Meta-Favourite", nil];
//    NSDictionary *payload = [NSDictionary dictionaryWithObjectsAndKeys:metadata, @"metadata", nil];
    
    NSDictionary *payload = [NSDictionary dictionaryWithObjectsAndKeys:offer.offerId, @"aeOfferId", offer.name, @"aeOfferName", offer.campaignChannel, @"campaignChannel", offer.campaignCode, @"campaignCode", offer.campaignId, @"campaignId", offer.campaignUserCode, @"campaignUserCode", offer.cometParameters, @"cometParameters", offer.responseApi, @"responseApi", offer.validationKey, @"validationKey", offer.price, @"price", offer.role, @"role", offer.quotaString, @"quota", nil];
    
    SBJSON *json = [SBJSON new];
    NSString *jsonStr = [json stringWithObject:payload];
    NSData *postData = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"Add Offer Payload: %@", jsonStr);
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setPostBody:[postData mutableCopy]];
    [request setDelegate:self];
    [self sendPostRequest:request];
}

- (void) requestIsJobExists {
    requestMethod = RequestMethodIsJobExists;
    NSURL *url = [NSURL URLWithString:REQUEST_IS_JOB_EXISTS];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setDelegate:self];
    [self sendGetRequest:request];
}

//- (void) requestCancelSubscription: (Subscription *)subscription {
//    requestMethod = RequestMethodCancelSubscription;
//    NSURL *url = [NSURL URLWithString:REQUEST_CANCEL_SUBSCRIPTION_URL];
//    
//    NSDictionary *metadata = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO], @"X-Object-Meta-Favourite", nil];
//    NSDictionary *payload = [NSDictionary dictionaryWithObjectsAndKeys:metadata, @"metadata", nil];
//    
//    SBJSON *json = [SBJSON new];
//    NSString *jsonStr = [json stringWithObject:payload];
//    NSData *postData = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
//    
//    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
//    [request addRequestHeader:@"createdDate" value:subscription.createdDate];
//    [request addRequestHeader:@"lastModifiedDate" value:subscription.lastModifiedDate];
//    [request addRequestHeader:@"createdBy" value:subscription.createdBy];
//    [request addRequestHeader:@"lastModifiedBy" value:subscription.lastModifiedBy];
//    [request addRequestHeader:@"isCurrentSubscription" value:subscription.isCurrentSubscription ? @"1" : @"0"];
//    [request addRequestHeader:@"status" value:subscription.status];
//    
//    NSDictionary *planDict = [NSDictionary dictionaryWithObjectsAndKeys:subscription.plan.name, @"name", subscription.plan.displayName, @"displayName", subscription.plan.description, @"description", subscription.plan.price, @"price", subscription.plan.isDefault ? @"1" : @"2", @"isDefault", subscription.plan.role, @"role", subscription.plan.slcmOfferId, @"sclmOfferId", subscription.plan.cometOfferId, @"cometOfferId", subscription.plan.quota, @"quota", nil];
//    NSLog(@"PlanDictionary: %@", planDict);
//    [request addRequestHeader:@"subscriptionPlan" value:[NSString stringWithFormat:@"my dictionary is %@", planDict]];
//    
//    [request setPostBody:[postData mutableCopy]];
//    [request setDelegate:self];
//    [self sendPostRequest:request];
//}

- (void)requestFinished:(ASIHTTPRequest *)request {
    NSError *error = [request error];
    
    if (!error) {
        @try {
            NSString *responseStr = [request responseString];
            NSLog(@"RESULT: %@", responseStr);
            SBJSON *jsonParser = [SBJSON new];
            if (requestMethod == RequestMethodGetCurrentSubscription) {
                NSDictionary *responseDict = [jsonParser objectWithString:responseStr];
                Subscription *subscription = [self parseSubscription:responseDict];
                if (subscription != nil && subscription.plan != nil && subscription.plan.name != nil) {
                    [self shouldReturnSuccessWithObject:subscription];
                } else {
                    [self shouldReturnFailWithMessage:GENERAL_ERROR_MESSAGE];
                }
            } else if (requestMethod == RequestMethodGetOffers) {
                NSMutableArray *result = [[NSMutableArray alloc] init];
                NSArray *mainArray = [jsonParser objectWithString:responseStr];
                if (mainArray != nil && ![mainArray isKindOfClass:[NSNull class]]) {
                    for (NSDictionary *offerDict in mainArray) {
                        Offer *offer = [self parseOffer:offerDict];
                        if (offer != nil) {
                            [result addObject:offer];
                        }
                    }
                    [self shouldReturnSuccessWithObject:result];
                } else {
                    [self shouldReturnFailWithMessage:GENERAL_ERROR_MESSAGE];
                }
            } else if (requestMethod == RequestMethodActivateOffer) {
                if ([responseStr isEqualToString:@""]) {
                    [self shouldReturnSuccess];
                } else {
                    [self shouldReturnFailWithMessage:GENERAL_ERROR_MESSAGE];
                }
            } else if (requestMethod == RequestMethodIsJobExists) {
                NSDictionary *responseDict = [jsonParser objectWithString:responseStr];
                NSNumber *result = [responseDict objectForKey:@"isJobExists"];
                int resultInt = [self intByNumber:result];
                if (resultInt == 0 || resultInt == 1) {
                    [self shouldReturnSuccessWithObject:result];
                } else {
                    [self shouldReturnFailWithMessage:GENERAL_ERROR_MESSAGE];
                }
            }
        }
        @catch (NSException *e) {
            NSLog(@"Exception: %@", e);
        }
    } else {
        [self shouldReturnFailWithMessage:GENERAL_ERROR_MESSAGE];
    }
}

@end
