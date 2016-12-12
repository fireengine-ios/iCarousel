//
//  AccountDao.m
//  Depo
//
//  Created by Salih Topcu on 05.01.2015.
//  Copyright (c) 2015 com.igones. All rights reserved.
//

#import "AccountDao.h"
#import "AppUtil.h"
#import "AppConstants.h"

@implementation AccountDao

- (void) requestCurrentAccount {
    requestMethod = RequestMethodGetCurrentSubscription;
    NSURL *url = [NSURL URLWithString:GET_CURRENT_SUBSCRIPTION_URL];
    NSMutableURLRequest *tempRequest = [[NSMutableURLRequest alloc] initWithURL:url];
    NSURLRequest *finalRequest = [self sendGetRequest:tempRequest];
    
    NSURLSessionDataTask *task = [[DepoHttpManager sharedInstance].urlSession dataTaskWithRequest:finalRequest completionHandler:[self createCompletionHandlerWithCompletion:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self requestFailed:response];
            });
        }
        else {
            if ([self checkResponseHasError:response]) {
                [self requestFailed:response];
            }
            else {
                NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                Subscription *currentSubscription = [self parseSubscription:dict];
                if (currentSubscription != nil) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self shouldReturnSuccessWithObject:currentSubscription];
                    });
                }
                
                else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self shouldReturnFailWithMessage:GENERAL_ERROR_MESSAGE];
                    });
                    
                }
            }
        }
    }]];
    self.currentTask = task;
    [task resume];
}

- (void) requestActiveSubscriptions {
    requestMethod = RequestMethodGetActiveSubscriptions;
    NSURL *url = [NSURL URLWithString:GET_ACTIVE_SUBSCRIPTIONS_URL];
    NSMutableURLRequest *tempRequest = [[NSMutableURLRequest alloc] initWithURL:url];
    NSURLRequest *finalRequest = [self sendGetRequest:tempRequest];
    
    NSURLSessionDataTask *task = [[DepoHttpManager sharedInstance].urlSession dataTaskWithRequest:finalRequest completionHandler:[self createCompletionHandlerWithCompletion:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self requestFailed:response];
            });
        }
        else {
            if (![self checkResponseHasError:response]) {
                NSMutableArray *subscriptions = [[NSMutableArray alloc] init];
                NSArray *responseArray = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
                if(responseArray != nil && [responseArray isKindOfClass:[NSArray class]]) {
                    for(NSDictionary *subscriptionDict in responseArray) {
                        Subscription *subscription = [self parseSubscription:subscriptionDict];
                        [subscriptions addObject:subscription];
                    }
                    NSArray *sortedArray = [subscriptions sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
                        NSNumber *firstQuota = [NSNumber numberWithFloat:[(Subscription*) a plan].quota];
                        NSNumber *secondQuota = [NSNumber numberWithFloat:[(Subscription*) b plan].quota];
                        return [firstQuota compare:secondQuota];
                    }];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self shouldReturnSuccessWithObject:sortedArray];
                    });
                }
                else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self shouldReturnFailWithMessage:GENERAL_ERROR_MESSAGE];
                    });
                }
            }
            else {
                [self requestFailed:response];
            }
        }
    }]];
    self.currentTask = task;
    [task resume];
}

- (void) requestOffers {
    requestMethod = RequestMethodGetOffers;
    NSURL *url = [NSURL URLWithString:GET_SUBSCRIPTION_OFFERS_URL];
    NSMutableURLRequest *tempRequest = [NSMutableURLRequest requestWithURL:url];
    NSURLRequest *finalRequest = [self sendGetRequest:tempRequest];
    NSURLSessionDataTask *task = [[DepoHttpManager sharedInstance].urlSession dataTaskWithRequest:finalRequest completionHandler:[self createCompletionHandlerWithCompletion:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self requestFailed:response];
            });
        }
        else {
            if ([self checkResponseHasError:response]) {
                [self requestFailed:response];
            }
            else {
                NSMutableArray *result = [[NSMutableArray alloc] init];
                NSArray *mainArr = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                if (mainArr !=nil && ![mainArr isKindOfClass:[NSNull class]]) {
                    for (NSDictionary *dict in mainArr) {
                        Offer *offer = [self parseOffer:dict];
                        if (offer != nil) {
                            [result addObject:offer];
                        }
                    }
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self shouldReturnSuccessWithObject:result];
                    });
                }
                else {
                    [self shouldReturnFailWithMessage:GENERAL_ERROR_MESSAGE];
                }
            }
        }
    }]];
    
    self.currentTask = task;
    [task resume];
}

