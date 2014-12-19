//
//  SettingsHelpController.m
//  Depo
//
//  Created by Salih Topcu on 23.09.2014.
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
        self.title = NSLocalizedString(@"Help", @"");
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 6;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row == 0 || indexPath.row == 4)
        return 31;
    else
        return 54;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = [NSString stringWithFormat:@"MenuCell%d-%d", (int)indexPath.section, (int)indexPath.row];
    
    if(indexPath.row == 0) {
        HeaderCell *cell = [[HeaderCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier headerText:@""];
        return cell;
    } else if(indexPath.row == 1) {
        TitleCell *cell = [[TitleCell alloc] initWithCellStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier titleText:NSLocalizedString(@"VideoHelpGuides", @"") titleColor:nil subTitleText:@"" iconName:@"" hasSeparator:YES isLink:YES linkText:@"" cellHeight:54];
        return cell;
    } else if(indexPath.row == 2) {
        TitleCell *cell = [[TitleCell alloc] initWithCellStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier titleText:NSLocalizedString(@"Troubleshooting", @"") titleColor:nil subTitleText:@"" iconName:@"" hasSeparator:YES isLink:YES linkText:@"" cellHeight:54];
        return cell;
    } else if(indexPath.row == 3) {
        TitleCell *cell = [[TitleCell alloc] initWithCellStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier titleText:NSLocalizedString(@"AboutAkilliDepo", @"") titleColor:nil subTitleText:@"" iconName:@"" hasSeparator:YES isLink:YES linkText:@"" cellHeight:54];
        return cell;
    } else if(indexPath.row == 4) {
        HeaderCell *cell = [[HeaderCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier headerText:@""];
        return cell;
    } else if(indexPath.row == 5) {
        TitleCell *cell = [[TitleCell alloc] initWithCellStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier titleText:NSLocalizedString(@"SupportWebsite", @"") titleColor:[Util UIColorForHexColor:@"3FB0E8"] subTitleText:@"" iconName:@"" hasSeparator:YES isLink:NO linkText:@"" cellHeight:54];
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
