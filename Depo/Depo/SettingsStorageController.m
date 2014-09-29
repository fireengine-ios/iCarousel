//
//  SettingsStorageController.m
//  Depo
//
//  Created by Mustafa Talha Celik on 23.09.2014.
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
        self.title = @"Storage";
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
}

- (int) numberOfSectionsInTableView:(UITableView *)tableView {
    return 5;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == 1)
        return 69;
    else if(indexPath.section == 4)
        return 151;
    else
        return 54;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = [NSString stringWithFormat:@"MenuCell%d-%d", indexPath.section, indexPath.row];
    
    if(indexPath.section == 0) {
        HeaderCell *cell = [[HeaderCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier headerText:@"CURRENT PACKAGE"];
        return cell;
    } else if(indexPath.section == 1) {
        TitleCell *cell = [[TitleCell alloc] initWithCellStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier titleText:@"Mini Paket (5GB) 3.9 TL/Ay" titleColor:nil subTitleText:@"Renewal date: 7 Jun 2014" iconName:@"" hasSeparator:YES isLink:NO linkText:@"" cellHeight:69];
        return cell;
    } else if(indexPath.section == 2) {
        TitleCell *cell = [[TitleCell alloc] initWithCellStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier titleText:@"Cancel Subscription" titleColor:[Util UIColorForHexColor:@"3FB0E8"] subTitleText:@"" iconName:@"" hasSeparator:YES isLink:NO linkText:@"" cellHeight:54];
        return cell;
    } else if(indexPath.section == 3) {
        HeaderCell *cell = [[HeaderCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier headerText:@"UPGRADE OPTIONS"];
        return cell;
    } else if(indexPath.section == 4) {
        UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        [self drawUpgradeOptionsCell:cell];
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

- (void) drawUpgradeOptionsCell:(UITableViewCell *)cell {
    cell.backgroundColor = [Util UIColorForHexColor:@"FFFFFF"];
    
    UIButton *button1 = [[UIButton alloc]initWithFrame:CGRectMake(20, 20, 280, 50)];
    [button1 setTitle:@"Standard Paket (50GB) 9.9 TL/Ay" forState:UIControlStateNormal];
    button1.backgroundColor = [Util UIColorForHexColor:@"FEDB13"];
    button1.layer.cornerRadius = 5.0f;
    [button1 setTitleColor:[Util UIColorForHexColor:@"292F3E"] forState:UIControlStateNormal];
    button1.titleLabel.font = [UIFont fontWithName:@"TurkcellSaturaDem" size:18];
    [cell addSubview:button1];
    
    UIButton *button2 = [[UIButton alloc]initWithFrame:CGRectMake(20, 80, 280, 50)];
    [button2 setTitle:@"Mega Paket (250GB) 19.9 TL/Ay" forState:UIControlStateNormal];
    button2.backgroundColor = [Util UIColorForHexColor:@"FEDB13"];
    button2.layer.cornerRadius = 5.0f;
    [button2 setTitleColor:[Util UIColorForHexColor:@"292F3E"] forState:UIControlStateNormal];
    button2.titleLabel.font = [UIFont fontWithName:@"TurkcellSaturaDem" size:18];
    [cell addSubview:button2];
    
    UIView *greyLine = [[UIView alloc] initWithFrame:CGRectMake(0, 150, 320, 1)];
    greyLine.backgroundColor = [Util UIColorForHexColor:@"E0E2E0"];
    [cell addSubview:greyLine];
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
