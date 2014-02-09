//
//  ViewController2.h
//  Where is it
//
//  Created by Vladimir P. Starkov on 21.09.12.
//  Copyright (c) 2012 Vladimir P. Starkov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewController.h"
#import "MapViewAnnotation.h"
#import "MobileCoreServices/MobileCoreServices.h"
#import "MapKit/MapKit.h"
#import "Foundation/Foundation.h"

@interface ViewController2 : UIViewController{
    UIButton *but;
  //  UIImageView *imageView;
    MKMapView *mapView;
    CLLocation *loc;
    MapViewAnnotation *newAnnotation;
    BOOL newMedia;
    int l;
    UILabel *lab;
    UILabel *lab1;
    UILabel *lab2;

}
@property (nonatomic,retain) IBOutlet UIScrollView *scroll;
@property (nonatomic,retain) IBOutlet UIActivityIndicatorView *aiv;
@property (nonatomic,retain) IBOutlet MKMapView *mapView;
@property (nonatomic,retain) IBOutlet UIButton *but2;
@property (nonatomic,retain) IBOutlet UIButton *but3;
@property (nonatomic,retain) IBOutlet UIImageView *menu;
@property (nonatomic,retain) UIBarButtonItem *inf;
@property (nonatomic,assign) CLLocation *loc;
@property (nonatomic,retain) CLLocationManager *manager;
@property (nonatomic,assign) int detailItem;
-(IBAction)infopressed;
-(IBAction)route;
-(IBAction)usemaps2;
@end
