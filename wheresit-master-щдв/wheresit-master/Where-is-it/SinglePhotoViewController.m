//
//  SinglePhotoViewController.m
//  Where-is-it
//
//  Created by Mac on 30.07.13.
//  Copyright (c) 2013 IT-insign. All rights reserved.
//

#import "SinglePhotoViewController.h"
#import "MapKit/MapKit.h"
#import "MapViewAnnotation.h"
#import "CoreLocation/CoreLocation.h"
#import <QuartzCore/QuartzCore.h>
#import "AppDelegate.h"
#import <AddressBook/AddressBook.h>


#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

@interface SinglePhotoViewController (){
@private AppDelegate* appDel;
@private UIButton *infobutton;
    NSString *latitude;
    NSString *longitude;
}

@property (strong, nonatomic) NSObject<FBGraphPlace> *selectedPlace;
@property (strong, nonatomic) NSObject<FBGraphLocation> *selectedLocation;

@property (unsafe_unretained, nonatomic) IBOutlet FBLoginView *FBLoginView;
@property (strong, nonatomic) IBOutlet FBProfilePictureView *userProfileImage;

@property (strong, nonatomic) IBOutlet UILabel *userNameLabel;
@property (strong, nonatomic) IBOutlet NSArray *selectedFriends;
@property (strong, nonatomic) UIImage *selectedPhoto;
@property (strong, nonatomic) NSString *message;

@property (strong, nonatomic) FBCacheDescriptor *placeCacheDescriptor;
@property (strong, nonatomic) CLLocationManager *locationManager;

@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;
@end

@implementation SinglePhotoViewController

@synthesize mapView;
@synthesize but2,but3,inf,manager,detailItem,scroll;
@synthesize popupvc, popoverView;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(void)viewWillAppear:(BOOL)animated{

    if (FBSession.activeSession.isOpen) {
        NSLog(@"session is OPENEd will appear");
        [self populateUserDetails];
        self.userProfileImage.hidden = NO;
    } else {
        self.userProfileImage.hidden = YES;
    }
}
- (void)populateUserDetails {
    if (FBSession.activeSession.isOpen) {
        [[FBRequest requestForMe] startWithCompletionHandler:
         ^(FBRequestConnection *connection, NSDictionary<FBGraphUser> *user, NSError *error) {
             if (!error) {
                 self.userNameLabel.text = user.name;
                 self.userProfileImage.profileID = [user objectForKey:@"id"];
             }
         }];
    }
}
- (void) viewDidAppear:(BOOL)animated {
    if (FBSession.activeSession.isOpen) {
        [self.locationManager startUpdatingLocation];
    }
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    FBCacheDescriptor *cacheDescriptor = [FBFriendPickerViewController cacheDescriptor];
    [cacheDescriptor prefetchAndCacheForSession:FBSession.activeSession];
    
    appDel = (AppDelegate*)[UIApplication sharedApplication].delegate;
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    // We don't want to be notified of small changes in location, preferring to use our
    // last cached results, if any.
    self.locationManager.distanceFilter = 50;
   
    
    l=0;
    CGRect screenBound = [[UIScreen mainScreen] bounds];
    CGSize screenSize = screenBound.size;
    CGFloat screenWidth = screenSize.width;
    CGFloat screenHeight = screenSize.height;
//    NSLog(@"screenSize %f %f",screenHeight,screenWidth);
    if (screenHeight==568) {
//        menu.frame=CGRectMake(0,screenHeight-117,screenWidth, 54);
        but2.frame=CGRectMake(0,screenHeight-115,screenWidth/2,50);
        but3.frame=CGRectMake(screenWidth/2, screenHeight-115, screenWidth/2, 50);
        scroll.frame=CGRectMake(0,0,320, 369);
        mapView.frame=CGRectMake(0,0,320, 369);
    }
    self.view.backgroundColor=[UIColor yellowColor];
    lab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    lab2 = [[UILabel alloc] initWithFrame:CGRectMake(0, 100, 320, 140)];
    lab1 =[[UILabel alloc]initWithFrame:CGRectMake(50, 0, 220, 100)];
    lab2.backgroundColor = [[UIColor alloc] initWithRed:0 green:0 blue:0 alpha:0];
    lab1.backgroundColor = [[UIColor alloc] initWithRed:0 green:0 blue:0 alpha:0];
    lab.backgroundColor = [[UIColor alloc] initWithRed:0 green:0 blue:0 alpha:0.5];
    lab2.hidden=YES;
    lab1.hidden=YES;
    lab.hidden=YES;
     infobutton = [UIButton buttonWithType:UIButtonTypeInfoDark];
    [infobutton addTarget:self action:@selector(infopressed) forControlEvents:UIControlEventTouchUpInside];
    inf = [[UIBarButtonItem alloc] initWithCustomView:infobutton];
    self.navigationItem.rightBarButtonItem = inf;
    self.navigationItem.title=@"Where is it?";
    [[UINavigationBar appearance] setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [UIColor blackColor],UITextAttributeTextColor,
      nil]];
    mapView.hidden = YES;
    [lab2 setNumberOfLines:6];
    [self performSelectorInBackground:@selector(scrollload) withObject:nil];
    [self.view addSubview:scroll];
    NSString *language = [[NSLocale currentLocale] localeIdentifier];
    if (![language isEqualToString:@"ru_RU"]) {
        [but2 setImage:[UIImage imageNamed:@"4.png"] forState:UIControlStateNormal];}
    mapView.hidden=YES;
    [mapView setMapType:MKMapTypeHybrid];
    mapView.showsUserLocation = YES;
    [self.view addSubview:mapView];
    [self.view addSubview:lab];
    [self.view addSubview:lab2];
    [self.view addSubview:lab1];
    lab2.textColor=[UIColor whiteColor];
    lab1.textColor=[UIColor whiteColor];
    lab2.textAlignment=UITextAlignmentCenter;
    lab1.textAlignment=UITextAlignmentCenter;
    [lab2 setFont:[UIFont systemFontOfSize:18]];
    [lab1 setFont:[UIFont systemFontOfSize:24]];
    [lab2 setNumberOfLines:6];
    [lab1 setNumberOfLines:4];
    
    if ([language isEqualToString:@"ru_RU"]) {
        lab1.text=@"Узнаете?\nВаш предмет\nздесь!";
        lab2.text=@"Нажмите компас чтобы\nпосмотреть место на карте";}
    else {lab1.text=@"Recognazing?\nYour thing is here!";
        lab2.text=@"Click a compass to find this place on the map";}
    
    popupvc = [[UIViewController alloc] init];
    self.popoverView.layer.cornerRadius = 5;
    self.popoverView.layer.borderWidth = 1.5f;
    self.popoverView.layer.masksToBounds = YES;
    
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.activityIndicator.hidesWhenStopped = YES;
    [self.view addSubview:self.activityIndicator];
    
    
    
}

