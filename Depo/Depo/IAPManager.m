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
@synthesize restoreInProgress;
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
        /*
        productIdentifiers = [NSSet setWithObjects:@"mini_1_month", @"standard_1_month", nil];
        
        purchasedProductIdentifiers = [NSMutableSet set];
        for (NSString *productIdentifier in productIdentifiers) {
            if ([self isProductPurchasedWithIdentifier:productIdentifier]) {
                NSLog(@"Already purchased: %@", productIdentifier);
                [purchasedProductIdentifiers addObject:productIdentifier];
            }
        }
         */
        
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
    NSLog(@"PRODUCT IDs: %@", productIdentifiers);

    //TODO sil
//    productIdentifiers = [NSSet setWithObjects:@"mini_package_2_months", @"standard_package_1_month", nil];
    
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
        offer.period = [self parseDurationByIdentifier:skProduct.productIdentifier];
        offer.name = skProduct.localizedTitle;
        offer.rawPrice = skProduct.price.floatValue;
        offer.price = [numberFormatter stringFromNumber:skProduct.price];
        offer.offerType = OfferTypeApple;
        offer.description = skProduct.localizedDescription;
        
        [productsAsOffer addObject:offer];
    }

    NSArray *sortedArray = [productsAsOffer sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        NSNumber *firstPrice = [NSNumber numberWithFloat:[(Offer*) a rawPrice]];
        NSNumber *secondPrice = [NSNumber numberWithFloat:[(Offer*) b rawPrice]];
        return [firstPrice compare:secondPrice];
    }];

    completionHandler(YES, sortedArray);
    completionHandler = nil;
}

- (NSString *) parseDurationByIdentifier:(NSString *) rawId {
    if(rawId) {
        NSArray *splittedList = [rawId componentsSeparatedByString:@"_"];
        if([splittedList count] > 1) {
            NSString *lastItem = [[splittedList objectAtIndex:[splittedList count]-1] uppercaseString];
            if([lastItem isEqualToString:@"MONTH"]) {
                return @"MONTH";
            } else if([lastItem isEqualToString:@"MONTHS"]) {
                NSString *length = [splittedList objectAtIndex:[splittedList count]-2];
                return [NSString stringWithFormat:@"%@_%@", length, @"MONTHS"];
            } else if([lastItem isEqualToString:@"DAYS"]) {
                NSString *length = [splittedList objectAtIndex:[splittedList count]-2];
                return [NSString stringWithFormat:@"%@_%@", length, @"DAYS"];
            } else if([lastItem isEqualToString:@"YEAR"]){
                return @"YEAR";
            }
        }
    }
    return @"";
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error {
    NSLog(@"Failed to load list of products.");
    productsRequest = nil;

    completionHandler(NO, nil);
    completionHandler = nil;
}

- (void) restoreProducts {
    restoreInProgress = YES;
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

- (void) paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue {
    restoreInProgress = NO;

    NSMutableArray *purchasedItemIDs = [[NSMutableArray alloc] init];
    
    NSLog(@"received restored transactions: %lu", (unsigned long)queue.transactions.count);
    for (SKPaymentTransaction *transaction in queue.transactions) {
        NSString *productID = transaction.payment.productIdentifier;
        [purchasedItemIDs addObject:productID];
        [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    }
    [delegate iapRestoreFinishedWithProductIds:purchasedItemIDs];
}

- (void) paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error {
    restoreInProgress = NO;
    NSLog(@"Restore error: %@", error.localizedDescription);
    [delegate iapRestoreFinishedWithError:error.localizedDescription];
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions {
    if(!restoreInProgress) {
        if(processInProgress) {
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
            }
            processInProgress = NO;
        } else {
            for (SKPaymentTransaction * transaction in transactions) {
                switch (transaction.transactionState) {
                    case SKPaymentTransactionStatePurchased:
                        [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                        break;
                    case SKPaymentTransactionStateFailed:
                        [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                        break;
                    case SKPaymentTransactionStateRestored:
                        [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                    default:
                        break;
                }
            }
            NSURL *receiptFileURL = [[NSBundle mainBundle] appStoreReceiptURL];
            NSData *receiptData = [NSData dataWithContentsOfURL:receiptFileURL];
            
            [delegate iapInitializedWithReceipt:receiptData];
        }
    }
}

- (void)completeTransaction:(SKPaymentTransaction *)transaction {
    NSLog(@"completeTransaction...");
    
    NSURL *receiptFileURL = [[NSBundle mainBundle] appStoreReceiptURL];
    NSData *receiptData = [NSData dataWithContentsOfURL:receiptFileURL];
    
    [delegate iapFinishedForProduct:transaction.payment.productIdentifier withReceipt:receiptData];
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
