//
//  SettingsContactsController.m
//  Depo
//
//  Created by Mustafa Talha Celik on 26.09.2014.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "SettingsContactsController.h"

@interface SettingsContactsController ()

@end

@implementation SettingsContactsController

- (id)init
{
    infoTextAuto = @"Your Address Book will be automaticially backed up to the cloud when you open the app.)";
    infoTextAutoHeight = [Util calculateHeightForText:infoTextAuto forWidth:280 forFont:[UIFont fontWithName:@"TurkcellSaturaMed" size:14]];
    
    infoTextOff = @"Your Music won't be visible within the app & you can't upload anything new.";
    infoTextOffHeight = [Util calculateHeightForText:infoTextOff forWidth:280 forFont:[UIFont fontWithName:@"TurkcellSaturaMed" size:14]];
    
    infoTextBackUp = @"Facebook, Twitter & Exchange Server contacts can't be backed up to Turkcell Cloud Storage.";
    infoTextBackUpHeight = [Util calculateHeightForText:infoTextOff forWidth:280 forFont:[UIFont fontWithName:@"TurkcellSaturaMed" size:14]];
    
    self = [super init];
    if (self) {
        self.title = @"Contacts";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (int) numberOfSectionsInTableView:(UITableView *)tableView {
    return 5;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == 0)
        return 31;
    else if(indexPath.section == 3)
        return infoTextAutoHeight + 48;
    else if(indexPath.section == 7)
        return infoTextBackUpHeight + 48;
    else if(indexPath.section == 8)
        return infoTextOffHeight + 48;
    else
        return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = [NSString stringWithFormat:@"MenuCell%d-%d", indexPath.section, indexPath.row];
    
    if(indexPath.section == 0) {
        HeaderCell *cell = [[HeaderCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier headerText:@""];
        return cell;
    } else if(indexPath.section == 1) {
        TitleCell *cell = [[TitleCell alloc] initWithCellStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier iconName:@"" titleText:@"On" checkStatus:NO];
        return cell;
    } else if(indexPath.section == 2) {
        TitleCell *cell = [[TitleCell alloc] initWithCellStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier iconName:@"" titleText:@"Off" checkStatus:NO];
        return cell;
    } else if(indexPath.section == 3) {
        TextCell *cell = [[TextCell alloc]initWithCellStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier titleText:@"" titleColor:nil contentText:infoTextAuto contentTextColor:nil backgroundColor:nil hasSeparator:NO];
        return cell;
    } else if(indexPath.section == 4) {
        TextCell *cell = [[TextCell alloc]initWithCellStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier titleText:@"" titleColor:nil contentText:infoTextOff contentTextColor:nil backgroundColor:nil hasSeparator:NO];
        return cell;
    } else {
        return nil;
    }
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch ([indexPath section]) {
        case 0:
            break;
        case 1:
            
            break;
        case 2:
            
            break;
        case 3:
            
            break;
        case 4:
            
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