- (void)longPressHandler:(UILongPressGestureRecognizer*)recognizer
{
	if( recognizer.state == UIGestureRecognizerStateBegan )
	{
        /*
         self.popupvc.modalPresentationStyle = UIModalPresentationFormSheet;
         self.popupvc.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
         [self presentModalViewController:self.popupvc animated:YES];
         self.popupvc.view.superview.frame = CGRectMake(0, 0, 540, 620);
         self.popupvc.view.superview.center = self.view.center;
         
         [self.popupvc.view addSubview:popoverView];
         */
        [self.view addSubview:popoverView];
        popoverView.frame = CGRectMake(self.view.center.x - popoverView.frame.size.width/2, self.view.center.y - popoverView.frame.size.height/2, self.popoverView.frame.size.width, self.popoverView.frame.size.height);
    }
}

- (void)TapHandler:(UITapGestureRecognizer*)recognizer
{
    [self hidePopOver];
}
-(void) hidePopOver{
    [popoverView removeFromSuperview];
}
-(void)scrollload{
    CGRect screenBound = [[UIScreen mainScreen] bounds];
    CGSize screenSize = screenBound.size;
    CGFloat screenWidth = screenSize.width;
    CGFloat screenHeight = screenSize.height;
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSFileManager *filemgr = [NSFileManager defaultManager];
    NSArray *filelist = [filemgr contentsOfDirectoryAtPath:documentsDirectory error:nil];
    scroll.pagingEnabled = YES;
    NSInteger numberOfViews = [filelist count]/2;
    
//    for(NSString* s in filelist)
//        NSLog(@"%@", s);
    
    for (int i = 0; i < numberOfViews; i++) {
        CGFloat xOrigin = i * 320;
        NSString *pathstr = [NSString stringWithFormat:@"imageName%i.png",i+1];
        NSString *path = [documentsDirectory stringByAppendingPathComponent:pathstr];
        UIImageView *imView = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:path]];
        [imView setFrame:CGRectMake(320*i,-44, 320, self.view.frame.size.height )];
        [scroll addSubview:imView];
    }
    scroll.contentSize = CGSizeMake(320 * (numberOfViews), 350);
    scroll.showsHorizontalScrollIndicator = NO;
    scroll.showsVerticalScrollIndicator = NO;
    
    [scroll setContentOffset:CGPointMake(320*(detailItem), 0)];
    UILongPressGestureRecognizer *recognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressHandler:)];
    [scroll addGestureRecognizer:recognizer];
    UITapGestureRecognizer *taprecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(TapHandler:)];
    [scroll addGestureRecognizer:taprecognizer];
    scroll.delegate = self;
    
    pageControl.numberOfPages = numberOfViews;
    pageControl.currentPage = self.detailItem;
    
     [self refreshCurrentDetails];
    
    
}
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    int page = scroll.contentOffset.x/scrollView.frame.size.width;
    pageControl.currentPage = page;
    [self refreshCurrentDetails];
}

