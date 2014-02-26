//
//  SelectPlacesViewController.m
//  Where-is-it
//
//  Created by Mac on 05.09.13.
//  Copyright (c) 2013 IT-insign. All rights reserved.
//

#import "SelectPlacesViewController.h"
#import "FQViewController.h"
#import "PPViewController.h"

@interface SelectPlacesViewController ()

@end

@implementation SelectPlacesViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        UIViewController *viewController1 = [[FQViewController alloc] initWithNibName:@"FQViewController" bundle:nil];
        
        UIViewController *viewController2  = [[PPViewController alloc] initWithNibName:@"PPViewController" bundle:nil];
        self.tabBarController = [[UITabBarController alloc] init];
        self.tabBarController.viewControllers = @[viewController1, viewController2];
        [self.navigationController pushViewController:self.tabBarController animated:YES];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
