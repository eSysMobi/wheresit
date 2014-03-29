//
//  MainViewController.m
//  Where-is-it
//
//  Created by Mac on 24.08.13.
//  Copyright (c) 2013 IT-insign. All rights reserved.
//

#import "MainViewController.h"
#import "AVCamCaptureManager.h"
#import "AVCamRecorder.h"
#import <AVFoundation/AVFoundation.h>
#import "PhotosViewController.h"
#import "SinglePhotoViewController.h"
#import "AppDelegate.h"
#import "PPViewController.h"
#import "FQViewController.h"
#import "SelectPlacesViewController.h"
#import "CollectionViewController.h"
#import <AssetsLibrary/ALAsset.h>
#import <AssetsLibrary/ALAssetRepresentation.h>
#import <AssetsLibrary/ALAssetsGroup.h>
#import <ImageIO/CGImageSource.h>
#import <ImageIO/CGImageProperties.h>
#import <ImageIO/CGImageSource.h>
#import <ImageIO/CGImageProperties.h>
#import <CoreFoundation/CoreFoundation.h>
#import <AssetsLibrary/ALAssetsLibrary.h>
#import <ImageIO/ImageIO.h>
#import "Reachability.h"
#import <SystemConfiguration/SystemConfiguration.h>
@interface MainViewController (){
    @private AppDelegate* appDel;
    NSMutableArray* infos;
    int currentSavedIndx;
    
}
@property (weak, nonatomic) IBOutlet UIScrollView *InfoScroll;
@property (strong, nonatomic) FBUserSettingsViewController *settingsViewController;

@property (strong, nonatomic) NSString* placeName;
@property (strong, nonatomic) NSString* shareText;
@property (strong, nonatomic) NSObject<FBGraphPlace> *selectedPlace;
@property (strong, nonatomic) NSObject<FBGraphLocation> *selectedLocation;

@property (unsafe_unretained, nonatomic) IBOutlet FBLoginView *FBLoginView;
@property (strong, nonatomic) IBOutlet FBProfilePictureView *userProfileImage;

@property (strong, nonatomic) IBOutlet NSArray *selectedFriends;
@property (strong, nonatomic) UIImage *selectedPhoto;
@property (strong, nonatomic) NSString *message;

@property (strong, nonatomic) FBCacheDescriptor *placeCacheDescriptor;
@property (strong, nonatomic) CLLocationManager *locationManager;

@end
@interface MainViewController (InternalMethods)
- (CGPoint)convertToPointOfInterestFromViewCoordinates:(CGPoint)viewCoordinates;
- (void)tapToAutoFocus:(UIGestureRecognizer *)gestureRecognizer;
- (void)tapToContinouslyAutoFocus:(UIGestureRecognizer *)gestureRecognizer;
- (void)updateButtonStates;
- (void)cameraInit;
-(void)setInfo;
-(void) updateInfo;
-(void) selectFirstPlace;
@end

@interface MainViewController (AVCamCaptureManagerDelegate) <AVCamCaptureManagerDelegate>
-(void) showOptions:(BOOL) state animated:(BOOL) animated;
@end

@implementation MainViewController
@synthesize captureManager;
@synthesize captureVideoPreviewLayer;
@synthesize BNew, BPhoto,BPhotos,BPhotosPick,BPlaces,BShare;
@synthesize topImageView, middleImageView, bottomImageView;
@synthesize library;
@synthesize imageView, image, imageSaved, location;
@synthesize videoPreviewView;
@synthesize InfoScroll;

@synthesize photosViewController, singlePhotoViewController;



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization

    }
    return self;
}

