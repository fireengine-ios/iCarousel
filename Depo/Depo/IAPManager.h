//
//  IAPManager.h
//  Acdm_1
//
//  Created by Mahir on 10/16/14.
//  Copyright (c) 2014 igones. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

@protocol IAPManagerDelegate <NSObject>
- (void) iapWasCancelled;
- (void) iapFailedWithMessage:(NSString *) errorMessage;
- (void) iapFinishedForProduct:(NSString *) productIdentifier withReceipt:(NSData *) receipt;
- (void) iapInitializedWithReceipt:(NSData *) receipt;
- (void) iapRestoredForProduct:(NSString *) productIdentifier;
- (void) iapRestoreFinishedWithProductIds:(NSArray *) productIds;
- (void) iapRestoreFinishedWithError:(NSString *) errorDesc;
@end

typedef void (^RequestProductsCompletionHandler)(BOOL success, NSArray * products);

@interface IAPManager : NSObject <SKProductsRequestDelegate, SKPaymentTransactionObserver>

@property (nonatomic, weak) id<IAPManagerDelegate> delegate;
@property (nonatomic, strong) NSArray *products;
@property (nonatomic) BOOL processInProgress;
@property (nonatomic) BOOL restoreInProgress;

+ (IAPManager *) sharedInstance;
- (void) requestProducts:(NSArray *) productNames withCompletionHandler:(RequestProductsCompletionHandler) handler;
- (void) buyProduct:(SKProduct *)product;
- (void) buyProductByIdentifier:(NSString *) identifier;
- (BOOL) isProductPurchasedWithIdentifier:(NSString *) identifier;
- (void) restoreProducts;

@end
