//
//  RevisitedStorageController.m
//  Depo
//
//  Created by Mahir on 13/01/16.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import "RevisitedStorageController.h"
#import "CustomConfirmView.h"
#import "AppDelegate.h"
#import "BaseViewController.h"
#import "AppUtil.h"
#import "AppSession.h"
#import "AppConstants.h"

@interface RevisitedStorageController ()

@end

@implementation RevisitedStorageController

@synthesize mainTable;
@synthesize purchaseView;

- (id)init {
    if(self = [super init]) {
        self.title = NSLocalizedString(@"Packages", @"");
        self.view.backgroundColor = [Util UIColorForHexColor:@"F1F2F6"];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    tableUpdateCounter = 0;
    
    accountDaoToGetCurrentSubscription = [[AccountDao alloc]init];
    accountDaoToGetCurrentSubscription.delegate = self;
    accountDaoToGetCurrentSubscription.successMethod = @selector(loadCurrentSubscriptionCallback:);
    accountDaoToGetCurrentSubscription.failMethod = @selector(loadCurrentSubscriptionFailCallback:);

    accountDaoToLearnIsJobExists = [[AccountDao alloc]init];
    accountDaoToLearnIsJobExists.delegate = self;
    accountDaoToLearnIsJobExists.successMethod = @selector(isJobExistsCallback:);
    accountDaoToLearnIsJobExists.failMethod = @selector(isJobExistsFailCallback:);
    
    accountDaoToGetOffers = [[AccountDao alloc]init];
    accountDaoToGetOffers.delegate = self;
    accountDaoToGetOffers.successMethod = @selector(loadOffersCallback:);
    accountDaoToGetOffers.failMethod = @selector(loadOffersFailCallback:);

    appleProductsDao = [[AppleProductsListDao alloc] init];
    appleProductsDao.delegate = self;
    appleProductsDao.successMethod = @selector(appleProductsSuccessCallback:);
    appleProductsDao.failMethod = @selector(appleProductsFailCallback:);
    
    iapValidateDao = [[IAPValidateDao alloc] init];
    iapValidateDao.delegate = self;
    iapValidateDao.successMethod = @selector(iapValidateSuccessCallback:);
    iapValidateDao.failMethod = @selector(iapValidateFailCallback:);

    iapInitialValidateDao = [[IAPValidateDao alloc] init];
    iapInitialValidateDao.delegate = self;
    iapInitialValidateDao.successMethod = @selector(iapInitialValidateSuccessCallback:);
    iapInitialValidateDao.failMethod = @selector(iapInitialValidateFailCallback:);
    
    accountDaoToActivateOffer = [[AccountDao alloc]init];
    accountDaoToActivateOffer.delegate = self;
    accountDaoToActivateOffer.successMethod = @selector(activateOfferCallback);
    accountDaoToActivateOffer.failMethod = @selector(activateOfferFailCallback:);

    [IAPManager sharedInstance].delegate = self;

    mainTable = [[UITableView alloc] initWithFrame:CGRectMake(0, self.topIndex, 320, self.view.frame.size.height - self.topIndex - 64) style:UITableViewStylePlain];
    mainTable.delegate = self;
    mainTable.dataSource = self;
    mainTable.backgroundColor = [UIColor clearColor];
    mainTable.backgroundView = nil;
    mainTable.bounces = NO;
    [mainTable setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.view addSubview:mainTable];

    //added to prevent sticky section headers
    CGFloat dummyViewHeight = 40;
    UIView *dummyView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, mainTable.bounds.size.width, dummyViewHeight)];
    mainTable.tableHeaderView = dummyView;
    mainTable.contentInset = UIEdgeInsetsMake(-dummyViewHeight, 0, 0, 0);
    
    if(APPDELEGATE.session.user.accountType == AccountTypeOther) {
        CustomButton *restoreButton = [[CustomButton alloc] initWithFrame:CGRectMake(0, 0, 18, 18) withImageName:@"icon_verif_refresh.png"];
        [restoreButton addTarget:self action:@selector(restoreClicked) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:restoreButton];
    }

    [self refreshPageData];
    [self readAndSendReceipt];
}

