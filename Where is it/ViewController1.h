//
//  ViewController1.h
//  Where is it
//
//  Created by Vladimir P. Starkov on 04.12.12.
//  Copyright (c) 2012 Vladimir P. Starkov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewController2.h"
#import "ViewController.h"
@class ViewController2;
@class ViewController;

@interface ViewController1 : UIViewController{
        UIButton *button;
    int l;
}
@property (strong,nonatomic) ViewController2 *viewController2;
@property (strong,nonatomic) UILabel *lab;
@property (strong,nonatomic) ViewController *viewController;
@property (nonatomic,retain) UIBarButtonItem *inf;
-(IBAction)buttonClick:(UIButton *)sender;
@end