- (void)viewDidLoad
{
    
    if ([ self  connected]) {
        //[self performSelectorInBackground:@selector(loadData) withObject:nil];
    }
    else{
        UIAlertView *aw=[[UIAlertView alloc] initWithTitle:@"Нет подключения" message:@"Проверьте соединение с интернетом" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [aw show];
        BPlaces.enabled =NO;
            }

    
//    [self performSelector:@selector(check) withObject:nil];
//    NSLog(@"%i=====",[self connected]);//на устройстве проверка на наличие/отсутствие интернета работает нормально
//    if ([ self  connected]) {
//        [self performSelectorInBackground:@selector(loadData) withObject:nil];}
//    else{
//        UIAlertView *aw=[[UIAlertView alloc] initWithTitle:@"Нет подключения" message:@"Проверьте соединение с интернетом" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
//        [aw show];}
    
    
    
    
    
    
    [super viewDidLoad];
    self.library=[[ALAssetsLibrary alloc] init];
    // Do any additional setup after loading the view from its nib.
    
    NSUserDefaults *usersDefaults = [NSUserDefaults standardUserDefaults];
    [usersDefaults setBool:NO forKey:@"Option"];
    
    self.photosViewController = [[PhotosViewController alloc] initWithNibName:@"PhotosViewController" bundle:nil];
    appDel = (AppDelegate*)[UIApplication sharedApplication].delegate;
    self.navigationController.navigationBarHidden = YES;
    

    [self setInfo];
    [self updateInfo];    
    [self cameraInit];
    [self connected];
//    [self selectFirstPlace];
}


-(BOOL)connected{
    Reachability *reach = [Reachability reachabilityForInternetConnection];
    NetworkStatus netstat = [reach currentReachabilityStatus];
    return !(netstat==NotReachable);
}

-(void)viewDidAppear:(BOOL)animated{
    self.navigationController.navigationBarHidden = YES;
    NSUserDefaults *usersDefaults = [NSUserDefaults standardUserDefaults];
    BOOL op = [usersDefaults boolForKey:@"Option"];
    [self showOptions:op animated:NO];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)viewDidUnload {
    [self setMainView:nil];
    [self setPhotoView:nil];
    [super viewDidUnload];
}
@end

//=================================================================================
@implementation MainViewController (InternalMethods)
-(void) selectFirstPlace{
    FQViewController *viewController1 = [[FQViewController alloc] initWithNibName:@"FQViewController" bundle:nil];
//    [self.view addSubview:viewController1];
    self.tabBarController = [[UITabBarController alloc] init];
    self.tabBarController.viewControllers = @[viewController1];
    self.tabBarController.view.frame = CGRectMake(-self.imageView.frame.size.width, 0, self.imageView.frame.size.width-20, self.imageView.frame.size.height);
    [self.view addSubview:self.tabBarController.view];
    
//
    self.placeName = [viewController1 getFirstPlace];
    [viewController1 removeFromParentViewController];
    [self updateInfo];
}
-(void)setInfo{
   
//    self.InfoScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0,0, 280, 150)];
//    [self.view addSubview:self.InfoScroll];
    self.placeName = @"Select location";
    
    self.InfoScroll.delegate = self;
    CLLocationManager *manager0 = [[CLLocationManager alloc] init];
    [manager0 startUpdatingLocation];
    location = manager0.location;
    
    UILabel* lb1 = [[UILabel alloc] initWithFrame:CGRectMake(0, 220, 620,60)];//self.InfoScroll.frame.size.width, self.InfoScroll.frame.size.height)];
    lb1.numberOfLines = 3;
    lb1.lineBreakMode = NSLineBreakByWordWrapping;
    lb1.textColor = [UIColor blackColor];
    lb1.backgroundColor = [UIColor whiteColor];
    lb1.text = [NSString stringWithFormat:@"IM HERE\n %@ ",self.placeName];

    self.shareText =    lb1.text;
    [self.InfoScroll addSubview:lb1];
    
    
    UILabel* lb2 = [[UILabel alloc] initWithFrame:CGRectMake(290, 220, 620,60)];//self.InfoScroll.frame.size.width, 0, self.InfoScroll.frame.size.width, self.InfoScroll.frame.size.height)];
    lb2.numberOfLines = 3;
    lb2.lineBreakMode = NSLineBreakByWordWrapping;
    lb2.backgroundColor = [UIColor whiteColor];
    lb2.textColor = [UIColor blackColor];
    NSLog(@"I'M HERE\n%fN %fE",location.coordinate.latitude, location.coordinate.longitude);
    
    lb2.text = [NSString stringWithFormat: @"I'M HERE\n%fN %fE",location.coordinate.latitude, location.coordinate.longitude];
    [self.InfoScroll addSubview:lb2];
    [self.InfoScroll setContentSize:CGSizeMake(560, 50)];
    self.InfoScroll.pagingEnabled = YES;
    [self.InfoScroll setShowsHorizontalScrollIndicator:NO];
    
    infos = [[NSMutableArray alloc] init];
    [infos addObject:lb1];
    [infos addObject:lb2];
}
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
//    NSLog(@"%f", self.InfoScroll.contentOffset.x);
    if(self.InfoScroll.contentOffset.x >= 132.0f)
        if(image != [UIImage imageNamed:@"middle2"])
        middleImageView.image = [UIImage imageNamed:@"middle2"];
    if(self.InfoScroll.contentOffset.x <= 131.0f)
        if(image != [UIImage imageNamed:@"middle1"])
        middleImageView.image = [UIImage imageNamed:@"middle1"];
}
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    int page = self.InfoScroll.contentOffset.x/self.InfoScroll.frame.size.width;
    CLLocationManager *manager0 = [[CLLocationManager alloc] init];
    [manager0 startUpdatingLocation];
    location = manager0.location;
    
    if(page == 0)
        self.shareText =  [NSString stringWithFormat: @"I'M HERE\n%@",self.placeName];
    else
        self.shareText = [NSString stringWithFormat: @"I'M HERE\n%fN %fE",location.coordinate.latitude, location.coordinate.longitude];
}
-(void) updateInfo {
 

    
    
    UILabel* label = infos[0];
    label.text = [NSString stringWithFormat: @"I'M HERE\n%@",self.placeName];

    CLLocationManager *manager0 = [[CLLocationManager alloc] init];
    [manager0 startUpdatingLocation];
    location = manager0.location;
    
    label = infos[1];
    label.text = [NSString stringWithFormat: @"I'M HERE\n%fN %fE",location.coordinate.latitude, location.coordinate.longitude];
    
    if(self.InfoScroll.contentOffset.x <= 131.0f){
        self.shareText =  [NSString stringWithFormat: @"I'M HERE\n%@",self.placeName]
        ;
    }
    else
        self.shareText = [NSString stringWithFormat: @"I'M HERE\n%fN %fE",location.coordinate.latitude, location.coordinate.longitude];
}


////========================================================= load image from album
//-(void)loadNewLibraryImages
//{
//    self.assetGroups = [[NSMutableArray alloc] init];
//    // Group enumerator Block
//    dispatch_async(dispatch_get_main_queue(), ^
//                   {
//                       void (^assetGroupEnumerator)(struct ALAssetsGroup *, BOOL *) = (^ALAssetsGroup *group, BOOL *stop)
//                    
//                       {
//                           if (group == nil)
//                           {
//                               return;
//                           }
//                           if ([[group valueForProperty:ALAssetsGroupPropertyName] isEqualToString:@"YOUR ALBUM NAME"]) {
//                               [self.assetGroups addObject:group];
//                               [self loadImages];
//                               return;
//                           }
//                           
//                           if (stop) {
//                               return;
//                           }
//                           
//                       };
//                       
//                       // Group Enumerator Failure Block
//                       void (^assetGroupEnumberatorFailure)(NSError *) = ^(NSError *error) {
//                           
//                           UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"ERROR" message:[NSString stringWithFormat:@"No Albums Available"] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
//                           [alert show];
//
//                       };
//                       
//                       // Enumerate Albums
//                       ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
//                       [library enumerateGroupsWithTypes:ALAssetsGroupAll
//                                              usingBlock:assetGroupEnumerator
//                                            failureBlock:assetGroupEnumberatorFailure];
//                       
//                       
//                   });
//    
//    
//}
//
//-(void)loadImages
//{
//    //for (ALAssetsGroup *assetGroup in self.assetGroups) {
//    //  for (int i = 0; i<[self.assetGroups count]; i++) {
//    
//    ALAssetsGroup *assetGroup = [self.assetGroups objectAtIndex:0];
//    NSLog(@"ALBUM NAME:;%@",[assetGroup valueForProperty:ALAssetsGroupPropertyName]);
//    
//    [assetGroup enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop)
//     {
//         if(result == nil)
//         {
//             return;
//         }
//         UIImage *img = [UIImage imageWithCGImage:[[result defaultRepresentation] fullScreenImage] scale:1.0 orientation:(UIImageOrientation)[[result valueForProperty:@"ALAssetPropertyOrientation"] intValue]];
//         
//     }];  
//    
//    //  }
//}





