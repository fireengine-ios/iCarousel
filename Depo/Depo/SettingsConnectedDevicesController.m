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

- (id)init {
    self = [super init];
    if (self) {
        self.title = NSLocalizedString(@"ConnectedDevices", @"");
    }
    return self;
}

- (void) viewWillAppear:(BOOL)animated {
    [super showLoading];
    deviceDao = [[DeviceDao alloc]init];
    deviceDao.delegate = self;
    deviceDao.successMethod = @selector(loadDevicesCallback:);
    deviceDao.failMethod = @selector(loadDevicesFailCallback:);
    [deviceDao requestConnectedDevices];
    
    [super viewWillAppear:animated];
}

- (void) loadDevicesCallback:(NSArray *) files {
    [super hideLoading];
    devicesArray = [[NSMutableArray alloc] initWithArray:files];
    [super drawPageContentTable];
}

- (void) loadDevicesFailCallback:(NSString *) errorMessage {
    [super hideLoading];
    [super showErrorAlertWithMessage:errorMessage];
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return devicesArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 54;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 54;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return [[HeaderCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"" headerText:[NSString stringWithFormat:NSLocalizedString(@"ConnectedDevicesTitle", @""), [devicesArray count]]];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = [NSString stringWithFormat:@"MenuCell%d-%d", (int)indexPath.section, (int)indexPath.row];
    
    Device *device = [devicesArray objectAtIndex:indexPath.row];
    NSString *iconName;
    if (device.type == DeviceTypeIphone)
        iconName = @"iphone_icon";
    else if (device.type == DeviceTypeIpad)
        iconName = @"ipad_icon";
    else if (device.type == DeviceTypeMac)
        iconName = @"macbook_icon";
    else if (device.type == DeviceTypeWindows)
        iconName = @"macbook_icon";
    else if (device.type == DeviceTypeAndroid)
        iconName = @"android_icon";
    else
        iconName = @"default_loading_bg";
    
    TitleCell *cell = [[TitleCell alloc] initWithCellStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier titleText:device.name titleColor:nil subTitleText:@"" iconName:iconName hasSeparator:YES isLink:NO linkText:@"" cellHeight:54];
    return cell;
}

@end