//обновить данные о выбранном фото и координатах
-(void) refreshCurrentDetails{
    int i = (int)(scroll.contentOffset.x/320);
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *pathstr = [NSString stringWithFormat:@"photo%i.plist",i+1];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:pathstr];
    NSArray *arr = [[NSArray alloc] initWithContentsOfFile:path];
    latitude = [[NSString alloc] initWithFormat:@"%@",[arr objectAtIndex:0]];
    longitude = [[NSString alloc]initWithFormat:@"%@",[arr objectAtIndex:1]];
    
    i = (int)(scroll.contentOffset.x/320);
    int j = 0;
    for(UIImageView* im in [scroll subviews]){
        if(i == j)
            self.selectedPhoto = im.image;
        j++;
    }
}

-(void)infopressed{
    if (l==0){
        lab2.hidden=NO;
        lab1.hidden=NO;
        lab.hidden=NO;
        l=1;
    }
    else{
        lab2.hidden=YES;
        lab1.hidden=YES;
        lab.hidden=YES;
        l=0;
    }
    
}


-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status{
}

- (IBAction)shareFB:(id)sender {
    if (FBSession.activeSession.isOpen){
        NSLog(@"active session is open");
    }
    [self hidePopOver];
    [self openFriendsList];
}
-(IBAction)selectPlace:(id)sender;{
    [self selectPlace];
}
-(void) openFriendsList{
    if (FBSession.activeSession.isOpen) {
        FBFriendPickerViewController *friendPicker = [[FBFriendPickerViewController alloc] init];
        
        // Set up the friend picker to sort and display names the same way as the
        // iOS Address Book does.
        
        // Need to call ABAddressBookCreate in order for the next two calls to do anything.
        ABAddressBookRef addressBook = ABAddressBookCreate();
        ABPersonSortOrdering sortOrdering = ABPersonGetSortOrdering();
        ABPersonCompositeNameFormat nameFormat = ABPersonGetCompositeNameFormat();
        
        friendPicker.sortOrdering = (sortOrdering == kABPersonSortByFirstName) ? FBFriendSortByFirstName : FBFriendSortByLastName;
        friendPicker.displayOrdering = (nameFormat == kABPersonCompositeNameFormatFirstNameFirst) ? FBFriendDisplayByFirstName : FBFriendDisplayByLastName;
        
        friendPicker.title = @"Выберите друзей";

        [friendPicker loadData];
        [friendPicker presentModallyFromViewController:self
                                              animated:YES
                                               handler:^(FBViewController *sender, BOOL donePressed) {
                                                   if (donePressed) {
                                                       NSLog(@"done");
                                                       self.selectedFriends = friendPicker.selection;
//                                                       if([self.selectedFriends count] > 0)
                                                           [self EnterMessage];
//                                                       else
//                                                           NSLog(@"empty selections");
                                                   }
                                               }];
        CFRelease(addressBook);
    } else {
        [appDel presentLoginSettings];
    }
}

