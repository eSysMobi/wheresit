//
//  MainViewController.h
//  Where-is-it
//
//  Created by Mac on 24.08.13.
//  Copyright (c) 2013 IT-insign. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MobileCoreServices/MobileCoreServices.h"
#import "MapKit/MapKit.h"
#import "Foundation/Foundation.h"
#import "ALAssetsLibrary+CustomPhotoAlbum.h"
#import "MapViewAnnotation.h"
#import <FacebookSDK/FacebookSDK.h>

@class AVCamCaptureManager, AVCamPreviewView, AVCaptureVideoPreviewLayer, PhotosViewController, SinglePhotoViewController, CollectionViewController;

@interface MainViewController : UIViewController < FBLoginViewDelegate,
UITableViewDataSource,
UIImagePickerControllerDelegate,
FBFriendPickerDelegate,
UINavigationControllerDelegate,
FBPlacePickerDelegate,
CLLocationManagerDelegate,
UIActionSheetDelegate,
UIScrollViewDelegate>

@property (strong, nonatomic) UITabBarController *tabBarController;
@property (strong, atomic) ALAssetsLibrary* library;

@property (nonatomic,retain) UIImage *image;
@property (nonatomic,retain) UIImage *imageSaved;
//@property (nonatomic,retain) NSData *imageData;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@property (nonatomic,retain) IBOutlet UIView *videoPreviewView;
@property (nonatomic,retain) AVCamCaptureManager *captureManager;
@property (nonatomic,retain) AVCaptureVideoPreviewLayer *captureVideoPreviewLayer;

@property (strong,nonatomic) PhotosViewController * photosViewController;
@property (strong,nonatomic) CollectionViewController * singlePhotoViewController;
@property (nonatomic,assign) CLLocation *location;

@property (weak, nonatomic) IBOutlet UIView *mainView;
@property (weak, nonatomic) IBOutlet UIView *photoView;

@property (weak, nonatomic) IBOutlet UIImageView *topImageView;
@property (weak, nonatomic) IBOutlet UIImageView *middleImageView;
@property (weak, nonatomic) IBOutlet UIImageView *bottomImageView;

@property (weak, nonatomic) IBOutlet UIButton *BInfo;
@property (strong, nonatomic) IBOutlet UIView *VInfo;
- (IBAction)AInfo:(id)sender;
- (IBAction)AInfoClose:(id)sender;


@property (weak, nonatomic) IBOutlet UIButton *BNew;
@property (weak, nonatomic) IBOutlet UIButton *BShare;
@property (weak, nonatomic) IBOutlet UIButton *BPhotos;

@property (weak, nonatomic) IBOutlet UIButton *BPlaces;
@property (weak, nonatomic) IBOutlet UIButton *BPhoto;
@property (weak, nonatomic) IBOutlet UIButton *BPhotosPick;

- (IBAction)ASelectPlace:(id)sender;
- (IBAction)ATakePhoto:(id)sender;
- (IBAction)AOpenPhotosPicker:(id)sender;

- (IBAction)AOpenPhotos:(id)sender;
- (IBAction)ATakeNewPhoto:(id)sender;
- (IBAction)ASharePhoto:(id)sender;

@end
