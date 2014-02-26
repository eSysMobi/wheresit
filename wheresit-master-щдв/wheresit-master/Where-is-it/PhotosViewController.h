//
//  PhotosViewController.h
//  Where-is-it
//
//  Created by Mac on 30.07.13.
//  Copyright (c) 2013 IT-insign. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "SinglePhotoViewController.h"
@class SinglePhotoViewController;
@class TakePhotoViewController;

@interface PhotosViewController : UIViewController{
    UIButton *button;
    int l;
}
@property (strong,nonatomic) SinglePhotoViewController *detailViewController;
@property (strong,nonatomic) UILabel *lab;
@property (strong,nonatomic) TakePhotoViewController *takePhotoViewController;
@property (nonatomic,retain) UIBarButtonItem *inf;
-(IBAction)buttonClick:(UIButton *)sender;
@end
