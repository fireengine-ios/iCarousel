//
//  PhotoListController.m
//  Depo
//
//  Created by Mahir on 9/24/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "PhotoListController.h"

@interface PhotoListController ()

@end

@implementation PhotoListController

- (id)init {
    self = [super init];
    if (self) {
        self.title = @"Photos";

        fileListDao = [[FileListDao alloc] init];
        fileListDao.delegate = self;
        fileListDao.successMethod = @selector(photoListSuccessCallback:);
        fileListDao.failMethod = @selector(photoListFailCallback:);
    }
    return self;
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [fileListDao requestPhotosForOffset:0 andSize:10];
}

- (void) photoListSuccessCallback:(NSArray *) files {
    for(MetaFile *row in files) {
        NSLog(@"Photo Name: %@", row.name);
    }
}

- (void) photoListFailCallback:(NSString *) errorMessage {
    [self showErrorAlertWithMessage:errorMessage];
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