-(void) cameraInit{
    self.imageView.hidden = YES;
    
    if ([self captureManager] == nil) {
		AVCamCaptureManager *manager = [[AVCamCaptureManager alloc] init];
		[self setCaptureManager:manager];
        //		[manager release];
		
		[[self captureManager] setDelegate:self];
		if ([[self captureManager] setupSession]) {
            // Create video preview layer and add it to the UI
			AVCaptureVideoPreviewLayer *newCaptureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:[[self captureManager] session]];
			UIView *view = [self videoPreviewView];
			CALayer *viewLayer = [view layer];
			[viewLayer setMasksToBounds:YES];
			
			CGRect bounds = [view bounds];
			[newCaptureVideoPreviewLayer setFrame:bounds];
			
			if ([newCaptureVideoPreviewLayer isOrientationSupported]) {
				[newCaptureVideoPreviewLayer setOrientation:AVCaptureVideoOrientationPortrait];
			}
			
			[newCaptureVideoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
			
			[viewLayer insertSublayer:newCaptureVideoPreviewLayer below:[[viewLayer sublayers] objectAtIndex:0]];
			
			[self setCaptureVideoPreviewLayer:newCaptureVideoPreviewLayer];
            //            [newCaptureVideoPreviewLayer release];
			
            // Start the session. This is done asychronously since -startRunning doesn't return until the session is running.
			dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
				[[[self captureManager] session] startRunning];
			});
			
            [self updateButtonStates];
            
            // Add a single tap gesture to focus on the point tapped, then lock focus
			UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapToAutoFocus:)];
			[singleTap setDelegate:self];
			[singleTap setNumberOfTapsRequired:1];
			[view addGestureRecognizer:singleTap];
			
            // Add a double tap gesture to reset the focus mode to continuous auto focus
			UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapToContinouslyAutoFocus:)];
			[doubleTap setDelegate:self];
			[doubleTap setNumberOfTapsRequired:2];
			[singleTap requireGestureRecognizerToFail:doubleTap];
			[view addGestureRecognizer:doubleTap];
			
            
		}
	}
}

// Convert from view coordinates to camera coordinates, where {0,0} represents the top left of the picture area, and {1,1} represents
// the bottom right in landscape mode with the home button on the right.
- (CGPoint)convertToPointOfInterestFromViewCoordinates:(CGPoint)viewCoordinates
{
    CGPoint pointOfInterest = CGPointMake(.5f, .5f);
    CGSize frameSize = [[self videoPreviewView] frame].size;
    
    if ([captureVideoPreviewLayer isMirrored]) {
        viewCoordinates.x = frameSize.width - viewCoordinates.x;
    }
    
    if ( [[captureVideoPreviewLayer videoGravity] isEqualToString:AVLayerVideoGravityResize] ) {
		// Scale, switch x and y, and reverse x
        pointOfInterest = CGPointMake(viewCoordinates.y / frameSize.height, 1.f - (viewCoordinates.x / frameSize.width));
    } else {
        CGRect cleanAperture;
        for (AVCaptureInputPort *port in [[[self captureManager] videoInput] ports]) {
            if ([port mediaType] == AVMediaTypeVideo) {
                cleanAperture = CMVideoFormatDescriptionGetCleanAperture([port formatDescription], YES);
                CGSize apertureSize = cleanAperture.size;
                CGPoint point = viewCoordinates;
                
                CGFloat apertureRatio = apertureSize.height / apertureSize.width;
                CGFloat viewRatio = frameSize.width / frameSize.height;
                CGFloat xc = .5f;
                CGFloat yc = .5f;
                
                if ( [[captureVideoPreviewLayer videoGravity] isEqualToString:AVLayerVideoGravityResizeAspect] ) {
                    if (viewRatio > apertureRatio) {
                        CGFloat y2 = frameSize.height;
                        CGFloat x2 = frameSize.height * apertureRatio;
                        CGFloat x1 = frameSize.width;
                        CGFloat blackBar = (x1 - x2) / 2;
						// If point is inside letterboxed area, do coordinate conversion; otherwise, don't change the default value returned (.5,.5)
                        if (point.x >= blackBar && point.x <= blackBar + x2) {
							// Scale (accounting for the letterboxing on the left and right of the video preview), switch x and y, and reverse x
                            xc = point.y / y2;
                            yc = 1.f - ((point.x - blackBar) / x2);
                        }
                    } else {
                        CGFloat y2 = frameSize.width / apertureRatio;
                        CGFloat y1 = frameSize.height;
                        CGFloat x2 = frameSize.width;
                        CGFloat blackBar = (y1 - y2) / 2;
						// If point is inside letterboxed area, do coordinate conversion. Otherwise, don't change the default value returned (.5,.5)
                        if (point.y >= blackBar && point.y <= blackBar + y2) {
							// Scale (accounting for the letterboxing on the top and bottom of the video preview), switch x and y, and reverse x
                            xc = ((point.y - blackBar) / y2);
                            yc = 1.f - (point.x / x2);
                        }
                    }
                } else if ([[captureVideoPreviewLayer videoGravity] isEqualToString:AVLayerVideoGravityResizeAspectFill]) {
					// Scale, switch x and y, and reverse x
                    if (viewRatio > apertureRatio) {
                        CGFloat y2 = apertureSize.width * (frameSize.width / apertureSize.height);
                        xc = (point.y + ((y2 - frameSize.height) / 2.f)) / y2; // Account for cropped height
                        yc = (frameSize.width - point.x) / frameSize.width;
                    } else {
                        CGFloat x2 = apertureSize.height * (frameSize.height / apertureSize.width);
                        yc = 1.f - ((point.x + ((x2 - frameSize.width) / 2)) / x2); // Account for cropped width
                        xc = point.y / frameSize.height;
                    }
                }
                
                pointOfInterest = CGPointMake(xc, yc);
                break;
            }
        }
    }
    
    return pointOfInterest;
}

