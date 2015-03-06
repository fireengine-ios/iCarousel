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

@interface SettingsStorageController ()

@end

@implementation SettingsStorageController

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
    
    if (currentSubscription == nil && accountDaoToLearnIsJobExists == nil) {
        accountDaoToLearnIsJobExists = [[AccountDao alloc]init];
        accountDaoToLearnIsJobExists.delegate = self;
        accountDaoToLearnIsJobExists.successMethod = @selector(isJobExistsCallback:);
        accountDaoToLearnIsJobExists.failMethod = @selector(isJobExistsFailCallback:);
        [accountDaoToLearnIsJobExists requestIsJobExists];
    }
    
    if (!isJobExists) {
        accountDaoToGetOffers = [[AccountDao alloc]init];
        accountDaoToGetOffers.delegate = self;
        accountDaoToGetOffers.successMethod = @selector(loadOffersCallback:);
        accountDaoToGetOffers.failMethod = @selector(loadOffersFailCallback:);
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
    offers = [[NSMutableArray alloc] initWithArray:files];
    if (offers.count > 0) {
        [super drawPageContentTable];
        [super hideLoading];
    }
}

- (void) loadOffersFailCallback:(NSString *) errorMessage {
    [super hideLoading];
    [super showErrorAlertWithMessage:errorMessage];
}

- (void) activateOfferCallback {
    currentSubscription = nil;
    isJobExists = YES;
    [offers removeAllObjects];
    [self loadPageContent];
    [pageContentTable reloadData];
    [self.navigationController popViewControllerAnimated:YES];
    [super showInfoAlertWithMessage:NSLocalizedString(@"ActivateOfferSuccess", @"")];
}

- (void) activateOfferFailCallback:(NSString *) errorMessage {
    [super hideLoading];
    [super showErrorAlertWithMessage:errorMessage];
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
        } else if ([currentSubscription.plan.role isEqualToString:@"demo"]) {
            return 1;
        } else {
            return 2;
        }
    }
    else
        return offers.count;
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
            return 69;
        else
            return 54;
    }
    else {
        if (indexPath.row == 0 || indexPath.row == offers.count - 1)
            return 75;
        else
            return 60;
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
            NSString *subscriptionDisplayName = [self getPackageDisplayName:currentSubscription.plan.role];
            NSString *title = [NSString stringWithFormat:NSLocalizedString(@"SubscriptionInfo", @""), subscriptionDisplayName, currentSubscription.plan.quota/(1024*1024*1024), currentSubscription.plan.price];
            
            TitleCell *cell = [[TitleCell alloc] initWithCellStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier titleText:title titleColor:nil subTitleText:@"" iconName:@"" hasSeparator:YES isLink:NO linkText:@"" cellHeight:69];
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
        OfferCell *cell;
        Offer *offer = [offers objectAtIndex:indexPath.row];
        NSString *offerDisplayName = [self getPackageDisplayName:offer.role];
        NSString *packageName = @"%@ (%gGB) %@ TL/%@";
        packageName = [NSString stringWithFormat:packageName, offerDisplayName, offer.quota/(1024*1024*1024), offer.price, NSLocalizedString(@"Month", @"")];
        packageName = [packageName stringByReplacingOccurrencesOfString:@"Akıllı Depo " withString:@""];
        if (indexPath.row == 0)
            cell = [[OfferCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier titleText:packageName hasSeparator:NO topIndex:15 bottomIndex:0];
        else if (indexPath.row == offers.count - 1)
            cell = [[OfferCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier titleText:packageName hasSeparator:YES topIndex:0 bottomIndex:15];
        else
            cell = [[OfferCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier titleText:packageName hasSeparator:NO];
        return cell;
    }
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        selectedOffer = [offers objectAtIndex:indexPath.row];
        CustomConfirmView *confirm = [[CustomConfirmView alloc] initWithFrame:CGRectMake(0, 0, APPDELEGATE.window.frame.size.width, APPDELEGATE.window.frame.size.height) withTitle:NSLocalizedString(@"Approve", @"") withCancelTitle:NSLocalizedString(@"TitleNo", @"") withApproveTitle:NSLocalizedString(@"TitleYes", @"") withMessage:NSLocalizedString(@"ActivateOfferApprove", @"") withModalType:ModalTypeApprove];
        confirm.delegate = self;
        [APPDELEGATE showCustomConfirm:confirm];
    }
}

- (void) didApproveCustomAlert:(CustomConfirmView *)alertView {
    [alertView removeFromSuperview];
    [self activateOffer:selectedOffer];
}

- (void) didRejectCustomAlert:(CustomConfirmView *)alertView {
    [alertView removeFromSuperview];
}

- (void) activateOffer:(Offer *)offer {
    [super showLoading];
    accountDaoToActivateOffer = [[AccountDao alloc]init];
    accountDaoToGetOffers.delegate = self;
    accountDaoToGetOffers.successMethod = @selector(activateOfferCallback);
    accountDaoToGetOffers.failMethod = @selector(activateOfferFailCallback:);
    [accountDaoToGetOffers requestActivateOffer:offer];
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

@end
