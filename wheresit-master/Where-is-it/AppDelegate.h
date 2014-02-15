//
//  AppDelegate.h
//  Where-is-it
//
//  Created by Mac on 30.07.13.
//  Copyright (c) 2013 IT-insign. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate, UITabBarControllerDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) UITabBarController *tabBarController;
@property (strong, nonatomic) FBUserSettingsViewController *settingsViewController;
@property (strong, nonatomic) UINavigationController *nav0;
@property (strong, nonatomic) UINavigationController *nav;
-(void) openSession;
-(void) presentLoginSettings;
@end