-(void) selectPlace{
    if (FBSession.activeSession.isOpen) {
        FBPlacePickerViewController *placePicker = [[FBPlacePickerViewController alloc] init];
        
        placePicker.title = @"Select a place";
        
        // SIMULATOR BUG:
        // See http://stackoverflow.com/questions/7003155/error-server-did-not-accept-client-registration-68
        // at times the simulator fails to fetch a location; when that happens rather than fetch a
        // a meal near 0,0 -- let's see if we can find something good in Paris
        if (self.placeCacheDescriptor == nil) {
            [self setPlaceCacheDescriptorForCoordinates:CLLocationCoordinate2DMake(48.857875, 2.294635)];
        }
        
        [placePicker configureUsingCachedDescriptor:self.placeCacheDescriptor];
        [placePicker loadData];
        [placePicker presentModallyFromViewController:self
                                             animated:YES
                                              handler:^(FBViewController *sender, BOOL donePressed) {
                                                  if (donePressed) {
                                                      self.selectedPlace = placePicker.selection;
                                                      NSLog(@"places selected %@",  self.selectedPlace.name);
                                                  }
                                              }];
    } else {
        // if not logged in, give the user the option to log in
        [appDel presentLoginSettings];
    }
    NSLog(@"selectiong PLACE");
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

-(void) EnterMessage{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Добавить описание?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alert textFieldAtIndex:0].autocapitalizationType = UITextAutocapitalizationTypeSentences;
    [alert show];
}
#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (!alertView.cancelButtonIndex == buttonIndex) {
        self.message = [alertView textFieldAtIndex:0].text;
        [self Post];
    }
}
- (void)Post {
    if (FBSession.activeSession.isOpen) {
        if ([FBSession.activeSession.permissions indexOfObject:@"publish_actions"] == NSNotFound) {
            NSLog(@"publish is NO");
            [self requestPermissionAndPost:@"publish_actions"];
        } else if ([FBSession.activeSession.permissions indexOfObject:@"publish_stream"] == NSNotFound) {
            NSLog(@"publish stream is NO");
            [self requestPermissionAndPost:@"publish_stream"];
        } else {
            [self postOpenGraphAction2];
        }
    } else {
        NSLog(@"session is NOT opened");
    }
}


// Helper method to request publish permissions and post.
- (void)requestPermissionAndPost:(NSString*) permis {
    NSLog(@"requestPermissionAndPost");
    [FBSession.activeSession requestNewPublishPermissions:[NSArray arrayWithObject:permis]
                                          defaultAudience:FBSessionDefaultAudienceFriends
                                        completionHandler:^(FBSession *session, NSError *error) {
                                            if (!error) {
                                                // Now have the permission
                                                [self postOpenGraphAction2];
                                            } else {
                                                if (error.fberrorCategory != FBErrorCategoryUserCancelled) {
                                                }
                                            }
                                        }];
}


- (void)enableUserInteraction:(BOOL) enabled {
    if (enabled) {
        [self.activityIndicator stopAnimating];
    } else {
        [self centerAndShowActivityIndicator];
    }
    
    self.navigationController.navigationBar.userInteractionEnabled = enabled;
    [self.view setUserInteractionEnabled:enabled];
}
- (void)centerAndShowActivityIndicator {
    CGRect frame = self.view.frame;
    CGPoint center = CGPointMake(CGRectGetMidX(frame), CGRectGetMidY(frame));
    self.activityIndicator.center = center;
    [self.activityIndicator startAnimating];
}
// Creates the Open Graph Action.
- (void)postOpenGraphAction2 {
    [self enableUserInteraction:NO];
    NSLog(@"postOpenGraphAction2");
    
    for(id<FBGraphUser> user in self.selectedFriends)
    {
        NSLog(@"USER %@ - %@", user.id, user.name);
    }
    //загрузка фото на сервер какой то
    FBRequestConnection *requestConnection = [[FBRequestConnection alloc] init];
    if (self.selectedPhoto) {
        self.selectedPhoto = [self normalizedImage:self.selectedPhoto];
        FBRequest *stagingRequest = [FBRequest requestForUploadStagingResourceWithImage:self.selectedPhoto];
        [requestConnection addRequest:stagingRequest
                    completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                        if (error) {
                            NSLog(@"error on requestForUploadStagingResourceWithImage");
                            [self enableUserInteraction:YES];
                        }
                    }
                       batchEntryName:@"stagedphoto"];
    }
    
    
    NSMutableDictionary<FBGraphObject> *action = [FBGraphObject graphObject];
    
    //выбранное место
    if (self.selectedPlace) {
//    [action setObject: self.selectedPlace forKey:@"place"];
    }
    //выбранные друзья
    if (self.selectedFriends.count > 0) {
        [action setObject:self.selectedFriends forKey:@"tags"];
    }
    
    //фото загрузили - берем ссылку на фото
    if (self.selectedPhoto) {
        action[@"image"] = @[ @{ @"url" : @"{result=stagedphoto:$.uri}", @"user_generated" : @"true" } ];
    }
    
    //делаем ссылку на гугл мап
    NSString* placename = @"Where is it";
    NSString* gmapurl = [NSString stringWithFormat:@"https://maps.google.com/maps?ll=%@,%@&q=%@,%@+(%@)",latitude,longitude,latitude,longitude,placename];
    //делаем объект
    //все что ниже закомменчено - не обязательно, так как того, что после закомменченного хватает
