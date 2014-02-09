//
//  ViewController.h
//  Where is it
//
//  Created by Vladimir P. Starkov on 04.09.12.
//  Copyright (c) 2012 Vladimir P. Starkov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MobileCoreServices/MobileCoreServices.h"
#import "MapKit/MapKit.h"
#import "Foundation/Foundation.h"
@class ViewController1;
@interface ViewController : UIViewController <UIImagePickerControllerDelegate,UINavigationControllerDelegate>{
    UIImageView *imageView;
    MKMapView *mapView;
    CLLocation *loc;
    BOOL newMedia;
    int l;
    int j;
    UILabel *lab;
    UILabel *lab1;
    UILabel *lab2;
}
@property (strong,nonatomic) ViewController1 * viewController1;
@property (nonatomic,retain) IBOutlet UIImageView *imageView;
@property (nonatomic,retain) IBOutlet UIButton *but1;
@property (nonatomic,retain) IBOutlet UIActivityIndicatorView *acv;
@property (nonatomic,retain) UIBarButtonItem *inf;
@property (nonatomic,assign) CLLocation *loc;
@property (nonatomic,retain) CLLocationManager *manager;
-(IBAction)infopressed;
-(IBAction)useCamera;
@end
