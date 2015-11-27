//
//  SettingsStorageController.m
//  Depo
//
//  Created by Salih Topcu on 23.09.2014.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "SettingsStorageController.h"
#import "OfferCell.h"
#import "CustomConfirmView.h"
#import "AppDelegate.h"
#import "BaseViewController.h"
#import "OfferContainer.h"
#import "AppUtil.h"

@interface SettingsStorageController ()

@end

@implementation SettingsStorageController

@synthesize purchaseView;
@synthesize offerToSubs;
@synthesize containerOffers;

- (id)init
{
    self = [super init];
    if (self) {
        self.title = NSLocalizedString(@"Memory", @"");
    }
    return self;
}

- (void) viewWillAppear:(BOOL)animated {
    isJobExists = YES;
    [self loadPageContent];
}

- (void) loadPageContent {
    [super showLoading];
    tableUpdateCounter++;
    
    if (accountDaoToGetCurrentSubscription == nil) {
        accountDaoToGetCurrentSubscription = [[AccountDao alloc]init];
        accountDaoToGetCurrentSubscription.delegate = self;
        accountDaoToGetCurrentSubscription.successMethod = @selector(loadCurrentSubscriptionCallback:);
        accountDaoToGetCurrentSubscription.failMethod = @selector(loadCurrentSubscriptionFailCallback:);
        [accountDaoToGetCurrentSubscription requestCurrentAccount];
    }
    
    if (currentSubscription == nil) {
        if(accountDaoToLearnIsJobExists == nil) {
            accountDaoToLearnIsJobExists = [[AccountDao alloc]init];
            accountDaoToLearnIsJobExists.delegate = self;
            accountDaoToLearnIsJobExists.successMethod = @selector(isJobExistsCallback:);
            accountDaoToLearnIsJobExists.failMethod = @selector(isJobExistsFailCallback:);
        }
        [accountDaoToLearnIsJobExists requestIsJobExists];
    }
    
    if (!isJobExists) {
        if(accountDaoToGetOffers == nil) {
            accountDaoToGetOffers = [[AccountDao alloc]init];
            accountDaoToGetOffers.delegate = self;
            accountDaoToGetOffers.successMethod = @selector(loadOffersCallback:);
            accountDaoToGetOffers.failMethod = @selector(loadOffersFailCallback:);
        }
        [accountDaoToGetOffers requestOffers];
    }
}

- (void) loadCurrentSubscriptionCallback:(Subscription *) file {
    currentSubscription = file;
    [super drawPageContentTable];
    [super hideLoading];
}

- (void) loadCurrentSubscriptionFailCallback:(NSString *) errorMessage {
    [super hideLoading];
    [super showErrorAlertWithMessage:errorMessage];
}

- (void) isJobExistsCallback:(NSNumber *) result {
    int resultInt = [result intValue];
    if (resultInt == 1) {
        isJobExists = YES;
    } else {
        isJobExists = NO;
        [self loadPageContent];
    }
    [super hideLoading];
}

- (void) isJobExistsFailCallback:(NSString *) errorMessage {
    [super hideLoading];
    [super showErrorAlertWithMessage:errorMessage];
}

- (void) loadOffersCallback:(NSArray *) files {
    //offer listesi başarıyla alınınca bu metoda düşer
    offers = [[NSMutableArray alloc] initWithArray:files];
    if ([currentSubscription.plan.role isEqualToString:@"demo"]) {
        NSArray *temp = [self sortArray:offers withKey:@"quota" withAscending:YES];
        containerOffers = [self sortingOfferContainers:temp];
    }
    else {
        NSArray *temp = [self sortArray:offers withKey:@"quota" withAscending:NO];
        containerOffers = [self sortingOfferContainers:temp];
    }
    
    if (offers.count > 0) {
        [super drawPageContentTable];
        [super hideLoading];
    }
}

