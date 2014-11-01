//
//  SortModalController.m
//  Depo
//
//  Created by Mahir on 30/10/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "SortModalController.h"
#import "CustomButton.h"
#import "SortTypeCell.h"
#import "AppDelegate.h"
#import "AppSession.h"

@interface SortModalController ()

@end

@implementation SortModalController

@synthesize delegate;
@synthesize sortTable;
@synthesize sortTypes;

- (id) init {
    if(self = [super init]) {
        self.title = NSLocalizedString(@"SortTitle", @"");
        self.view.backgroundColor = [UIColor whiteColor];

        CustomButton *cancelButton = [[CustomButton alloc] initWithFrame:CGRectMake(0, 0, 60, 20) withImageName:nil withTitle:NSLocalizedString(@"ButtonCancel", @"") withFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:18] withColor:[UIColor whiteColor]];
        [cancelButton addTarget:self action:@selector(triggerDismiss) forControlEvents:UIControlEventTouchUpInside];
        
        UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithCustomView:cancelButton];
        self.navigationItem.leftBarButtonItem = cancelItem;

        CustomButton *applyButton = [[CustomButton alloc] initWithFrame:CGRectMake(0, 0, 60, 20) withImageName:nil withTitle:NSLocalizedString(@"ApplyTitle", @"") withFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:18] withColor:[UIColor whiteColor]];
        [applyButton addTarget:self action:@selector(triggerApply) forControlEvents:UIControlEventTouchUpInside];
        
        UIBarButtonItem *applyItem = [[UIBarButtonItem alloc] initWithCustomView:applyButton];
        self.navigationItem.rightBarButtonItem = applyItem;

        
        self.sortTypes = [NSArray arrayWithObjects:[NSNumber numberWithInt:SortTypeAlphaAsc], [NSNumber numberWithInt:SortTypeAlphaDesc], [NSNumber numberWithInt:SortTypeDateDesc], [NSNumber numberWithInt:SortTypeDateAsc], [NSNumber numberWithInt:SortTypeSizeDesc], [NSNumber numberWithInt:SortTypeSizeAsc], nil];
        
        UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        bgView.backgroundColor = [UIColor blackColor];
        bgView.alpha = 0.8;
        [self.view addSubview:bgView];

        sortTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStylePlain];
        sortTable.delegate = self;
        sortTable.dataSource = self;
        sortTable.backgroundColor = [UIColor clearColor];
        sortTable.backgroundView = nil;
        sortTable.separatorStyle = UITableViewCellSeparatorStyleNone;
        [sortTable sizeToFit];
        [self.view addSubview:sortTable];
        
    }
    return self;
}

- (void) triggerApply {
    [delegate sortDidChange];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [sortTypes count];
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = [NSString stringWithFormat:@"SORT_CELL_%d", (int)indexPath.row];
    NSNumber *sortType = [sortTypes objectAtIndex:indexPath.row];
    SortTypeCell *cell = [[SortTypeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier withSortType:[sortType intValue]];
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSNumber *sortType = [sortTypes objectAtIndex:indexPath.row];
    APPDELEGATE.session.sortType = [sortType intValue];
    [sortTable reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
