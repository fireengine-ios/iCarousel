//
//  SettingsConnectedDevicesController.m
//  Depo
//
//  Created by Salih Topcu on 23.09.2014.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "SettingsConnectedDevicesController.h"
#import "HeaderCell.h"
#import "TitleCell.h"
#import "TextCell.h"

@interface SettingsConnectedDevicesController ()

@end

@implementation SettingsConnectedDevicesController

- (id)init
{
    infoText1 = NSLocalizedString(@"ConnectedDevicesInfo", @"");
    infoText1Height = [Util calculateHeightForText:infoText1 forWidth:290 forFont:[UIFont fontWithName:@"TurkcellSaturaMed" size:14]];
    
    self = [super init];
    if (self) {
        self.title = NSLocalizedString(@"ConnectedDevices", @"");
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

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 6;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row == 5)
        return infoText1Height + 48;
    else
        return 54;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = [NSString stringWithFormat:@"MenuCell%d-%d", (int)indexPath.section, (int)indexPath.row];
    
    if(indexPath.row == 0) {
        NSString *connectedDevicesCountInfo = [NSString stringWithFormat:NSLocalizedString(@"ConnectedDevicesTitle", @""), 4];
        HeaderCell *cell = [[HeaderCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier headerText:connectedDevicesCountInfo];
        return cell;
    } else if(indexPath.row == 1) {
        TitleCell *cell = [[TitleCell alloc] initWithCellStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier titleText:@"Mehmet's Macbook" titleColor:nil subTitleText:@"" iconName:@"macbook_icon@2x" hasSeparator:YES isLink:NO linkText:@"" cellHeight:54];
        return cell;
    } else if(indexPath.row == 2) {
        TitleCell *cell = [[TitleCell alloc] initWithCellStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier titleText:@"iPhone" titleColor:nil subTitleText:@"" iconName:@"iphone_icon@2x" hasSeparator:YES isLink:NO linkText:@"" cellHeight:54];
        return cell;
    } else if(indexPath.row == 3) {
        TitleCell *cell = [[TitleCell alloc] initWithCellStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier titleText:@"Android" titleColor:nil subTitleText:@"" iconName:@"android_icon@2x" hasSeparator:YES isLink:NO linkText:@"" cellHeight:54];
        return cell;
    } else if(indexPath.row == 4) {
        TitleCell *cell = [[TitleCell alloc] initWithCellStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier titleText:@"iPad" titleColor:nil subTitleText:@"" iconName:@"ipad_icon@2x" hasSeparator:YES isLink:NO linkText:@"" cellHeight:54];
        return cell;
    } else if(indexPath.row == 5) {
        TextCell *cell = [[TextCell alloc]initWithCellStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier titleText:@"" titleColor:nil contentText:infoText1 contentTextColor:nil backgroundColor:nil hasSeparator:NO];
        return cell;
    } else {
        return nil;
    }
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch ([indexPath row]) {
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
