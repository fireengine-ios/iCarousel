//
//  SettingsUploadController.m
//  Depo
//
//  Created by Mustafa Talha Celik on 23.09.2014.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "SettingsUploadController.h"
#import "SettingsPhotosVideosController.h"
#import "SettingsMusicController.h"
#import "SettingsDocumentsController.h"
#import "SettingsContactsController.h"

@interface SettingsUploadController ()

@end

@implementation SettingsUploadController

- (id)init
{
    self = [super init];
    if (self) {
        self.title = @"Upload & Syncing";
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
    return 10;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == 0 || indexPath.section == 8)
        return 31;
    else if(indexPath.section == 6 || indexPath.section == 7)
        return 44;
    else if(indexPath.section == 9)
        return 69;
    else
        return 54;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = [NSString stringWithFormat:@"MenuCell%d-%d", indexPath.section, indexPath.row];
    
    if(indexPath.section == 0) {
        HeaderCell *cell = [[HeaderCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier headerText:@""];
        return cell;
    } else if(indexPath.section == 1) {
        TitleCell *cell = [[TitleCell alloc] initWithCellStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier titleText:@"Photos & Videos" titleColor:nil subTitleText:@"" iconName:@"" hasSeparator:YES isLink:YES linkText:@"Auto" cellHeight:54];
        return cell;
    } else if(indexPath.section == 2) {
        TitleCell *cell = [[TitleCell alloc] initWithCellStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier titleText:@"Music" titleColor:nil subTitleText:@"" iconName:@"" hasSeparator:YES isLink:YES linkText:@"On" cellHeight:54];
        return cell;
    } else if(indexPath.section == 3) {
        TitleCell *cell = [[TitleCell alloc] initWithCellStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier titleText:@"Documents" titleColor:nil subTitleText:@"" iconName:@"" hasSeparator:YES isLink:YES linkText:@"On" cellHeight:54];
        return cell;
    } else if(indexPath.section == 4) {
        TitleCell *cell = [[TitleCell alloc] initWithCellStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier titleText:@"Contacts" titleColor:nil subTitleText:@"" iconName:@"" hasSeparator:YES isLink:YES linkText:@"Auto" cellHeight:54];
        return cell;
    } else if(indexPath.section == 5) {
        HeaderCell *cell = [[HeaderCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier headerText:@"SYNCHRONISATION PREFERENCES"];
        return cell;
    } else if(indexPath.section == 6) {
        TitleCell *cell = [[TitleCell alloc] initWithCellStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier iconName:@"" titleText:@"Wifi + 3G" checkStatus:YES];
        return cell;
    } else if(indexPath.section == 7) {
        TitleCell *cell = [[TitleCell alloc] initWithCellStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier iconName:@"" titleText:@"Wifi" checkStatus:NO];
        return cell;
    } else if(indexPath.section == 8) {
        HeaderCell *cell = [[HeaderCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier headerText:@""];
        return cell;
    } else if(indexPath.section == 9) {
        TitleCell *cell = [[TitleCell alloc] initWithCellStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier titleText:@"Data Roaming" subTitletext:@"Auto upload whilst abroad" toggleStatus:YES];
        return cell;
    } else {
        return nil;
    }
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch ([indexPath section]) {
        case 1:
            [self didTriggerPhotosVideos];
            break;
        case 2:
            [self didTriggerMusic];
            break;
        case 3:
            [self didTriggerDocuments];
            break;
        case 4:
            [self didTriggerContacts];
            break;
        case 6:
            
            break;
        case 7:
            
        default:
            break;
    }
}

- (void) didTriggerPhotosVideos {
    SettingsPhotosVideosController *photosVideosController = [[SettingsPhotosVideosController alloc] init];
    [self.nav pushViewController:photosVideosController animated:YES];
    
}

- (void) didTriggerMusic {
    SettingsMusicController *musicController = [[SettingsMusicController alloc] init];
    [self.nav pushViewController:musicController animated:YES];
}

- (void) didTriggerDocuments {
    SettingsDocumentsController *documentsController = [[SettingsDocumentsController alloc] init];
    [self.nav pushViewController:documentsController animated:YES];
}

- (void) didTriggerContacts {
    SettingsContactsController *contactsController = [[SettingsContactsController alloc] init];
    [self.nav pushViewController:contactsController animated:YES];
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
