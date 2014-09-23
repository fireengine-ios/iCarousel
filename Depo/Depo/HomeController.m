//
//  HomeController.m
//  Depo
//
//  Created by Mahir on 9/19/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "HomeController.h"
#import "MetaFile.h"

@interface HomeController ()

@end

@implementation HomeController

- (id)init {
    self = [super init];
    if (self) {
        self.title = @"";

        fileListDao = [[FileListDao alloc] init];
        fileListDao.delegate = self;
        fileListDao.successMethod = @selector(fileListSuccessCallback:);
        fileListDao.failMethod = @selector(fileListFailCallback:);
        
        [fileListDao requestFileListingForParentForOffset:0 andSize:10];
    }
    return self;
}

- (void) fileListSuccessCallback:(NSArray *) files {
    for(MetaFile *file in files) {
        NSLog(@"File name: %@", file.name);
    }
    
}

- (void) fileListFailCallback:(NSString *) errorMessage {
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
