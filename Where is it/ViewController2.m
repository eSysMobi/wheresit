//
//  ViewController2.m
//  Where is it
//
//  Created by Vladimir P. Starkov on 21.09.12.
//  Copyright (c) 2012 Vladimir P. Starkov. All rights reserved.
//

#import "ViewController2.h"
#import "MapKit/MapKit.h"
#import "MapViewAnnotation.h"
#import "CoreLocation/CoreLocation.h"


#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)
@interface ViewController2 ()
@end

@implementation ViewController2
@synthesize mapView;
@synthesize but2,but3,inf,manager,detailItem,scroll,menu;

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
    [super viewDidLoad];
    l=0;
    CGRect screenBound = [[UIScreen mainScreen] bounds];
    CGSize screenSize = screenBound.size;
    CGFloat screenWidth = screenSize.width;
    CGFloat screenHeight = screenSize.height;
    NSLog(@"%f%f",screenHeight,screenWidth);
    if (screenHeight==568) {
    menu.frame=CGRectMake(0,screenHeight-117,screenWidth, 54);
    but2.frame=CGRectMake(0,screenHeight-115,screenWidth/2,50);
    but3.frame=CGRectMake(screenWidth/2, screenHeight-115, screenWidth/2, 50);
        scroll.frame=CGRectMake(0,0,320, 369);
        mapView.frame=CGRectMake(0,0,320, 369);}
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
    UIButton *button = [UIButton buttonWithType:UIButtonTypeInfoDark];
    [button addTarget:self action:@selector(infopressed) forControlEvents:UIControlEventTouchUpInside];
    inf = [[UIBarButtonItem alloc] initWithCustomView:button];
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
    for (int i = 1; i < numberOfViews+1; i++) {
        CGFloat xOrigin = (i-1) * 320;
        NSString *pathstr = [NSString stringWithFormat:@"imageName%i.png",i];
        NSString *path = [documentsDirectory stringByAppendingPathComponent:pathstr];
        UIImageView *imView = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:path]];
        [imView setFrame:CGRectMake(xOrigin,0, 320, 380)];
        [scroll addSubview:imView];
    }
    scroll.contentSize = CGSizeMake(320 * (numberOfViews), 350);
    
    [scroll setContentOffset:CGPointMake(320*(detailItem-1), 0)];
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
    NSLog(@"1");
}

-(void)usemaps2{
   // imageView.hidden= YES;

    NSString *language = [[NSLocale currentLocale] localeIdentifier];
    if ([language isEqualToString:@"ru_RU"]) {
        lab2.text=@"Нажмите компас\nчтобы увидеть\nмаршрут";}
    else {lab2.text=@"Click a compass\nto see a route";}
    mapView.hidden=NO;
    int i = (int)(scroll.contentOffset.x/320);
    NSLog(@"%i",i);
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *pathstr = [NSString stringWithFormat:@"photo%i.plist",i+1];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:pathstr];
    NSArray *arr = [[NSArray alloc] initWithContentsOfFile:path];
    NSString *str = [[NSString alloc] initWithFormat:@"%@",[arr objectAtIndex:0]];
    NSString *str1 = [[NSString alloc]initWithFormat:@"%@",[arr objectAtIndex:1]];
    NSLog(@"%@%@",str,str1);
    mapView.showsUserLocation = YES;
    MKCoordinateRegion region;
    region.center = CLLocationCoordinate2DMake(str.floatValue, str1.floatValue);
    MKCoordinateSpan span;
    span.longitudeDelta = 0.002;
    span.latitudeDelta = 0.002;
    region.span = span;
    [self.mapView setRegion:region animated:YES];;
    MapViewAnnotation *newAnnotation = [[MapViewAnnotation alloc] initWithTitle:@"I'm here" andCoordinate:CLLocationCoordinate2DMake(str.floatValue, str1.floatValue)];
	[mapView addAnnotation:newAnnotation];;
}

-(void)route{
    CLLocationManager *manager = [[CLLocationManager alloc] init];
    manager.delegate = self;
    manager.distanceFilter = kCLDistanceFilterNone;
    manager.desiredAccuracy = kCLLocationAccuracyBest;
    [manager startUpdatingLocation];
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSFileManager *filemgr = [NSFileManager defaultManager];
    NSArray *filelist = [filemgr contentsOfDirectoryAtPath:documentsDirectory error:nil];
    //int i=[filelist count]/2;
    int i = (int)(scroll.contentOffset.x/320);
    NSLog(@"%i",i);
    NSString *pathstr = [NSString stringWithFormat:@"photo%i.plist",i+1];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:pathstr];
    NSArray *arr = [[NSArray alloc] initWithContentsOfFile:path];
    NSString *str = [[NSString alloc] initWithFormat:@"%@",[arr objectAtIndex:0]];
    NSString *str1 = [[NSString alloc]initWithFormat:@"%@",[arr objectAtIndex:1]];
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"6.0")) {
        NSString *stringURL = [NSString stringWithFormat:@"http://maps.apple.com/maps?saddr=%g,%g&daddr=%f,%f",manager.location.coordinate.latitude, manager.location.coordinate.longitude,str.floatValue,str1.floatValue];
        NSURL *url = [NSURL URLWithString:stringURL];
        [[UIApplication sharedApplication] openURL:url];}
    else {NSString *stringURL = [NSString stringWithFormat:@"http://maps.google.com/maps?saddr=%g,%g&daddr=%f,%f",manager.location.coordinate.latitude, manager.location.coordinate.longitude,str.floatValue,str1.floatValue];
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
@end