// Auto focus at a particular point. The focus mode will change to locked once the auto focus happens.
- (void)tapToAutoFocus:(UIGestureRecognizer *)gestureRecognizer
{
    if ([[[captureManager videoInput] device] isFocusPointOfInterestSupported]) {
        CGPoint tapPoint = [gestureRecognizer locationInView:[self videoPreviewView]];
        CGPoint convertedFocusPoint = [self convertToPointOfInterestFromViewCoordinates:tapPoint];
        [captureManager autoFocusAtPoint:convertedFocusPoint];
    }
}

// Change to continuous auto focus. The camera will constantly focus at the point choosen.
- (void)tapToContinouslyAutoFocus:(UIGestureRecognizer *)gestureRecognizer
{
    if ([[[captureManager videoInput] device] isFocusPointOfInterestSupported])
        [captureManager continuousFocusAtPoint:CGPointMake(.5f, .5f)];
}

// Update button states based on the number of available cameras and mics
- (void)updateButtonStates
{
//	NSUInteger cameraCount = [[self captureManager] cameraCount];
//	NSUInteger micCount = [[self captureManager] micCount];
//    
//    CFRunLoopPerformBlock(CFRunLoopGetMain(), kCFRunLoopCommonModes, ^(void) {
//        if (cameraCount < 2) {
//            [[self cameraToggleButton] setEnabled:NO];
//            
//            if (cameraCount < 1) {
//                [[self stillButton] setEnabled:NO];
//                
//            } else {
//                [[self stillButton] setEnabled:YES];
//            }
//        } else {
//            [[self cameraToggleButton] setEnabled:YES];
//            [[self stillButton] setEnabled:YES];
//        }
//    });
}

@end
//=================================================================================

@implementation MainViewController (AVCamCaptureManagerDelegate)

- (void)captureManager:(AVCamCaptureManager *)captureManager didFailWithError:(NSError *)error
{
    CFRunLoopPerformBlock(CFRunLoopGetMain(), kCFRunLoopCommonModes, ^(void) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[error localizedDescription]
                                                            message:[error localizedFailureReason]
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"OK", @"OK button title")
                                                  otherButtonTitles:nil];
        [alertView show];
        //        [alertView release];
    });
}

- (void)captureManagerStillImageCaptured:(AVCamCaptureManager *)captureManager
{
//    self.image = [captureManager image];
    [self showOptions:YES animated:YES];
    
    self.imageView.image = [captureManager image];
    
    self.image = [self okImage];
    
    CFRunLoopPerformBlock(CFRunLoopGetMain(), kCFRunLoopCommonModes, ^(void) {
        
    });
//    [[[self captureManager] session] stopRunning];
    
}

- (void)captureManagerDeviceConfigurationChanged:(AVCamCaptureManager *)captureManager
{
	[self updateButtonStates];
}


