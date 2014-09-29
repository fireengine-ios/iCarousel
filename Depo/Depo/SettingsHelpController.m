//
//  SettingsHelpController.m
//  Depo
//
//  Created by Mustafa Talha Celik on 23.09.2014.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "SettingsHelpController.h"

@interface SettingsHelpController ()

@end

@implementation SettingsHelpController

- (id)init
{
    self = [super init];
    if (self) {
        self.title = @"Help";
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
    return 6;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == 0 || indexPath.section == 4)
        return 31;
    else
        return 54;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = [NSString stringWithFormat:@"MenuCell%d-%d", indexPath.section, indexPath.row];
    
    if(indexPath.section == 0) {
        HeaderCell *cell = [[HeaderCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier headerText:@""];
        return cell;
    } else if(indexPath.section == 1) {
        TitleCell *cell = [[TitleCell alloc] initWithCellStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier titleText:@"Video Help Guides" titleColor:nil subTitleText:@"" iconName:@"" hasSeparator:YES isLink:YES linkText:@"" cellHeight:54];
        return cell;
    } else if(indexPath.section == 2) {
        TitleCell *cell = [[TitleCell alloc] initWithCellStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier titleText:@"Toubleshooting" titleColor:nil subTitleText:@"" iconName:@"" hasSeparator:YES isLink:YES linkText:@"" cellHeight:54];
        return cell;
    } else if(indexPath.section == 3) {
        TitleCell *cell = [[TitleCell alloc] initWithCellStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier titleText:@"About Akilli Depo" titleColor:nil subTitleText:@"" iconName:@"" hasSeparator:YES isLink:YES linkText:@"" cellHeight:54];
        return cell;
    } else if(indexPath.section == 4) {
        HeaderCell *cell = [[HeaderCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier headerText:@""];
        return cell;
        return cell;
    } else if(indexPath.section == 5) {
        TitleCell *cell = [[TitleCell alloc] initWithCellStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier titleText:@"Support website" titleColor:[Util UIColorForHexColor:@"3FB0E8"] subTitleText:@"" iconName:@"" hasSeparator:YES isLink:NO linkText:@"" cellHeight:54];
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
