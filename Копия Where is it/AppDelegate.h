//
//  AppDelegate.h
//  Where is it
//
//  Created by Vladimir P. Starkov on 04.09.12.
//  Copyright (c) 2012 Vladimir P. Starkov. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ViewController;
@class ViewController1;
@class ViewController2;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) UINavigationController *navigationController;
@property (strong, nonatomic) UINavigationController *navigationController2;

@end