- (void) loadOffersFailCallback:(NSString *) errorMessage {
    //offer listesi hata alırsa bu metoda düşer
    [super hideLoading];
    [super showErrorAlertWithMessage:errorMessage];
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

- (void) failedPurchaseTryAgainDelegate {
    [self activateOffer:selectedOffer];
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    if (offers.count > 0)
        return 2;
    else
        return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        if (currentSubscription.plan == nil) {
            return 0;
        }
        else{
            return 1;
        }
    } else {
        if([offers count] > 0) {
            return containerOffers.count;
        } else {
            return 0;
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0 && currentSubscription.plan == nil)
        return 0;
    return 54;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        if (currentSubscription.plan == nil)
            return 0;
        else if (indexPath.row == 0)
            return 80;
        else
            return 120;
    }
    else {
        if (indexPath.row == 0 || indexPath.row == offers.count - 1)
            return 90;
        else
            return 90;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSString *titleText;
    switch (section) {
        case 0: titleText = NSLocalizedString(@"CurrentPackageTitle", @""); break;
        case 1: titleText = NSLocalizedString(@"UpgradeOptionsTitle", @""); break;
        default: titleText = @""; break;
    }
    return [[HeaderCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"" headerText:titleText];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = [NSString stringWithFormat:@"MenuCell-%d-%d-%d", tableUpdateCounter, (int)indexPath.section, (int)indexPath.row];
    
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            //NSString *subscriptionDisplayName = [self getPackageDisplayName:currentSubscription.plan.role];
            //NSString *title = [NSString stringWithFormat:NSLocalizedString(@"SubscriptionInfo", @""), subscriptionDisplayName, currentSubscription.plan.quota/(1024*1024*1024), currentSubscription.plan.price];
            
            //TitleCell *cell = [[TitleCell alloc] initWithCellStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier titleText:title titleColor:nil subTitleText:@"" iconName:@"" hasSeparator:YES isLink:NO linkText:@"" cellHeight:69];
            
            OfferRedesignCell *cell = [[OfferRedesignCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier withCurrenSubscription:currentSubscription];
            return cell;
            
            
        }
        else {
            NSString *nameForSms = [self getNameForSms:currentSubscription.plan.role];
            NSString *contentText = @"";
            if (![nameForSms isEqualToString:@""]) {
                contentText = [NSString stringWithFormat:NSLocalizedString(@"CancelSubscriptionInfo", @""), nameForSms];
            }
            TextCell *cell = [[TextCell alloc]initWithCellStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier titleText:@"" titleColor:nil contentText:contentText contentTextColor:nil backgroundColor:nil hasSeparator:NO];
            
            
            return cell;
        }
    }
    else {
        OfferRedesignCell *cell = [[OfferRedesignCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier withOffer:[containerOffers objectAtIndex:indexPath.row] withCurrentSubscription:currentSubscription];
        cell.offerCellDel = self;
        return cell;
    }
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    /*if (indexPath.section == 1) {
     selectedOffer = [offers objectAtIndex:indexPath.row];
     CustomConfirmView *confirm = [[CustomConfirmView alloc] initWithFrame:CGRectMake(0, 0, APPDELEGATE.window.frame.size.width, APPDELEGATE.window.frame.size.height) withTitle:NSLocalizedString(@"Approve", @"") withCancelTitle:NSLocalizedString(@"TitleNo", @"") withApproveTitle:NSLocalizedString(@"TitleYes", @"") withMessage:NSLocalizedString(@"ActivateOfferApprove", @"") withModalType:ModalTypeApprove];
     confirm.delegate = self;
     [APPDELEGATE showCustomConfirm:confirm];
     }
     */
}

- (void) didApproveCustomAlert:(CustomConfirmView *)alertView {
    [self activateOffer:selectedOffer];
}

- (void) didRejectCustomAlert:(CustomConfirmView *)alertView {
    //    [alertView removeFromSuperview];
}

- (void) activateOffer:(Offer *)offer {
    [super showLoading];
    accountDaoToActivateOffer = [[AccountDao alloc]init];
    accountDaoToActivateOffer.delegate = self;
    accountDaoToActivateOffer.successMethod = @selector(activateOfferCallback);
    accountDaoToActivateOffer.failMethod = @selector(activateOfferFailCallback:);
    [accountDaoToActivateOffer requestActivateOffer:offer];
}

- (NSString *)getPackageDisplayName: (NSString *)roleName {
    NSString *name = @"";
    if ([roleName isEqualToString:@"demo"]) {
        name = NSLocalizedString(@"Welcome", @"");
    } else if ([roleName isEqualToString:@"standard"]) {
        name = @"Mini Paket";
    } else if ([roleName isEqualToString:@"premium"]) {
        name = @"Standart Paket";
    } else if ([roleName isEqualToString:@"ultimate"]) {
        name = @"Mega Paket";
    }
    return name;
}

- (NSString *)getNameForSms: (NSString *)roleName {
    NSString *name = @"";
    if ([currentSubscription.plan.role isEqualToString:@"standart"]) {
        name = @"MINIDEPO";
    } else if ([currentSubscription.plan.role isEqualToString:@"premium"]) {
        name = @"STANDARTDEPO";
    } else if ([currentSubscription.plan.role isEqualToString:@"ultimate"]) {
        name = @"MEGADEPO";
    }
    return name;
}

- (void) selectedOfferPurchase:(Offer *)offer {
    purchaseView = [[PurchaseView alloc] initWithFrame:CGRectMake(0,0,self.view.frame.size.width,self.view.frame.size.height) withOffer:offer];
    purchaseView.delegate = self;
    [purchaseView drawBeforePurchaseView];
    [self.view addSubview:purchaseView];
}

- (void) shouldCloseView {
    if(purchaseView) {
        [purchaseView removeFromSuperview];
        purchaseView = nil;
    }
}


- (void) activatePurchasing:(Offer *) chosenOffer {
    selectedOffer = chosenOffer;
    [self activateOffer:selectedOffer];
}

- (NSArray *) sortingOfferContainers:(NSArray *) offerPackages {
    
    if([offers count] == 0)
        return [[NSArray alloc] init];
    
    OfferContainer *firstContainer = [[OfferContainer alloc] init];
    Offer *tmp = [[Offer alloc] init];
    tmp = [offerPackages objectAtIndex:0];
    NSMutableArray *containerArray = [[NSMutableArray alloc] init];
    if ([tmp.period isEqualToString:@"MONTH"]) {
        firstContainer.montlyOffer = tmp;
        firstContainer.quota = tmp.quota;
        [containerArray addObject:firstContainer];
    }
    else {
        firstContainer.yearlyOffer = tmp;
        firstContainer.quota = tmp.quota;
        [containerArray addObject:firstContainer];
    }
    for (int j = 0; j <[offerPackages count]; j++) {
        Offer *comparableOffer = [offerPackages objectAtIndex:j];
        if (comparableOffer.quota == firstContainer.quota) {
            if ([comparableOffer.period isEqualToString:@"MONTH"]) {
                firstContainer.montlyOffer = comparableOffer;
                
            }
            else if([comparableOffer.period isEqualToString:@"YEAR"]){
                firstContainer.yearlyOffer = comparableOffer;
            }
        }
        else {
            firstContainer = [[OfferContainer alloc] init];
            firstContainer.quota = comparableOffer.quota;
            if ([comparableOffer.period isEqualToString:@"MONTH"]) {
                firstContainer.montlyOffer = comparableOffer;
                [containerArray addObject:firstContainer];
                
            }
            else {
                firstContainer.yearlyOffer = comparableOffer;
                [containerArray addObject:firstContainer];
            }
            
        }
    }
    
    return containerArray;
    
}

- (void) failedActivationTryAgain {
    [self activateOffer:selectedOffer];
}

- (void) purchasingDone {
    [self shouldCloseView];
    currentSubscription = nil;
    isJobExists = YES;
    [offers removeAllObjects];
//    [self loadPageContent];
//    [pageContentTable reloadData];
    [APPDELEGATE triggerHome];
}

- (NSArray *) sortArray:(NSArray *) array withKey:(NSString *) key withAscending:(BOOL) ascending {
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:key ascending:ascending];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    NSArray * sortedArray = [array sortedArrayUsingDescriptors:sortDescriptors];
    
    for (int i = 0; i< [offers count]; i++) {
        Offer *tmp = [[Offer alloc] init];
        tmp = [sortedArray objectAtIndex:i];
        NSLog(@"%f",tmp.quota);
    }
    
    return sortedArray;
    
}

@end
