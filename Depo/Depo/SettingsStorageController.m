//
//  SettingsStorageController.m
//  Depo
//
//  Created by Salih Topcu on 23.09.2014.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "SettingsStorageController.h"

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
    [super showLoading];
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

- (void) cancelSubscriptionCallback {
    [super hideLoading];
}

- (void) cancelSubscriptionFailCallback:(NSString *) errorMessage {
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
    if (section == 0)
        return 2;
    else
        return offers.count + 2;
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
        if (indexPath.row == 0 || indexPath.row == offers.count + 1)
            return 15;
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
    NSString *cellIdentifier = [NSString stringWithFormat:@"MenuCell%d-%d", (int)indexPath.section, (int)indexPath.row];
    
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            NSString *descriptionText = currentSubscription.plan.accountDescription;
            descriptionText = [descriptionText stringByReplacingOccurrencesOfString:@"${NAME}" withString:currentSubscription.plan.name];
            descriptionText = [descriptionText stringByReplacingOccurrencesOfString:@"${QUOTA}B" withString:@"${QUOTA}"];
            descriptionText = [descriptionText stringByReplacingOccurrencesOfString:@"${QUOTA}" withString:[NSString stringWithFormat:@"%gGB", currentSubscription.plan.quota/(1024*1024*1024)]];
            descriptionText = [descriptionText stringByReplacingOccurrencesOfString:@"${PRICE}" withString:[NSString stringWithFormat:@"%g", currentSubscription.plan.price]];
            descriptionText = [descriptionText stringByReplacingOccurrencesOfString:@"${CURRENCY}" withString:@"TL"];
            TitleCell *cell = [[TitleCell alloc] initWithCellStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier titleText:currentSubscription.plan.displayName titleColor:nil subTitleText:descriptionText iconName:@"" hasSeparator:YES isLink:NO linkText:@"" cellHeight:69];
            return cell;
        }
        else {
            TextCell *cell = [[TextCell alloc]initWithCellStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier titleText:@"" titleColor:nil contentText:[NSString stringWithFormat:NSLocalizedString(@"CancelSubscriptionInfo", @""), currentSubscription.plan.name] contentTextColor:nil backgroundColor:nil hasSeparator:NO];
            return cell;
            
//            TitleCell *cell = [[TitleCell alloc] initWithCellStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier titleText:NSLocalizedString(@"CancelSubscription", @"") titleColor:[Util UIColorForHexColor:@"3FB0E8"] subTitleText:@"" iconName:@"" hasSeparator:YES isLink:NO linkText:@"" cellHeight:54];
            return cell;
        }
    }
    else {
        UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        //[self drawUpgradeOptionsCell:cell];
        return cell;
    }
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        if (indexPath.row == 1) { // cancel subscription
            accountDaoToCancelSubscription = [[AccountDao alloc]init];
            accountDaoToCancelSubscription.delegate = self;
            accountDaoToCancelSubscription.successMethod = @selector(cancelSubscriptionCallback);
            accountDaoToCancelSubscription.failMethod = @selector(cancelSubscriptionFailCallback:);
            [accountDaoToCancelSubscription requestCancelSubscription:currentSubscription];
        }
    }
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
