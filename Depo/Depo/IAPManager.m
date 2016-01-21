//
//  IAPManager.m
//  Acdm_1
//
//  Created by Mahir on 10/16/14.
//  Copyright (c) 2014 igones. All rights reserved.
//

#import "IAPManager.h"
#import "AppConstants.h"
#import "Offer.h"

#define IAP_PURCHASE_USER_DEFAULTS_FLAG_WITH_IDENTIFIER @"IAP_PURCHASE_FLAG_%@"

@implementation IAPManager {
    SKProductsRequest *productsRequest;
    RequestProductsCompletionHandler completionHandler;
    NSSet *productIdentifiers;
    NSMutableSet *purchasedProductIdentifiers;
}

@synthesize delegate;
@synthesize processInProgress;
@synthesize products;

+ (IAPManager *) sharedInstance {
    static IAPManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[IAPManager alloc] init];
    });
    return sharedInstance;
}

- (id) init {
    if ((self = [super init])) {
        productIdentifiers = [NSSet setWithObjects:@"mini_1_month", @"standard_1_month", nil];
        
        purchasedProductIdentifiers = [NSMutableSet set];
        for (NSString *productIdentifier in productIdentifiers) {
            if ([self isProductPurchasedWithIdentifier:productIdentifier]) {
                NSLog(@"Already purchased: %@", productIdentifier);
                [purchasedProductIdentifiers addObject:productIdentifier];
            }
        }
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    }
    return self;
}

- (BOOL) isProductPurchasedWithIdentifier:(NSString *) identifier {
    NSString *userDefaultsKey = [NSString stringWithFormat:IAP_PURCHASE_USER_DEFAULTS_FLAG_WITH_IDENTIFIER, identifier];
    return [[NSUserDefaults standardUserDefaults] boolForKey:userDefaultsKey];
}

- (void) requestProducts:(NSArray *) productNames withCompletionHandler:(RequestProductsCompletionHandler) handler {
    
    productIdentifiers = [NSSet setWithArray:productNames];

    completionHandler = [handler copy];
    
    productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:productIdentifiers];
    productsRequest.delegate = self;
    [productsRequest start];
}

- (void) buyProduct:(SKProduct *) product {
    if(processInProgress) {
        NSLog(@"Purchase process in progress");
        return;
    }
    SKPayment *payment = [SKPayment paymentWithProduct:product];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
    processInProgress = YES;
}

- (void) buyProductByIdentifier:(NSString *) identifier {
    if(processInProgress) {
        NSLog(@"Purchase process in progress");
        return;
    }
    for(SKProduct *product in self.products) {
        if([product.productIdentifier isEqualToString:identifier]) {
            SKPayment *payment = [SKPayment paymentWithProduct:product];
            [[SKPaymentQueue defaultQueue] addPayment:payment];
            processInProgress = YES;
        }
    }
    if(!processInProgress) {
        [delegate iapFailedWithMessage:NSLocalizedString(@"IAPProductNotFound", @"")];
    }
}

#pragma mark - SKProductsRequestDelegate

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    
    NSLog(@"Loaded list of products...");
    productsRequest = nil;
    
    self.products = response.products;
    NSMutableArray *productsAsOffer = [[NSMutableArray alloc] init];
    for (SKProduct *skProduct in products) {
        NSLog(@"Found product: %@ %@ %0.2f",
              skProduct.productIdentifier,
              skProduct.localizedTitle,
              skProduct.price.floatValue);
        
        NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
        [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
        [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
        [numberFormatter setLocale:skProduct.priceLocale];
        
        Offer *offer = [[Offer alloc] init];
        offer.storeProductIdentifier = skProduct.productIdentifier;
        //TODO YEAR gelecek olan olursa burasi duzeltilecek
        offer.period = @"MONTH";
        offer.name = skProduct.localizedTitle;
        offer.rawPrice = skProduct.price.floatValue;
        offer.price = [numberFormatter stringFromNumber:skProduct.price];
        offer.offerType = OfferTypeApple;
        
        //TODO quota konacak
        
        [productsAsOffer addObject:offer];
    }

    /*
    //TODO sil
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [numberFormatter setLocale:[NSLocale currentLocale]];
    Offer *offer = [[Offer alloc] init];
    offer.storeProductIdentifier = @"mini_1_aylik";
    offer.period = @"MONTH";
    offer.name = @"Minicik Paket 1 Aylik";
    offer.rawPrice = 9.90;
    offer.price = [numberFormatter stringFromNumber:[NSNumber numberWithFloat:offer.rawPrice]];
    offer.offerType = OfferTypeApple;
    [productsAsOffer addObject:offer];
    */
    
    completionHandler(YES, productsAsOffer);
    completionHandler = nil;
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error {
    NSLog(@"Failed to load list of products.");
    productsRequest = nil;
    
    completionHandler(NO, nil);
    completionHandler = nil;
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions {
    processInProgress = NO;
    for (SKPaymentTransaction * transaction in transactions) {
        switch (transaction.transactionState) {
            case SKPaymentTransactionStatePurchased:
                [self completeTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                [self failedTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                [self restoreTransaction:transaction];
            default:
                break;
        }
    };
}

- (void)completeTransaction:(SKPaymentTransaction *)transaction {
    NSLog(@"completeTransaction...");
    /*
     [purchasedProductIdentifiers addObject:productIdentifier];
     [[NSUserDefaults standardUserDefaults] setBool:YES forKey:productIdentifier];
     [[NSUserDefaults standardUserDefaults] synchronize];
     */
    [delegate iapFinishedForProduct:transaction.payment.productIdentifier withReceipt:transaction.transactionReceipt];
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

- (void)restoreTransaction:(SKPaymentTransaction *)transaction {
    NSLog(@"restoreTransaction...");
    [delegate iapRestoredForProduct:transaction.originalTransaction.payment.productIdentifier];
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

- (void)failedTransaction:(SKPaymentTransaction *)transaction {
    if (transaction.error.code == SKErrorPaymentCancelled) {
        [delegate iapWasCancelled];
    } else {
        [delegate iapFailedWithMessage:transaction.error.localizedDescription];
    }
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}

@end