- (void) refreshPageData {
    [accountDaoToGetCurrentSubscription requestActiveSubscriptions];
    dispatch_async(dispatch_get_main_queue(), ^{
        [super showLoading];
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark CustomConfirmDelegate methods

- (void) didRejectCustomAlert:(CustomConfirmView *) alertView {
}

- (void) didApproveCustomAlert:(CustomConfirmView *) alertView {
    [self activateOffer:selectedOffer];
}

#pragma mark PurchaseViewDelegate methods

- (void) shouldCloseView {
    if(purchaseView) {
        [purchaseView removeFromSuperview];
        purchaseView = nil;
    }
}

- (void) activatePurchasing:(Offer *) chosenOffer {
    selectedOffer = chosenOffer;
    if(selectedOffer.offerType == OfferTypeTurkcell) {
        [self activateOffer:selectedOffer];
    } else {
        [[IAPManager sharedInstance] buyProductByIdentifier:chosenOffer.storeProductIdentifier];
    }
}

- (void) failedPurchaseTryAgainDelegate {
    [self activateOffer:selectedOffer];
}

- (void) purchasingDone {
    if(purchaseView) {
        [purchaseView removeFromSuperview];
        purchaseView = nil;
    }
    currentSubscriptions = nil;
    [offers removeAllObjects];
    isJobExists = YES;

    [APPDELEGATE triggerHome];
}

#pragma mark IAPManagerDelegate methods

- (void) iapWasCancelled {
    [self hideLoading];
    if(purchaseView) {
        [purchaseView removeFromSuperview];
    }
}

- (void) iapFailedWithMessage:(NSString *) errorMessage {
    [super hideLoading];
    if(purchaseView) {
        [purchaseView drawFailedPurchaseView:errorMessage];
    }
}

- (void) iapFinishedForProduct:(NSString *) productIdentifier withReceipt:(NSData *) receipt {
    [iapValidateDao requestIAPValidationForProductId:productIdentifier withReceiptId:[receipt base64EncodedStringWithOptions:0]];
    [self showLoading];
}

- (void) iapRestoredForProduct:(NSString *) productIdentifier {
    [super hideLoading];
    /*
    //TODO restore için şu anda hata gösteriliyor. Fakat success gösterip tekrar validasyona mı girmeli?
    if(purchaseView) {
        [purchaseView drawFailedPurchaseView:NSLocalizedString(@"IAPRestoreError", @"")];
    }
    [self refreshPageData];
     */
}

- (void) iapRestoreFinishedWithProductIds:(NSArray *)productIds {
    NSLog(@"At iapRestoreFinishedWithProductIds: %@", productIds);
    if(offers) {
        NSMutableArray *filteredArray = [[NSMutableArray alloc] init];
        for(Offer *offer in offers) {
            if(![productIds containsObject:offer.storeProductIdentifier]) {
                [filteredArray addObject:offer];
            }
        }
        offers = filteredArray;
        [self refreshTable];
    }
    [self hideLoading];
}

- (void) iapRestoreFinishedWithError:(NSString *)errorDesc {
    NSLog(@"At iapRestoreFinishedWithError: %@", errorDesc);
    [self showErrorAlertWithMessage:errorDesc];
    [self hideLoading];
}

- (void) iapInitializedWithReceipt:(NSData *)receipt {
//    [iapInitialValidateDao requestIAPValidationWithReceiptId:[receipt base64EncodedStringWithOptions:0]];
}

#pragma mark UITableView methods

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    if (offers.count > 0) {
        return 2;
    } else {
        return 1;
    }
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        if(currentSubscriptions == nil) {
            return 0;
        } else {
            return [currentSubscriptions count];
        }
    } else {
        if(offers == nil) {
            return 0;
        } else {
            return [offers count];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0){
        if(currentSubscriptions == nil) {
            return 0;
        } else {
            return 40;
        }
    } else {
        if(offers == nil) {
            return 0;
        } else {
            return 50;
        }
    }
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return 135;
    } else {
        return 75;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 40)];
    if(section == 0) {
        headerView.backgroundColor = [UIColor clearColor];
        
        CustomLabel *titleLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(0, 12, headerView.frame.size.width, 16) withFont:[UIFont fontWithName:@"TurkcellSaturaMed" size:12] withColor:[Util UIColorForHexColor:@"292F3E"] withText:NSLocalizedString(@"CurrentPackageTitle", @"") withAlignment:NSTextAlignmentCenter];
        [headerView addSubview:titleLabel];
    } else {
        headerView.backgroundColor = [UIColor whiteColor];

        CustomLabel *titleLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(0, 12, headerView.frame.size.width, 16) withFont:[UIFont fontWithName:@"TurkcellSaturaMed" size:12] withColor:[Util UIColorForHexColor:@"292F3E"] withText:NSLocalizedString(@"UpgradeOptionsTitle", @"") withAlignment:NSTextAlignmentCenter];
        [headerView addSubview:titleLabel];
        
        UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(0, 40, headerView.frame.size.width, 1)];
        separator.backgroundColor = [Util UIColorForHexColor:@"DADADA"];
        separator.alpha = 0.6f;
        [headerView addSubview:separator];
    }
    return headerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = [NSString stringWithFormat:@"MenuCell-%d-%d-%d", tableUpdateCounter, (int)indexPath.section, (int)indexPath.row];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(cell == nil) {
        if (indexPath.section == 0) {
            Subscription *subscription = [currentSubscriptions objectAtIndex:indexPath.row];
            cell = [[RevisitedCurrentSubscriptionCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier withSubscription:subscription];
            ((RevisitedCurrentSubscriptionCell *) cell).delegate = self;
        } else {
            Offer *offer = [offers objectAtIndex:indexPath.row];
            cell = [[RevisitedOfferCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier withOffer:offer];
            ((RevisitedOfferCell *) cell).delegate = self;
        }
    }
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
}

- (void) appleProductsSuccessCallback:(NSArray *) productNames {
    appleProductNames = productNames;
    
    [[IAPManager sharedInstance] requestProducts:appleProductNames withCompletionHandler:^(BOOL success, NSArray *products) {
        if(success) {
            offers = [[NSMutableArray alloc] initWithArray:products];
        } else {
            [self showErrorAlertWithMessage:NSLocalizedString(@"IAPProductReadError", @"")];
        }
        [self hideLoading];
        [self refreshTable];
    }];
}

- (void) appleProductsFailCallback:(NSString *) errorMessage {
    [self hideLoading];
    [self showErrorAlertWithMessage:NSLocalizedString(@"IAPProductReadError", @"")];
    [self refreshTable];
}

- (void) loadCurrentSubscriptionCallback:(NSArray *) subscriptions {
    currentSubscriptions = subscriptions;
    [self refreshTable];

    [accountDaoToLearnIsJobExists requestIsJobExists];
}

- (void) loadCurrentSubscriptionFailCallback:(NSString *) errorMessage {
    [self hideLoading];
    [self showErrorAlertWithMessage:errorMessage];
}

- (void) isJobExistsCallback:(NSNumber *) result {
    int resultInt = [result intValue];
    if (resultInt == 1) {
        isJobExists = YES;
        [super hideLoading];
    } else {
        isJobExists = NO;

        if(APPDELEGATE.session.user.accountType == AccountTypeTurkcell) {
            [accountDaoToGetOffers requestOffers];
        } else {
            [appleProductsDao requestAppleProductNames];
        }
    }
}

- (void) isJobExistsFailCallback:(NSString *) errorMessage {
    [self hideLoading];
    [self showErrorAlertWithMessage:errorMessage];
}

- (void) loadOffersCallback:(NSArray *) files {
    offers = [[NSMutableArray alloc] initWithArray:files];
    [self hideLoading];
    [self refreshTable];
}

- (void) loadOffersFailCallback:(NSString *) errorMessage {
    [self hideLoading];
    [self showErrorAlertWithMessage:errorMessage];
}

- (void) iapValidateSuccessCallback:(NSString *) resultingStatus {
    [self hideLoading];
    if([resultingStatus isEqualToString:@"SUCCESS"]) {
        if(purchaseView) {
            [purchaseView drawSuccessPurchaseView];
        }
        [self refreshPageData];
    } else {
        if(purchaseView) {
            [purchaseView drawFailedPurchaseView:NSLocalizedString(resultingStatus, @"")];
        }
    }
}

- (void) iapValidateFailCallback:(NSString *) errorMessage {
    if(purchaseView) {
        [purchaseView drawFailedPurchaseView:errorMessage];
    }
    [self hideLoading];
}

- (void) iapInitialValidateSuccessCallback:(NSString *) resultingStatus {
    if(refreshActive) {
        [self hideLoading];
        refreshActive = NO;
    }
    if([resultingStatus isEqualToString:@"RESTORED"]) {
        if(purchaseView) {
            [purchaseView removeFromSuperview];
        }
        [self refreshPageData];
    }
}

- (void) iapInitialValidateFailCallback:(NSString *) errorMessage {
    if(refreshActive) {
        [self hideLoading];
        refreshActive = NO;
    }
}

- (void) refreshTable {
    tableUpdateCounter ++;
    [self.mainTable reloadData];
}

- (void) activateOfferCallback {
    [super hideLoading];
    
    //[super showInfoAlertWithMessage:NSLocalizedString(@"ActivateOfferSuccess", @"")];
    if(purchaseView) {
        [purchaseView drawSuccessPurchaseView];
    }
}

- (void) activateOfferFailCallback:(NSString *) errorMessage {
    [super hideLoading];
    //[super showErrorAlertWithMessage:errorMessage];
    if(purchaseView) {
        [purchaseView drawFailedPurchaseView:errorMessage];
    }
}

- (void) activateOffer:(Offer *) offerToActivate {
    [accountDaoToActivateOffer requestActivateOffer:offerToActivate];
    [super showLoading];
}

- (void) restoreClicked {
    refreshActive = YES;
    [self readAndSendReceipt];
    [self showLoading];
}

- (void) readAndSendReceipt {
    NSURL *receiptFileURL = [[NSBundle mainBundle] appStoreReceiptURL];
    NSData *receiptData = [NSData dataWithContentsOfURL:receiptFileURL];
    
    [iapInitialValidateDao requestIAPValidationWithReceiptId:[receiptData base64EncodedStringWithOptions:0]];
}

#pragma mark RevisitedCurrentSubscriptionCellDelegate methods

- (void) revisitedCurrentSubscriptionCellDidSelectCancelForSubscription:(Subscription *)sRef {
    NSString *contentText = @"";
    if([sRef.type isEqualToString:@"INAPP_PURCHASE_APPLE"]) {
        contentText = NSLocalizedString(@"CancelSubscriptionInfoApple", @"");
    } else if([sRef.type isEqualToString:@"INAPP_PURCHASE_GOOGLE"]) {
        contentText = NSLocalizedString(@"CancelSubscriptionInfoGoogle", @"");
    } else {
        NSString *nameForSms = [AppUtil getPackageNameForSms:sRef.plan.role];
        if (![nameForSms isEqualToString:@""]) {
            contentText = [NSString stringWithFormat:NSLocalizedString(@"CancelSubscriptionInfo", @""), nameForSms];
        }
    }
    [self showInfoAlertWithMessage:contentText];
}

#pragma mark  RevisitedOfferCellDelegate methods

- (void) revisitedOfferCellDelegateDidClickBuy:(Offer *)offerRef {
    purchaseView = [[PurchaseView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width,self.view.frame.size.height) withOffer:offerRef];
    purchaseView.delegate = self;
    [purchaseView drawBeforePurchaseView];
    [self.view addSubview:purchaseView];
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationPortrait | UIInterfaceOrientationPortraitUpsideDown;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown);
}

@end
