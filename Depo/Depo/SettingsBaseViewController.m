//
//  SettingsBaseViewController.m
//  Depo
//
//  Created by Mustafa Talha Celik on 26.09.2014.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "SettingsBaseViewController.h"

@interface SettingsBaseViewController ()

@end

@implementation SettingsBaseViewController

- (id)init
{
    self = [super init];
    if (self) {
        //topIndex = IS_BELOW_7 ? 0 : 20;
        
        self.view.backgroundColor = [Util UIColorForHexColor:@"F1F2F6"];
        
        pageContentTable = [[UITableView alloc] initWithFrame:CGRectMake(0, topIndex, 320, self.view.frame.size.height - topIndex) style:UITableViewStylePlain];
        pageContentTable.delegate = self;
        pageContentTable.dataSource = self;
        pageContentTable.backgroundColor = [UIColor clearColor];
        pageContentTable.backgroundView = nil;
        [pageContentTable setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        [self.view addSubview:pageContentTable];
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

- (int) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
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
