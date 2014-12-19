//
//  SettingsContactsController.m
//  Depo
//
//  Created by Salih Topcu on 26.09.2014.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "SettingsContactsController.h"

@interface SettingsContactsController ()

@end

@implementation SettingsContactsController

- (id)init
{
    infoTextAuto = NSLocalizedString(@"ContactsAutoInfo", @"");
    infoTextAutoHeight = [Util calculateHeightForText:infoTextAuto forWidth:280 forFont:[UIFont fontWithName:@"TurkcellSaturaMed" size:14]];
    
    infoTextOff = NSLocalizedString(@"ContactsOffInfo", @"");
    infoTextOffHeight = [Util calculateHeightForText:infoTextOff forWidth:280 forFont:[UIFont fontWithName:@"TurkcellSaturaMed" size:14]];
    
    infoTextBackUp = NSLocalizedString(@"ContactsAutoDescriptionBody", @"");
    infoTextBackUpHeight = [Util calculateHeightForText:infoTextOff forWidth:280 forFont:[UIFont fontWithName:@"TurkcellSaturaMed" size:14]];
    
    self = [super init];
    if (self) {
        self.title = NSLocalizedString(@"Contacts", @"");
        currentSetting = [CacheUtil readCachedSettingSyncContacts];
        oldSetting = currentSetting;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void) viewWillDisappear:(BOOL)animated {
    if (currentSetting != oldSetting)
        [CacheUtil writeCachedSettingSyncContacts:currentSetting];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 9;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row == 0)
        return 31;
    else if(indexPath.row == 3)
        return (currentSetting == EnableOptionAuto) ? infoTextAutoHeight + 48 : 0;
    else if(indexPath.row == 4 || indexPath.row == 5 || indexPath.row == 6)
        return (currentSetting == EnableOptionAuto) ? 69 : 0;
    else if(indexPath.row == 7)
        return (currentSetting == EnableOptionAuto) ? infoTextBackUpHeight + 48 : 0;
    else if(indexPath.row == 8)
        return (currentSetting == EnableOptionOff) ? infoTextOffHeight + 48 : 0;
    else
        return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = [NSString stringWithFormat:@"MenuCell%d-%d", (int)indexPath.section, (int)indexPath.row];
    
    if(indexPath.row == 0) {
        HeaderCell *cell = [[HeaderCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier headerText:@""];
        return cell;
    } else if(indexPath.row == 1) {
        TitleCell *cell = [[TitleCell alloc] initWithCellStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier iconName:@"" titleText:[self getEnableOptionName:EnableOptionAuto] checkStatus:(currentSetting == EnableOptionAuto)];
        return cell;
    } else if(indexPath.row == 2) {
        TitleCell *cell = [[TitleCell alloc] initWithCellStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier iconName:@"" titleText:[self getEnableOptionName:EnableOptionOff] checkStatus:(currentSetting == EnableOptionOff)];
        return cell;
    } else if(indexPath.row == 3) {
        TextCell *cell = [[TextCell alloc]initWithCellStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier titleText:@"" titleColor:nil contentText:infoTextAuto contentTextColor:nil backgroundColor:nil hasSeparator:NO];
        cell.hidden = (currentSetting != EnableOptionAuto);
        return cell;
    } else if(indexPath.row == 4) {
        TitleCell *cell = [[TitleCell alloc] initWithCellStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier titleText:NSLocalizedString(@"PhoneContacts", @"") subTitletext:@"185" SwitchButtonStatus:YES];
        //[cell.switchButton addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
        cell.hidden = (currentSetting != EnableOptionAuto);
        return cell;
    } else if(indexPath.row == 5) {
        TitleCell *cell = [[TitleCell alloc] initWithCellStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier titleText:@"Google" subTitletext:@"20" SwitchButtonStatus:YES];
        //[cell.switchButton addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
        cell.hidden = (currentSetting != EnableOptionAuto);
        return cell;
    } else if(indexPath.row == 6) {
        TitleCell *cell = [[TitleCell alloc] initWithCellStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier titleText:@"Yahoo" subTitletext:@"15" SwitchButtonStatus:YES];
        //[cell.switchButton addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
        cell.hidden = (currentSetting != EnableOptionAuto);
        return cell;
    } else if(indexPath.row == 7) {
        NSString *autoInfoHeader = [NSString stringWithFormat:NSLocalizedString(@"ContactsAutoDescriptionHeader", @""), 165];
        TextCell *cell = [[TextCell alloc]initWithCellStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier titleText:autoInfoHeader titleColor:[Util UIColorForHexColor:@"555748"] contentText:infoTextBackUp contentTextColor:[Util UIColorForHexColor:@"82866D"] backgroundColor:[Util UIColorForHexColor:@"FFF6B2"] hasSeparator:NO];
        cell.hidden = (currentSetting != EnableOptionAuto);
        return cell;
    } else if(indexPath.row == 8) {
        TextCell *cell = [[TextCell alloc]initWithCellStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier titleText:@"" titleColor:nil contentText:infoTextOff contentTextColor:nil backgroundColor:nil hasSeparator:NO];
        cell.hidden = (currentSetting != EnableOptionOff);
        return cell;
    } else {
        return nil;
    }
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch ([indexPath row]) {
        case 1:
            [self setAuto];
            currentSetting = EnableOptionAuto;
            break;
        case 2:
            [self setOff];
            currentSetting = EnableOptionOff;
            break;
        default:
            break;
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