- (void) requestActivateOffer: (Offer *)offer {
    requestMethod = RequestMethodActivateOffer;
    NSURL *url = [NSURL URLWithString:REQUEST_ACTIVATE_OFFER_URL];
    
    //    NSDictionary *metadata = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO], @"X-Object-Meta-Favourite", nil];
    //    NSDictionary *payload = [NSDictionary dictionaryWithObjectsAndKeys:metadata, @"metadata", nil];
    
    NSDictionary *payload = [NSDictionary dictionaryWithObjectsAndKeys:offer.offerId, @"aeOfferId", offer.name, @"aeOfferName", offer.campaignChannel, @"campaignChannel", offer.campaignCode, @"campaignCode", offer.campaignId, @"campaignId", offer.campaignUserCode, @"campaignUserCode", offer.cometParameters, @"cometParameters", offer.responseApi, @"responseApi", offer.validationKey, @"validationKey", offer.price, @"price", offer.role, @"role", offer.quotaString, @"quota", nil];
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:payload options:0 error:nil];

    NSMutableURLRequest *tempRequest = [NSMutableURLRequest requestWithURL:url];
    [tempRequest setHTTPBody:jsonData];
    NSURLRequest *finalRequest = [self sendPostRequest:tempRequest];
    NSURLSessionDataTask *task = [[DepoHttpManager sharedInstance].urlSession dataTaskWithRequest:finalRequest completionHandler:[self createCompletionHandlerWithCompletion:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSString *responseStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self requestFailed:response];
            });
        }
        else {
            if ([self checkResponseHasError:response]) {
                [self requestFailed:response];
            }
            else {
                if ([responseStr isEqualToString:@""]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self shouldReturnSuccess];
                    });
                    
                } else {
                    NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                    if(responseDict != nil && ![responseDict isKindOfClass:[NSNull class]]) {
                        NSNumber *errorCode = [responseDict objectForKey:@"errorCode"];
                        if(errorCode != nil && ![errorCode isKindOfClass:[NSNull class]]) {
                            if([errorCode intValue] == 1004) {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    [self shouldReturnFailWithMessage:NSLocalizedString(@"PackageSubscriptionQuotaErrorMessage", @"")];
                                });
                                return;
                            }
                        }
                    }
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self shouldReturnFailWithMessage:GENERAL_ERROR_MESSAGE];
                    });
                }
            }
        }
    }]];
    self.currentTask = task;
    [task resume];
}

- (void) requestIsJobExists {
    requestMethod = RequestMethodIsJobExists;
    NSURL *url = [NSURL URLWithString:REQUEST_IS_JOB_EXISTS];
    NSMutableURLRequest *tempRequest = [NSMutableURLRequest requestWithURL:url];
    NSURLRequest *finalRequest = [self sendGetRequest:tempRequest];
    NSURLSessionDataTask *task = [[DepoHttpManager sharedInstance].urlSession dataTaskWithRequest:finalRequest completionHandler:[self createCompletionHandlerWithCompletion:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self requestFailed:response];
            });
            
        }
        else {
            if ([self checkResponseHasError:response]) {
                [self requestFailed:response];
            }
            else {
                NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                NSNumber *result = [dict objectForKey:@"isJobExists"];
                int resultInt = [self intByNumber:result];
                if (resultInt == 0 || resultInt == 1) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self shouldReturnSuccessWithObject:result];
                    });
                } else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self shouldReturnFailWithMessage:GENERAL_ERROR_MESSAGE];
                    });
                }
            }
        }
    }]];
    self.currentTask = task;
    [task resume];
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

@end