- (void)usePhoto{
    NSLog(@"use Photo");
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSFileManager *filemgr = [NSFileManager defaultManager];
    NSArray *filelist = [filemgr contentsOfDirectoryAtPath:documentsDirectory error:nil];
    
    //if ([mediaType isEqualToString:(NSString *)kUTTypeImage])
    {
        UIImage *image = [self okImage];    //[info   objectForKey:UIImagePickerControllerOriginalImage];
//        UIGraphicsBeginImageContext(CGSizeMake(242,324));
//        
//        CGContextRef            context = UIGraphicsGetCurrentContext();
//        
//        [image drawInRect: CGRectMake(0, 0, 242, 324 )];
//        
//        UIImage        *smallImage = UIGraphicsGetImageFromCurrentImageContext();
//        
//        UIGraphicsEndImageContext();
        CLLocationManager *manager1 = [[CLLocationManager alloc] init];
        [manager1 startUpdatingLocation];
        location=manager1.location;
        NSError *error;
        // NSLog(@"%f  %f",location.coordinate.latitude,location.coordinate.longitude);
        NSLog(@"loc=%@",location);
        NSData *imageData = UIImagePNGRepresentation(image);
        NSMutableDictionary *newMetadata = [NSMutableDictionary dictionary];
        
        //The photo object has @property location
        CLLocationDegrees exifLatitude  = self.location.coordinate.latitude;
        CLLocationDegrees exifLongitude = self.location.coordinate.longitude;
        
        NSString *latRef;
        NSString *lngRef;
        if (exifLatitude < 0.0) {
            exifLatitude = exifLatitude * -1.0f;
            latRef = @"S";
        } else {
            latRef = @"N";
        }
        
        if (exifLongitude < 0.0) {
            exifLongitude = exifLongitude * -1.0f;
            lngRef = @"W";
        } else {
            lngRef = @"E";
        }

        NSMutableDictionary *GPSMetadata = [[NSMutableDictionary alloc] init];
        NSMutableDictionary *exifData = [[NSMutableDictionary alloc] init];
        [GPSMetadata setObject:[NSNumber numberWithFloat:exifLatitude] forKey:(NSString*)kCGImagePropertyGPSLatitude];
        [GPSMetadata setObject:[NSNumber numberWithFloat:exifLongitude] forKey:(NSString*)kCGImagePropertyGPSLongitude];
        [GPSMetadata setObject:latRef forKey:(NSString*)kCGImagePropertyGPSLatitudeRef];
        [GPSMetadata setObject:lngRef forKey:(NSString*)kCGImagePropertyGPSLongitudeRef];
        [GPSMetadata setObject:[NSDate new] forKey:(NSString*)kCGImagePropertyGPSTimeStamp];
        [GPSMetadata setObject:[NSNumber numberWithFloat:self.location.horizontalAccuracy] forKey:(NSString*)kCGImagePropertyGPSDOP];
        [GPSMetadata setObject:[NSNumber numberWithFloat:self.location.altitude] forKey:(NSString*)kCGImagePropertyGPSAltitude];
        NSDateFormatter *exifDateFormatter = [[NSDateFormatter alloc]init];
        
        [exifDateFormatter setDateFormat:@"yyyy:MM:dd HH:mm:ss"];
        [exifData setObject:[exifDateFormatter stringFromDate:[NSDate new]] forKey:(NSString *)kCGImagePropertyExifDateTimeOriginal];
        
        [newMetadata setObject:GPSMetadata forKey:(NSString *)kCGImagePropertyGPSDictionary];
        [newMetadata setObject:exifData forKey:(NSString *)kCGImagePropertyExifDictionary];
        ALAssetsLibraryWriteImageCompletionBlock imageWriteCompletionBlock =
        ^(NSURL *newURL, NSError *error) {
            
                UIAlertView *alert;
                if(error){
                    alert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"Cannot save photo" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                }
                else{
                    alert = [[UIAlertView alloc]initWithTitle:@"Success" message:@"Photo has been saved to Camera Roll" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                    //result Block
                }
                [alert show];
            
        };
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc]init];
        //I print out the new metadata here, everything is fine
        NSLog(@"%@", newMetadata.description);
        [library writeImageToSavedPhotosAlbum:[image CGImage] metadata:newMetadata completionBlock:imageWriteCompletionBlock];
//        [library writeImageDataToSavedPhotosAlbum:imageData metadata:metadata completionBlock:^(NSURL *assetURL, NSError *error){
//            if (error) {
//                // TODO: error handling
//            } else {
//                // TODO: success handling
//            }
//        }];
        NSLog(@"metadata=%@",newMetadata);
        NSMutableData *dest_data = [NSMutableData data];
        CGImageSourceRef  source = CGImageSourceCreateWithData((__bridge CFDataRef)imageData, NULL);
        if (!source)
        {
            NSLog(@"***Could not create image source ***");
        }
        CFStringRef UTI = CGImageSourceGetType(source);
        CGImageDestinationRef destination = CGImageDestinationCreateWithData((__bridge CFMutableDataRef)dest_data,UTI,1,NULL);
        if(!destination) {
            NSLog(@"***Could not create image destination ***");
        }
        CGImageDestinationAddImageFromSource(destination,source,0, (__bridge CFDictionaryRef) newMetadata);
        BOOL success = NO;
        success = CGImageDestinationFinalize(destination);
        if(!success) {
            NSLog(@"***Could not create data from image destination ***");
        }
        [self.library saveImage:image toAlbum:@"Test" metadata:newMetadata withCompletionBlock:^(NSError *error) {         if (error!=nil)          {             NSLog(@"Big error: %@", [error description]);         }     }];
        if(self.imageSaved == self.image){
//            int indx = ([filelist count])/2;
//            if(indx == 6)
//                indx = 1;
            NSString *d = [NSString stringWithFormat:@"imageName%i.png",currentSavedIndx];
            NSString *path = [documentsDirectory stringByAppendingPathComponent: d];
            [imageData writeToFile:path options:NSDataWritingAtomic error:&error];
        }
        else{
            NSString *fname;
            NSString *path;
            int indx = ([filelist count])/2;
            if(indx < 6){
                fname = [NSString stringWithFormat:@"imageName%i.png",(indx + 1)];
                path = [documentsDirectory stringByAppendingPathComponent:fname];
                [imageData writeToFile:path options:NSDataWritingAtomic error:&error];
                currentSavedIndx = indx+1;
            }
            else{
                currentSavedIndx = 1;
                for(int i = 5; i > 0; i--){
                    NSString * pathF1 = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"imageName%i.png", i]];
                    
                    NSString * pathF2 = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"imageName%i.png", (i + 1)]];
                    
                    UIImage *tempimg = [UIImage imageWithContentsOfFile:pathF1];
                    NSData *imageDataT = UIImagePNGRepresentation(tempimg);
                    [imageDataT writeToFile:pathF2 atomically:YES];
                    
                    if(i == 1)
                        [imageData writeToFile:pathF1 options:NSDataWritingAtomic error:&error];
                }
            }
        }
        [self performSelectorInBackground:@selector(savedata) withObject:nil];
    }
    self.imageSaved = self.image;
}
-(void)savedata{
    
    CLLocationManager *manager1 = [[CLLocationManager alloc] init];
    [manager1 startUpdatingLocation];
    location = manager1.location;
    NSLog(@"SAVE DATA LOC %@",location);
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSFileManager *filemgr = [NSFileManager defaultManager];
    NSArray *filelist = [filemgr contentsOfDirectoryAtPath:documentsDirectory error:nil];
    
    int indx = ([filelist count])/2;
    if(indx < 6){
        NSString *fname = [NSString stringWithFormat:@"photo%i.plist",(indx + 1)];
        NSString *path = [documentsDirectory stringByAppendingPathComponent:fname];
        location = manager1.location;
        NSString *str1 = [[NSString alloc] initWithFormat:@"%f",location.coordinate.latitude];
        NSString *str2 = [[NSString alloc] initWithFormat:@"%f",location.coordinate.longitude];
        NSArray *locdata = [[NSArray alloc] initWithObjects:str1,str2, nil];
        [locdata writeToFile:path atomically:YES];
    }
    else{
        NSString *path1 = [documentsDirectory stringByAppendingPathComponent:@"photo1.plist"];
        NSString *path2 = [documentsDirectory stringByAppendingPathComponent:@"photo2.plist"];
        NSString *path3 = [documentsDirectory stringByAppendingPathComponent:@"photo3.plist"];
        NSString *path4 = [documentsDirectory stringByAppendingPathComponent:@"photo4.plist"];
        NSString *path5 = [documentsDirectory stringByAppendingPathComponent:@"photo5.plist"];
        NSString *path6 = [documentsDirectory stringByAppendingPathComponent:@"photo6.plist"];
            location = manager1.location;
        NSString *str1 = [[NSString alloc] initWithFormat:@"%f",location.coordinate.latitude];
        NSString *str2 = [[NSString alloc] initWithFormat:@"%f",location.coordinate.longitude];
            NSArray *locdata = [[NSArray alloc] initWithObjects:str1,str2, nil];
            NSArray *TArray = [NSArray arrayWithContentsOfFile:path5];
            [TArray writeToFile:path6 atomically:YES];
            TArray = [NSArray arrayWithContentsOfFile:path4];
            [TArray writeToFile:path5 atomically:YES];
            TArray = [NSArray arrayWithContentsOfFile:path3];
            [TArray writeToFile:path4 atomically:YES];
            TArray = [NSArray arrayWithContentsOfFile:path2];
            [TArray writeToFile:path3 atomically:YES];
            TArray = [NSArray arrayWithContentsOfFile:path1];
            [TArray writeToFile:path2 atomically:YES];
            [locdata writeToFile:path1 atomically:YES];
    }
}
- (UIImage*) okImage {
    CGRect rect = [[UIScreen mainScreen] bounds];
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [self.photoView.layer renderInContext:context];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}
- (UIImage*) normalizedImage:(UIImage*)image {
    
	CGImageRef          imgRef = image.CGImage;
	CGFloat             width = imageView.bounds.size.width;
//        CGImageGetWidth(imgRef);
	CGFloat             height = imageView.bounds.size.height;
//        CGImageGetHeight(imgRef);
	NSLog(@"image view = %f %f", width, height);
    NSLog(@"image = %f %f", image.size.width,image.size.height);
    
    CGAffineTransform   transform = CGAffineTransformIdentity;

	CGRect              bounds = CGRectMake(0, 0, width, height);
    
    CGSize              imageSize = bounds.size;
	CGFloat             boundHeight;
    UIImageOrientation  orient = image.imageOrientation;
    
	switch (orient) {
		case UIImageOrientationUp: //EXIF = 1
			transform = CGAffineTransformIdentity;
			break;
            
		case UIImageOrientationDown: //EXIF = 3
			transform = CGAffineTransformMakeTranslation(imageSize.width, imageSize.height);
			transform = CGAffineTransformRotate(transform, M_PI);
			break;
            
		case UIImageOrientationLeft: //EXIF = 6
			boundHeight = bounds.size.height;
			bounds.size.height = bounds.size.width;
			bounds.size.width = boundHeight;
			transform = CGAffineTransformMakeTranslation(imageSize.height, imageSize.width);
			transform = CGAffineTransformScale(transform, -1.0, 1.0);
			transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
			break;
            
		case UIImageOrientationRight: //EXIF = 8
			boundHeight = bounds.size.height;
			bounds.size.height = bounds.size.width;
			bounds.size.width = boundHeight;
			transform = CGAffineTransformMakeTranslation(0.0, imageSize.width);
			transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
			break;
            
		default:
            // image is not auto-rotated by the photo picker, so whatever the user
            // sees is what they expect to get. No modification necessary
            transform = CGAffineTransformIdentity;
            break;
	}
    UIGraphicsBeginImageContext(bounds.size);
	CGContextRef context = UIGraphicsGetCurrentContext();
    
    if ((image.imageOrientation == UIImageOrientationDown) ||
        (image.imageOrientation == UIImageOrientationRight) ||
        (image.imageOrientation == UIImageOrientationUp)) {
        // flip the coordinate space upside down
        CGContextScaleCTM(context, 1, -1);
        CGContextTranslateCTM(context, 0, -height);
    }
    
	CGContextConcatCTM(context, transform);
	CGContextDrawImage(UIGraphicsGetCurrentContext(), bounds, imgRef);
	UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
    
	return imageCopy;
}