//        // Facebook SDK * Object API *
//        id object = [FBGraphObject openGraphObjectForPostWithType:
////                     @"tuyon_test:myplace"
//                     @"website"
//                title:placename
//                image:@"https://s-static.ak.fbcdn.net/images/devsite/attachment_blank.png"
//                url:nil
//                description:@"" ];
//    
//        FBRequest *createObject = [FBRequest requestForPostOpenGraphObject:object];
////            [FBRequest requestForPostWithGraphPath:@"me/objects/object" graphObject:object];
//        [requestConnection addRequest:createObject
//                    completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
//                        if (error) {
//                            NSLog(@"error on openGraphObjectForPostWithType");
//                            [self enableUserInteraction:YES];
//                        }
//                        else
//                            NSLog(@"createObject complete");
//                    }
//                       batchEntryName:@"createobject"];

    action[@"url"] = gmapurl;
    action[@"website"] = gmapurl;// @"{result=createobject:$.id}";
    action[@"message"] = self.message;
    action[@"caption"] = @"BLAtitle"; 
    action[@"title"] = @"BLAtitle"; //!no work
    action[@"name"] = @"BLAname";   //!no work
    
    //делаем действие
    // Create the request and post the action to the "me/fb_sample_scrumps:eat" path.
    FBRequest *actionRequest = [FBRequest requestForPostWithGraphPath://@"me/og.posts"
//                                @"me/tuyon_test:look"
                                @"me/tuyon_test:sharelink"
                                                          graphObject:action];
    [requestConnection addRequest:actionRequest
                completionHandler:^(FBRequestConnection *connection,
                                    id result,
                                    NSError *error) {
                    [self enableUserInteraction:YES];
                    if (!error) {
                        [[[UIAlertView alloc] initWithTitle:@"Result"
                                                    message:[NSString stringWithFormat:@"Posted Open Graph action, id: %@",
                                                             [result objectForKey:@"id"]]
                                                   delegate:nil
                                          cancelButtonTitle:@"Thanks!"
                                          otherButtonTitles:nil]
                         show];
                        
                    } else {
                        NSLog(@"error on requestForPostWithGraphPath %@", error.description);
                    }
                }];
    //стартуем
    [requestConnection start];
    
}

- (UIImage*) normalizedImage:(UIImage*)image {
	CGImageRef          imgRef = image.CGImage;
	CGFloat             width = CGImageGetWidth(imgRef);
	CGFloat             height = CGImageGetHeight(imgRef);
	CGAffineTransform   transform = CGAffineTransformIdentity;
    if(width < 480.0){
        height *= 480.0/width;
        width = 480.0;
    }
    
    if(height < 480.0){
        width *= 480.0/height;
        height = 480.0;
    }
    
	CGRect              bounds = CGRectMake(0, 0, width, height);
    CGSize              imageSize = bounds.size;
	CGFloat             boundHeight;
    UIImageOrientation  orient = image.imageOrientation;
    
    
    NSLog(@"SIZE W=%f H=%f", width, height);
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
	CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, width, height), imgRef);
	UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
    
	return imageCopy;
}

//==========================================================================================
-(void)usemaps2{
    [self hidePopOver];
    // imageView.hidden= YES;
    
    NSString *language = [[NSLocale currentLocale] localeIdentifier];
    if ([language isEqualToString:@"ru_RU"]) {
        lab2.text=@"Нажмите компас\nчтобы увидеть\nмаршрут";}
    else {lab2.text=@"Click a compass\nto see a route";}
    mapView.hidden=NO;

    mapView.showsUserLocation = YES;
    MKCoordinateRegion region;
    region.center = CLLocationCoordinate2DMake(latitude.floatValue, longitude.floatValue);
    MKCoordinateSpan span;
    span.longitudeDelta = 0.002;
    span.latitudeDelta = 0.002;
    region.span = span;
    [self.mapView setRegion:region animated:YES];;
    MapViewAnnotation *newAnnotation = [[MapViewAnnotation alloc] initWithTitle:@"I'm here" andCoordinate:CLLocationCoordinate2DMake(latitude.floatValue, longitude.floatValue)];
	[mapView addAnnotation:newAnnotation];;
}

