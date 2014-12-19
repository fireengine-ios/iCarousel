//
//  SettingsPhotosVideosController.m
//  Depo
//
//  Created by Mustafa Talha Celik on 26.09.2014.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "SettingsPhotosVideosController.h"

@interface SettingsPhotosVideosController ()

@end

@implementation SettingsPhotosVideosController

- (id)init
{
    infoTextAuto =  NSLocalizedString(@"Photos&VideosAutoInfo", @"");
    infoTextAutoHeight = [Util calculateHeightForText:infoTextAuto forWidth:280 forFont:[UIFont fontWithName:@"TurkcellSaturaMed" size:14]];
    
    infoTextOn = NSLocalizedString(@"Photos&VideosOnInfo", @"");
    infoTextOnHeight = [Util calculateHeightForText:infoTextOn forWidth:280 forFont:[UIFont fontWithName:@"TurkcellSaturaMed" size:14]];
    
    infoTextOff = NSLocalizedString(@"Photos&VideosOffInfo", @"");
    infoTextOffHeight = [Util calculateHeightForText:infoTextOff forWidth:280 forFont:[UIFont fontWithName:@"TurkcellSaturaMed" size:14]];
    
    self = [super init];
    if (self) {
        self.title = NSLocalizedString(@"Photos&Videos", @"");
        currentSetting = [CacheUtil readCachedSettingSyncPhotosVideos];
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
        [CacheUtil writeCachedSettingSyncPhotosVideos:currentSetting];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 7;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row == 0)
        return 31;
    else if(indexPath.row == 4) {
        return (currentSetting == EnableOptionAuto) ? infoTextAutoHeight + 48 : 0;
    }
    else if(indexPath.row == 5) {
        return (currentSetting == EnableOptionOn) ? infoTextAutoHeight + 48 : 0;
    }
    else if(indexPath.row == 6) {
        return (currentSetting == EnableOptionOff) ? infoTextAutoHeight + 48 : 0;
    }
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
        TitleCell *cell = [[TitleCell alloc] initWithCellStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier iconName:@"" titleText:[self getEnableOptionName:EnableOptionOn] checkStatus:(currentSetting == EnableOptionOn)];
        return cell;
    } else if(indexPath.row == 3) {
        TitleCell *cell = [[TitleCell alloc] initWithCellStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier iconName:@"" titleText:[self getEnableOptionName:EnableOptionOff] checkStatus:(currentSetting == EnableOptionOff)];
        return cell;
    } else if(indexPath.row == 4) {
        TextCell *cell = [[TextCell alloc]initWithCellStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier titleText:@"" titleColor:nil contentText:infoTextAuto contentTextColor:nil backgroundColor:nil hasSeparator:NO];
        cell.hidden = (currentSetting != EnableOptionAuto);
        return cell;
    } else if(indexPath.row == 5) {
        TextCell *cell = [[TextCell alloc]initWithCellStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier titleText:@"" titleColor:nil contentText:infoTextOn contentTextColor:nil backgroundColor:nil hasSeparator:NO];
        cell.hidden = (currentSetting != EnableOptionOn);
        return cell;
    } else if(indexPath.row == 6) {
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
            [super setAuto];
            break;
        case 2:
            [super setOn];
            break;
        case 3:
            [super setOff];
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