- (IBAction)ASelectPlace:(id)sender {
//    SelectPlacesViewController *viewController  = [[SelectPlacesViewController alloc] initWithNibName:@"SelectPlacesViewController" bundle:nil];
    
    
//    [self.navigationController pushViewController:viewController animated:YES];
    
    FQViewController *viewController1 = [[FQViewController alloc] initWithNibName:@"FQViewController" bundle:nil];
    PPViewController *viewController2 = [[PPViewController alloc] initWithNibName:@"PPViewController" bundle:nil];
    self.tabBarController = [[UITabBarController alloc] init];
    self.tabBarController.viewControllers = @[viewController1, viewController2];
    self.tabBarController.view.frame = CGRectMake(-self.imageView.frame.size.width, 0, self.imageView.frame.size.width-self.mainView.frame.size.width*0.1, self.imageView.frame.size.height);
    [self.view addSubview:self.tabBarController.view];
    
    [UIView animateWithDuration:.4f
                     animations:^{
                        self.tabBarController.view.frame = CGRectMake(0, 0, self.imageView.frame.size.width-self.mainView.frame.size.width*0.1, self.imageView.frame.size.height);
//                         self.view.frame = CGRectMake(self.mainView.frame.size.width - self.mainView.frame.size.width*0.1, 0, self.mainView.frame.size.width, self.mainView.frame.size.height);
                    }
                     completion:^(BOOL finished){
                         
                     }
     ];
    UIButton* backB = [[UIButton alloc] initWithFrame:CGRectMake(self.mainView.frame.size.width-self.mainView.frame.size.width*0.1, self.mainView.frame.origin.y, self.mainView.frame.size.width, self.mainView.frame.size.height)];
//    [backB setImage:[UIImage imageNamed:@"icon114"] forState:UIControlStateNormal];
    
    [backB addTarget:self action:@selector(backClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backB];
    
    viewController1.confirmCallback = ^(id sender, NSString* place) {
        self.placeName = place;
         [self animateMain];
        [UIView animateWithDuration:.4f
                         animations:^{
                             self.tabBarController.view.frame = CGRectMake(-self.mainView.frame.size.width, self.mainView.frame.origin.y, self.mainView.frame.size.width, self.mainView.frame.size.height);
                            
                         }
                         completion:^(BOOL finished){
                             [self.tabBarController.view removeFromSuperview];
                             [self updateInfo];
                         }
         ];
        
    };
    
    viewController2.confirmCallback = ^(id sender, NSString* place) {
        self.placeName = place;
        [self animateMain];
        [UIView animateWithDuration:.4f
                         animations:^{
                             self.tabBarController.view.frame = CGRectMake(-self.mainView.frame.size.width, self.mainView.frame.origin.y, self.mainView.frame.size.width, self.mainView.frame.size.height);
                             
                         }
                         completion:^(BOOL finished){
                             [self.tabBarController.view removeFromSuperview];
                             [self updateInfo];
                         }
         ];
    };
    
    NSLog(@"selecting PLACE");
}
-(IBAction)backClick:(UIButton *)sender{
    NSLog(@"sss");
    [UIView animateWithDuration:.4f
                     animations:^{
//                         self.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
                         
                         self.tabBarController.view.frame = CGRectMake(-self.mainView.frame.size.width, self.mainView.frame.origin.y, self.mainView.frame.size.width, self.mainView.frame.size.height);
                         
                     }
                     completion:^(BOOL finished){
                         [self.tabBarController removeFromParentViewController];
                         [sender removeFromSuperview];
                     }
     ];
}
-(void) animateMain: (BOOL) toRight{
    if(toRight)
        [UIView animateWithDuration:.4f
                         animations:^{
                             self.view.frame = CGRectMake(self.imageView.frame.size.width - 20, 0, self.imageView.frame.size.width, self.imageView.frame.size.height);
                         }
                         completion:^(BOOL finished){
                             
                         }
         ];
    else
        [UIView animateWithDuration:.4f
                         animations:^{
                             self.view.frame = CGRectMake(20-self.imageView.frame.size.width, 0, self.imageView.frame.size.width, self.imageView.frame.size.height);
                         }
                         completion:^(BOOL finished){
                             
                         }
         ];
}
-(void) animateMain{
    [UIView animateWithDuration:.4f
                     animations:^{
                         self.view.frame = CGRectMake(0, 0, self.imageView.frame.size.width, self.imageView.frame.size.height);
                     }
                     completion:^(BOOL finished){
                         
                     }
     ];
}
//-(void)presentLoginSettings {
//    NSLog(@"FB Login settings");
//    if (self.settingsViewController == nil) {
//        self.settingsViewController = [[FBUserSettingsViewController alloc] init];
//        self.settingsViewController.delegate = self;
//    }
//    self.navigationController.navigationBarHidden = NO;
//    [self.navigationController pushViewController:self.settingsViewController animated:YES];
//}
- (IBAction)ATakePhoto:(id)sender {
    // Capture a still image
    [[self captureManager] captureStillImage];
    
    // Flash the screen white and fade it out to give UI feedback that a still image was taken
    UIView *flashView = [[UIView alloc] initWithFrame:[[self videoPreviewView] frame]];
    [flashView setBackgroundColor:[UIColor whiteColor]];
    [[[self view] window] addSubview:flashView];
    
    [UIView animateWithDuration:.4f
                     animations:^{
                         [flashView setAlpha:0.f];
                     }
                     completion:^(BOOL finished){
                         [flashView removeFromSuperview];
                         //                         [flashView release];
                     }
     ];
}
-(void) showOptions:(BOOL) state animated:(BOOL) animated{
    if(state){
        bottomImageView.image = [UIImage imageNamed:@"bottom4"];
    }
    else{
        bottomImageView.image = [UIImage imageNamed:@"bottom2"];
    }
    BNew.hidden = !state;
    BShare.hidden = !state;
    BPhotos.hidden = !state;
    
    BPlaces.hidden = state;
    BPhoto.hidden = state;
    BPhotosPick.hidden = state;
    
    NSUserDefaults *usersDefaults = [NSUserDefaults standardUserDefaults];
    [usersDefaults setBool:state forKey:@"Option"];
    
    if(state){
            self.imageView.hidden = NO;
        }
        else{
            self.imageView.hidden = YES;
        }
}
-(BOOL) startMediaBrowserFromViewController: (UIViewController*) controller usingDelegate: (id<UIImagePickerControllerDelegate, UINavigationControllerDelegate>) delegate{
    if(([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum] == NO) || delegate == nil || controller == nil)
        return NO;
    
    UIImagePickerController *mediaUI = [[UIImagePickerController alloc] init];
    mediaUI.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    mediaUI.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeSavedPhotosAlbum];
    mediaUI.allowsEditing = NO;
    mediaUI.delegate = delegate;
    [controller presentModalViewController:mediaUI animated:YES];
}
-(void)AOpenPhotosPicker:(id)sender{
    [self startMediaBrowserFromViewController:self usingDelegate:self];
}
- (IBAction)AOpenPhotos:(id)sender {
    self.navigationController.navigationBarHidden = NO;
    singlePhotoViewController = [[CollectionViewController alloc] initWithNibName:@"CollectionViewController" bundle:nil];
//    singlePhotoViewController.detailItem = 1;
//    singlePhotoViewController.hidesBottomBarWhenPushed=YES;
    [self.navigationController pushViewController:singlePhotoViewController animated:YES];
}