-(void)route{
    [self hidePopOver];
    CLLocationManager *manager = [[CLLocationManager alloc] init];
    manager.delegate = self;
    manager.distanceFilter = kCLDistanceFilterNone;
    manager.desiredAccuracy = kCLLocationAccuracyBest;
    [manager startUpdatingLocation];

    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"6.0")) {
        NSString *stringURL = [NSString stringWithFormat:@"http://maps.apple.com/maps?saddr=%g,%g&daddr=%f,%f",manager.location.coordinate.latitude, manager.location.coordinate.longitude,latitude.floatValue,longitude.floatValue];
        NSURL *url = [NSURL URLWithString:stringURL];
        [[UIApplication sharedApplication] openURL:url];}
    else {NSString *stringURL = [NSString stringWithFormat:@"http://maps.google.com/maps?saddr=%g,%g&daddr=%f,%f",manager.location.coordinate.latitude, manager.location.coordinate.longitude,latitude.floatValue,longitude.floatValue];
        NSURL *url = [NSURL URLWithString:stringURL];
        [[UIApplication sharedApplication] openURL:url];}
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc{
    
}
- (void)viewDidUnload {
    [self setPopoverView:nil];
    pageControl = nil;
    [super viewDidUnload];
}

#pragma mark - FBLoginView delegate
-(void)loginViewShowingLoggedInUser:(FBLoginView *)loginView{
    NSLog(@"loginViewShowingLoggedInUser");
}

-(void)loginView:(FBLoginView *)loginView handleError:(NSError *)error{
    NSLog(@"loginView handleError");
    NSString *alertMessage, *alertTitle;
    
    // Facebook SDK * error handling *
    // Error handling is an important part of providing a good user experience.
    // Since this sample uses the FBLoginView, this delegate will respond to
    // login failures, or other failures that have closed the session (such
    // as a token becoming invalid). Please see the [- postOpenGraphAction:]
    // and [- requestPermissionAndPost] on `SCViewController` for further
    // error handling on other operations.
    
    if (error.fberrorShouldNotifyUser) {
        // If the SDK has a message for the user, surface it. This conveniently
        // handles cases like password change or iOS6 app slider state.
        alertTitle = @"Something Went Wrong";
        alertMessage = error.fberrorUserMessage;
    } else if (error.fberrorCategory == FBErrorCategoryAuthenticationReopenSession) {
        // It is important to handle session closures as mentioned. You can inspect
        // the error for more context but this sample generically notifies the user.
        alertTitle = @"Session Error";
        alertMessage = @"Your current session is no longer valid. Please log in again.";
    } else if (error.fberrorCategory == FBErrorCategoryUserCancelled) {
        // The user has cancelled a login. You can inspect the error
        // for more context. For this sample, we will simply ignore it.
        NSLog(@"user cancelled login");
    } else {
        // For simplicity, this sample treats other errors blindly, but you should
        // refer to https://developers.facebook.com/docs/technical-guides/iossdk/errors/ for more information.
        alertTitle  = @"Unknown Error";
        alertMessage = @"Error. Please try again later.";
        NSLog(@"Unexpected error:%@", error);
    }
    
    if (alertMessage) {
        [[[UIAlertView alloc] initWithTitle:alertTitle
                                    message:alertMessage
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
    }
}

- (void)loginViewShowingLoggedOutUser:(FBLoginView *)loginView {
    NSLog(@"loginViewShowingLoggedOutUser");    
    // Facebook SDK * login flow *
    // It is important to always handle session closure because it can happen
    // externally; for example, if the current session's access token becomes
    // invalid. For this sample, we simply pop back to the landing page.
    //    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    /*    if (appDelegate.isNavigating) {
     // The delay is for the edge case where a session is immediately closed after
     // logging in and our navigation controller is still animating a push.
     [self performSelector:@selector(logOut) withObject:nil afterDelay:.5];
     } else {
     [self logOut];
     }
     */
}@end
