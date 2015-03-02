//
//  SettingsStorageController.m
//  Depo
//
//  Created by Salih Topcu on 23.09.2014.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "SettingsStorageController.h"
#import "OfferCell.h"

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
    [self loadPageContent];
}

- (void) loadPageContent {
    [super showLoading];
    tableUpdateCounter++;
    
    accountDaoToGetCurrentSubscription = [[AccountDao alloc]init];
    accountDaoToGetCurrentSubscription.delegate = self;
    accountDaoToGetCurrentSubscription.successMethod = @selector(loadCurrentSubscriptionCallback:);
    accountDaoToGetCurrentSubscription.failMethod = @selector(loadCurrentSubscriptionFailCallback:);
    [accountDaoToGetCurrentSubscription requestCurrentAccount];
    
    accountDaoToGetOffers = [[AccountDao alloc]init];
    accountDaoToGetOffers.delegate = self;
    accountDaoToGetOffers.successMethod = @selector(loadOffersCallback:);
    accountDaoToGetOffers.failMethod = @selector(loadOffersFailCallback:);
    [accountDaoToGetOffers requestOffers];
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

- (void) loadOffersCallback:(NSArray *) files {
    offers = [[NSMutableArray alloc] initWithArray:files];
    if (offers.count > 0 && currentSubscription != nil) {
        [super drawPageContentTable];
        [super hideLoading];
    }
}

- (void) loadOffersFailCallback:(NSString *) errorMessage {
    [super hideLoading];
    [super showErrorAlertWithMessage:errorMessage];
}

- (void) activateOfferCallback {
    [self loadPageContent];
    [pageContentTable reloadData];
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
        if ([currentSubscription.plan.role isEqualToString:@"demo"]) {
            return 1;
        } else {
            return 2;
        }
    }
    else
        return offers.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 54;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        if (indexPath.row == 0)
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
            NSString *title = [NSString stringWithFormat:NSLocalizedString(@"SubscriptionInfo", @""), currentSubscription.plan.displayName, currentSubscription.plan.quota/(1024*1024*1024), currentSubscription.plan.price];
            
            TitleCell *cell = [[TitleCell alloc] initWithCellStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier titleText:title titleColor:nil subTitleText:@"" iconName:@"" hasSeparator:YES isLink:NO linkText:@"" cellHeight:69];
            return cell;
        }
        else {
            NSString *nameForSms = @"";
            if ([currentSubscription.plan.role isEqualToString:@"standart"]) {
                nameForSms = @"MINIDEPO";
            } else if ([currentSubscription.plan.role isEqualToString:@"premium"]) {
                nameForSms = @"STANDARTDEPO";
            } else if ([currentSubscription.plan.role isEqualToString:@"ultimate"]) {
                nameForSms = @"MEGADEPO";
            }
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
        NSString *packageName = @"%@ (%gGB) %@ TL/%@";
        packageName = [NSString stringWithFormat:packageName, offer.name, offer.quota/(1024*1024*1024), offer.price, NSLocalizedString(@"Month", @"")];
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
        [super showLoading];
        Offer *offer = [offers objectAtIndex:indexPath.row];
        accountDaoToActivateOffer = [[AccountDao alloc]init];
        accountDaoToGetOffers.delegate = self;
        accountDaoToGetOffers.successMethod = @selector(activateOfferCallback);
        accountDaoToGetOffers.failMethod = @selector(activateOfferFailCallback:);
        [accountDaoToGetOffers requestActivateOffer:offer];
    }
}

@end