- (IBAction)ATakeNewPhoto:(id)sender {
    [self showOptions:NO animated:YES];
}

- (IBAction)ASharePhoto:(id)sender {
    
    [self usePhoto];
    [self dismissModalViewControllerAnimated:YES];
    
//    UIActionSheet *menu = [[UIActionSheet alloc] initWithTitle:@"Поделиться" delegate:self cancelButtonTitle:@"Отмена" destructiveButtonTitle:nil otherButtonTitles:@"Twitter" ,@"Facebook",@"E-mail", nil];
//    menu.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
//    [menu   showInView:self.view];
    
    NSArray *toShare = @[self.shareText, [self okImage]];
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:toShare applicationActivities:nil];
    activityVC.excludedActivityTypes = @[UIActivityTypePrint, UIActivityTypeSaveToCameraRoll, UIActivityTypeCopyToPasteboard, UIActivityTypeAssignToContact];
    
    [self presentViewController:activityVC animated:YES completion:^{
        
    }];
}
- (IBAction)AInfo:(id)sender {
    self.topImageView.image = [UIImage imageNamed:@"top2"];
    self.VInfo.backgroundColor = [UIColor colorWithWhite:0.5f alpha:0.5f];
    [self.view addSubview:self.VInfo];
}

- (IBAction)AInfoClose:(id)sender {
    self.topImageView.image = [UIImage imageNamed:@"top1"];
    [self.VInfo removeFromSuperview];
}
#pragma mark - imagePickerDelegate methods
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    NSString* mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    if(CFStringCompare((CFStringRef) mediaType, kUTTypeImage, 0) == kCFCompareEqualTo){
        self.imageView.image = (UIImage*)[ info objectForKey:UIImagePickerControllerOriginalImage];
        
        self.image = [self okImage];
        //        location = [[info objectForKey:UIImagePickerControllerOriginalImage] location];
    }
    NSURL *referenceURL = [info objectForKey:UIImagePickerControllerReferenceURL];
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    [library assetForURL:referenceURL resultBlock:^(ALAsset *asset) {
        ALAssetRepresentation *rep = [asset defaultRepresentation];
        NSDictionary *metadata = rep.metadata;
        NSLog(@"%i",[[metadata objectForKey:(NSString *)kCGImagePropertyGPSDictionary] count]);
        if ([[metadata objectForKey:(NSString *)kCGImagePropertyGPSDictionary]count]>0) {
            NSLog(@"11%@", [metadata objectForKey:(NSString *)kCGImagePropertyGPSDictionary]);}
        else{
            NSLog(@"FUCK YOu");
        }
        
        CGImageRef iref = [rep fullScreenImage] ;
        
        if (iref) {
            self.imageView.image = [UIImage imageWithCGImage:iref];
        }
    } failureBlock:^(NSError *error) {
        // error handling
    }];   [self dismissModalViewControllerAnimated:YES];
    [self showOptions:YES animated:YES];
}
#pragma mark - CLLocationManagerDelegate methods and related

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation {
    if (!oldLocation ||
        (oldLocation.coordinate.latitude != newLocation.coordinate.latitude &&
         oldLocation.coordinate.longitude != newLocation.coordinate.longitude &&
         newLocation.horizontalAccuracy <= 100.0)) {
            // Fetch data at this new location, and remember the cache descriptor.
            [self setPlaceCacheDescriptorForCoordinates:newLocation.coordinate];
            [self.placeCacheDescriptor prefetchAndCacheForSession:FBSession.activeSession];
        }
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error {
	NSLog(@"%@", error);
}

- (void)setPlaceCacheDescriptorForCoordinates:(CLLocationCoordinate2D)coordinates {
    self.placeCacheDescriptor =
    [FBPlacePickerViewController cacheDescriptorWithLocationCoordinate:coordinates
                                                        radiusInMeters:1500
                                                            searchText:@""
                                                          resultsLimit:50
                                                      fieldsForRequest:nil];
    
}
#pragma mark - FBUserSettingsDelegate methods
- (void)loginViewControllerDidLogUserOut:(id)sender {
    // Facebook SDK * login flow *
    // There are many ways to implement the Facebook login flow.
    // In this sample, the FBLoginView delegate (SCLoginViewController)
    // will already handle logging out so this method is a no-op.
}

- (void)loginViewController:(id)sender receivedError:(NSError *)error{
    // Facebook SDK * login flow *
    // There are many ways to implement the Facebook login flow.
    // In this sample, the FBUserSettingsViewController is only presented
    // as a log out option after the user has been authenticated, so
    // no real errors should occur. If the FBUserSettingsViewController
    // had been the entry point to the app, then this error handler should
    // be as rigorous as the FBLoginView delegate (SCLoginViewController)
    // in order to handle login errors.
    if (error) {
        NSLog(@"Unexpected error sent to the FBUserSettingsViewController delegate: %@", error);
    }
}

-(void)openSession{
    [FBSession openActiveSessionWithReadPermissions:nil allowLoginUI:YES completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
        [self sessionStateChanged:session state:status error:error];
    }];
}
-(void) sessionStateChanged:(FBSession*) session
                      state:(FBSessionState) state
                      error: (NSError*) error{
    
    switch (state) {
        case FBSessionStateOpen:{
            NSLog(@"Session start");
        }
            break;
        case FBSessionStateClosed:
        case FBSessionStateClosedLoginFailed:{
            NSLog(@"Session closed login failed");
            
            [FBSession.activeSession closeAndClearTokenInformation];
        }
            break;
        default:
            break;
    }
    
    if(error){
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alertView show];
    }
}

@end

