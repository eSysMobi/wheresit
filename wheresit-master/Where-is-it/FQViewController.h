//
//  FQViewController.h
//  Where-is-it
//
//  Created by Mac on 05.09.13.
//  Copyright (c) 2013 IT-insign. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

typedef void(^ConfirmCallback)(id sender, NSString *place);
@class FSVenue;
@interface FQViewController : UIViewController<CLLocationManagerDelegate>{
    CLLocationManager *_locationManager;
}
@property (copy, nonatomic) ConfirmCallback confirmCallback;

@property (strong,nonatomic)IBOutlet MKMapView* mapView;
@property (strong,nonatomic)IBOutlet UITableView* tableView;
@property (strong, nonatomic) IBOutlet UILabel *usernameLabel;
@property (strong, nonatomic) IBOutlet UIView *footer;
@property (strong, nonatomic) IBOutlet UIButton *logoutButton;


@property (strong,nonatomic)FSVenue* selected;
@property (strong,nonatomic)NSArray* nearbyVenues;

- (NSString*)getFirstPlace;
@end
