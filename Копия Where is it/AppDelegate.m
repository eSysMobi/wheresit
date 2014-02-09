//
//  AppDelegate.m
//  Where is it
//
//  Created by Vladimir P. Starkov on 04.09.12.
//  Copyright (c) 2012 Vladimir P. Starkov. All rights reserved.
//

#import "AppDelegate.h"

#import "ViewController.h"
#import "ViewController1.h"
#import "ViewController2.h"

@implementation AppDelegate
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{   int cacheSizeMemory = 4*1024*1024;
    int cacheSizeDisk = 32*1024*1024;
    CLLocationManager *manager = [[CLLocationManager alloc] init];
    manager.delegate = self;
    manager.distanceFilter = kCLDistanceFilterNone;
    manager.desiredAccuracy = kCLLocationAccuracyBest;
    [manager startUpdatingLocation];
    NSURLCache *sharedCache = [[NSURLCache alloc] initWithMemoryCapacity:cacheSizeMemory diskCapacity:cacheSizeDisk diskPath:@"nsurlcache.db"];
    [NSURLCache setSharedURLCache:sharedCache];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    ViewController *viewController = [[ViewController alloc] initWithNibName:@"ViewController" bundle:nil];
    ViewController1 *viewController1 = [[ViewController1 alloc] initWithNibName:@"ViewController1" bundle:nil];
    ViewController2 *viewController2 = [[ViewController2 alloc] initWithNibName:@"ViewController2" bundle:nil];
    self.navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
    self.navigationController2 = [[UINavigationController alloc] initWithRootViewController:viewController1];
    self.navigationController2.navigationBar.tintColor=[UIColor orangeColor];
    [self.navigationController.navigationBar setFrame:CGRectMake(0, 0, 640, 64)];


    //self.navigationController2.tabBarItem.image=[UIImage imageNamed:@"fotos25(1).png"];
    [self.navigationController2.tabBarItem setFinishedSelectedImage:[UIImage imageNamed:@"fotos25.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"fotos25h.png"]];
    self.navigationController2.title = @"Photos";
    [self.navigationController2.navigationBar setBackgroundImage:[UIImage imageNamed:@"top_2.png"] forBarMetrics:UIBarStyleDefault];
    //self.navigationController.tabBarItem.image=[UIImage imageNamed:@"kamera25.png"];
    [self.navigationController.tabBarItem setFinishedSelectedImage:[UIImage imageNamed:@"kamera25.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"kamera25h.png"]];
    self.navigationController.title = @"Take photo";
    self.navigationController.navigationBarHidden=NO;
    self.navigationController.navigationBar.tintColor=[UIColor orangeColor];
    self.navigationController.navigationBar.backItem.hidesBackButton=YES;
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"top_2.png"] forBarMetrics:UIBarStyleDefault];
    UITabBarController *tbc = [[UITabBarController alloc] init];
    NSArray *tabs_array = [[NSArray alloc] initWithObjects:self.navigationController,self.navigationController2, nil];
    tbc.viewControllers = tabs_array;
    tbc.tabBar.tintColor=[UIColor yellowColor];
    [[UITabBar appearance] setSelectedImageTintColor:[UIColor blackColor]];
    [[UITabBarItem appearance] setTitleTextAttributes:@{UITextAttributeTextColor:[UIColor blackColor]} forState:UIControlStateNormal];
    UIImageView *im = [[UIImageView alloc] init];
    im.frame=CGRectMake(0, 0, 320, 96);
    im.image=[UIImage imageNamed:@"menu2.png"];
    [[tbc tabBar] insertSubview:im atIndex:1];
    [self.window setRootViewController:tbc];
    [self.window addSubview:tbc.view];
    [self.window makeKeyAndVisible];
    return YES;
}

-(void)applicationDidReceiveMemoryWarning:(UIApplication *)application{
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

    

@end
