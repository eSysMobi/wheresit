//
//  SinglePhotoViewController.h
//  Where-is-it
//
//  Created by Mac on 30.07.13.
//  Copyright (c) 2013 IT-insign. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "MapViewAnnotation.h"
#import "MobileCoreServices/MobileCoreServices.h"
#import "MapKit/MapKit.h"
#import "Foundation/Foundation.h"
#import <FacebookSDK/FacebookSDK.h>

@interface SinglePhotoViewController : UIViewController< FBLoginViewDelegate,
UITableViewDataSource,
UIImagePickerControllerDelegate,
FBFriendPickerDelegate,
UINavigationControllerDelegate,
FBPlacePickerDelegate,
CLLocationManagerDelegate,
UIActionSheetDelegate,
UIScrollViewDelegate> {
    UIButton *but;
    //  UIImageView *imageView;
    MKMapView *mapView;
    CLLocation *loc;
//    MapViewAnnotation *newAnnotation;
    BOOL newMedia;
    int l;
    UILabel *lab;
    UILabel *lab1;
    UILabel *lab2;
    
    __weak IBOutlet UIPageControl *pageControl;
    IBOutlet UIViewController *popupvc;
    
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

@property (nonatomic, retain) IBOutlet UIViewController *popupvc;
@property (strong, nonatomic) IBOutlet UIView *popoverView;



-(IBAction)infopressed;
- (IBAction)shareFB:(id)sender;
- (IBAction)selectPlace:(id)sender;
-(IBAction)route;
-(IBAction)usemaps2;
@end
