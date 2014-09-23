//
//  MyNavigationController.m
//  Depo
//
//  Created by mahir tarlan
//  Copyright (c) 2013 igones. All rights reserved.
//

#import "MyNavigationController.h"
#import "CustomButton.h"
#import "AppConstants.h"
#import "Util.h"

@interface MyNavigationController ()

@end

@implementation MyNavigationController

- (id)init {
    self = [super init];
    if (self) {
    }
    return self;
}

- (id)initWithRootViewController:(UIViewController *)rootViewController {
    self = [super initWithRootViewController:rootViewController];
    if (self) {
        [self.navigationBar setBackgroundColor:[Util UIColorForHexColor:@"3fb0e8"]];
        self.navigationBar.barStyle = UIBarStyleBlackOpaque;
        self.navigationBar.barTintColor =[Util UIColorForHexColor:@"3fb0e8"];
        
        if([self.navigationBar respondsToSelector:@selector(setShadowImage:)] ) {
            [self.navigationBar setShadowImage:[UIImage new]];
        }

        [[UINavigationBar appearance] setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
                                                               [UIColor colorWithRed:245.0/255.0 green:245.0/255.0 blue:245.0/255.0 alpha:1.0], NSForegroundColorAttributeName, nil]];

        [[UINavigationBar appearance] setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys: [UIColor whiteColor], NSForegroundColorAttributeName, [UIFont fontWithName:@"TurkcellSaturaBol" size:18], NSFontAttributeName, nil]];
        
        /*
        [[UINavigationBar appearance] setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
                                                               [UIColor colorWithRed:245.0/255.0 green:245.0/255.0 blue:245.0/255.0 alpha:1.0], NSForegroundColorAttributeName, nil]];
         */
    }
    return self;
}

- (void) pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    [super pushViewController:viewController animated:animated];
    
    if([self.viewControllers count] > 1) {
        CustomButton *customBackButton = [[CustomButton alloc] initWithFrame:CGRectMake(10, 0, 20, 34) withImageName:@"detay_ok.png"];
        [customBackButton addTarget:self action:@selector(triggerBackByNav) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithCustomView:customBackButton];
        viewController.navigationItem.leftBarButtonItem = backButton;
    }
}

- (void) triggerBackByNav {
    [self popViewControllerAnimated:YES];
}

- (void) hideNavigationBar {
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void) showNavigationBar {
    [self.navigationController setNavigationBarHidden:NO animated:YES];
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

- (BOOL)shouldAutorotate {
    if ([[self topViewController] respondsToSelector:@selector(shouldAutorotate)])
        return [[self topViewController] shouldAutorotate];
    else
        return NO;
}

- (NSUInteger)supportedInterfaceOrientations {
    if ([[self topViewController] respondsToSelector:@selector(supportedInterfaceOrientations)])
        return [[self topViewController] supportedInterfaceOrientations];
    else
        return [super supportedInterfaceOrientations];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    if ([[self topViewController] respondsToSelector:@selector(shouldAutorotateToInterfaceOrientation:)])
        return [[self topViewController] shouldAutorotateToInterfaceOrientation:interfaceOrientation];
    else
        return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
