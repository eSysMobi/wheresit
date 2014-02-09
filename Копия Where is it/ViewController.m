//
//  ViewController.m
//  Where is it
//
//  Created by Vladimir P. Starkov on 04.09.12.
//  Copyright (c) 2012 Vladimir P. Starkov. All rights reserved.
//

#import "ViewController.h"
#import "ViewController1.h"
#import "AppDelegate.h"
#import "CoreGraphics/CoreGraphics.h"
#import "CoreLocation/CoreLocation.h"


#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

@interface ViewController ()

@end
@implementation ViewController
@synthesize imageView;
@synthesize viewController1, but1,acv,inf,manager;


- (void)viewDidLoad
{  
    [super viewDidLoad];
    [manager startUpdatingLocation];
    l=0;
    CGRect screenBound = [[UIScreen mainScreen] bounds];
    CGSize screenSize = screenBound.size;
    CGFloat screenWidth = screenSize.width;
    CGFloat screenHeight = screenSize.height;
    if (!(screenHeight==480)) {
        but1.frame=CGRectMake(113, 340, 95, 68);
    }
    lab2 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 440)];
    lab1 =[[UILabel alloc]initWithFrame:CGRectMake(50, 0, 220, 100)];
    lab2.backgroundColor = [[UIColor alloc] initWithRed:0 green:0 blue:0 alpha:0.5];
    lab1.backgroundColor = [[UIColor alloc] initWithRed:0 green:0 blue:0 alpha:0];
    lab2.hidden=YES;
    lab1.hidden=YES;
    acv.hidden=YES;
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc]
                                   initWithTitle: @"Back"
                                   style: UIBarButtonItemStyleBordered
                                   target: nil action: nil];
        [self.navigationItem setBackBarButtonItem: backButton];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeInfoDark];
    [button addTarget:self action:@selector(infopressed) forControlEvents:UIControlEventTouchUpInside];
    inf = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.rightBarButtonItem = inf;
    self.navigationItem.title=@"Where is it?";
    [[UINavigationBar appearance] setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [UIColor blackColor],UITextAttributeTextColor,
 nil]];
         NSString *language = [[NSLocale currentLocale] localeIdentifier];
        mapView.hidden = YES;
          [self.view addSubview:lab2];
        [lab2 setNumberOfLines:6];
        lab2.textColor=[UIColor whiteColor];
        lab2.textAlignment=UITextAlignmentCenter;

        if ([language isEqualToString:@"ru_RU"]) {
            lab2.text=@"Нажмите значок внизу!\nСделайте фото\nоставленного предмета\nили места";}
        else {lab2.text=@"Press a botton below!\nMake a photo the thing you leave somewhere";}
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSFileManager *filemgr = [NSFileManager defaultManager];
       NSArray *filelist = [filemgr contentsOfDirectoryAtPath:documentsDirectory error:nil];
    if ([filelist count]==0) {
        [self performSelectorInBackground:@selector(locMan) withObject:nil];}
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    NSLog(@"OldLocation %f %f", oldLocation.coordinate.latitude, oldLocation.coordinate.longitude);
    NSLog(@"NewLocation %f %f", newLocation.coordinate.latitude, newLocation.coordinate.longitude);
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

-(void)infopressed{
    if (l==0){
        lab2.hidden=NO;
        lab1.hidden=NO;
        l=1;
    }
    else{
        lab2.hidden=YES;
        lab1.hidden=YES;
        l=0;
    }
    
}

-(void)locMan{

    CLLocationManager *manager1 = [[CLLocationManager alloc] init];
    [manager1 startUpdatingLocation];
    loc = manager1.location;
    self.navigationController.navigationBar.backItem.hidesBackButton=YES;
    [self performSelector:@selector(useCamera) withObject:nil];
}



-(void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info
{   
    NSString *mediaType = [info
                           objectForKey:UIImagePickerControllerMediaType];
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSFileManager *filemgr = [NSFileManager defaultManager];
    NSArray *filelist = [filemgr contentsOfDirectoryAtPath:documentsDirectory error:nil];

        [self dismissModalViewControllerAnimated:YES];
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
        UIImage *image = [info
                          objectForKey:UIImagePickerControllerOriginalImage];
        UIGraphicsBeginImageContext(CGSizeMake(324,242));
        
        CGContextRef            context = UIGraphicsGetCurrentContext();
        
        [image drawInRect: CGRectMake(0, 0, 324, 242)];
        
        UIImage        *smallImage = UIGraphicsGetImageFromCurrentImageContext();
        
        UIGraphicsEndImageContext();
        NSData *imageData = UIImagePNGRepresentation(smallImage);
            [picker isBeingDismissed];
        [acv hidesWhenStopped];
        [acv startAnimating];
           NSError * error = nil;
            switch (([filelist count])/2) {
                case 0:
                {NSString *path = [documentsDirectory stringByAppendingPathComponent:@"imageName1.png"];
                        [imageData writeToFile:path options:NSDataWritingAtomic error:&error];}
                    break;
                case 1:
                {NSString *path = [documentsDirectory stringByAppendingPathComponent:@"imageName2.png"];
                        [imageData writeToFile:path options:NSDataWritingAtomic error:&error];}
                    break;
                case 2:
                {NSString *path = [documentsDirectory stringByAppendingPathComponent:@"imageName3.png"];
                        [imageData writeToFile:path options:NSDataWritingAtomic error:&error];}
                    break;
                case 3:
                {NSString *path = [documentsDirectory stringByAppendingPathComponent:@"imageName4.png"];
                        [imageData writeToFile:path options:NSDataWritingAtomic error:&error];}
                    break;
                case 4:
                {NSString *path = [documentsDirectory stringByAppendingPathComponent:@"imageName5.png"];
                        [imageData writeToFile:path options:NSDataWritingAtomic error:&error];}
                    break;
                case 5:
                {NSString *path = [documentsDirectory stringByAppendingPathComponent:@"imageName6.png"];
                        [imageData writeToFile:path options:NSDataWritingAtomic error:&error];}
                    break;
                case 6:{NSString *path1 = [documentsDirectory stringByAppendingPathComponent:@"imageName1.png"];
                    NSString *path2 = [documentsDirectory stringByAppendingPathComponent:@"imageName2.png"];
                    NSString *path3 = [documentsDirectory stringByAppendingPathComponent:@"imageName3.png"];
                    NSString *path4 = [documentsDirectory stringByAppendingPathComponent:@"imageName4.png"];
                    NSString *path5 = [documentsDirectory stringByAppendingPathComponent:@"imageName5.png"];
                    NSString *path6 = [documentsDirectory stringByAppendingPathComponent:@"imageName6.png"];
                    UIImage *tempimg = [UIImage imageWithContentsOfFile:path5];
                    NSData *imageDataT = UIImagePNGRepresentation(tempimg);
                    [imageDataT writeToFile:path6 atomically:YES];
                    tempimg = [UIImage imageWithContentsOfFile:path4];
                    imageDataT = UIImagePNGRepresentation(tempimg);
                    [imageDataT writeToFile:path5 atomically:YES];
                    tempimg = [UIImage imageWithContentsOfFile:path3];
                    imageDataT = UIImagePNGRepresentation(tempimg);
                    [imageDataT writeToFile:path4 atomically:YES];
                    tempimg = [UIImage imageWithContentsOfFile:path2];
                    imageDataT = UIImagePNGRepresentation(tempimg);
                    [imageDataT writeToFile:path3 atomically:YES];
                    tempimg = [UIImage imageWithContentsOfFile:path1];
                    imageDataT = UIImagePNGRepresentation(tempimg);
                    [imageDataT writeToFile:path2 atomically:YES];
                    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"imageName1.png"];
                    [imageData writeToFile:path options:NSDataWritingAtomic error:&error];
                }break;
            }   
            [self performSelectorInBackground:@selector(savedata) withObject:nil];
        [acv stopAnimating];
    }
}

-(void)savedata{
    CLLocationManager *manager1 = [[CLLocationManager alloc] init];
    [manager1 startUpdatingLocation];
    loc = manager1.location;
    NSLog(@"%@",loc);
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSFileManager *filemgr = [NSFileManager defaultManager];
    NSArray *filelist = [filemgr contentsOfDirectoryAtPath:documentsDirectory error:nil];
        switch (([filelist count])/2) {
            case 0:
            {NSString *path = [documentsDirectory stringByAppendingPathComponent:@"photo1.plist"];
                loc = manager1.location;
                NSString *str1 = [[NSString alloc] initWithFormat:@"%f",loc.coordinate.latitude];
                NSString *str2 = [[NSString alloc] initWithFormat:@"%f",loc.coordinate.longitude];
                NSArray *locdata = [[NSArray alloc] initWithObjects:str1,str2, nil];
                [locdata writeToFile:path atomically:YES];
}
                break;
            case 1:
            {NSString *path = [documentsDirectory stringByAppendingPathComponent:@"photo2.plist"];
                loc = manager1.location;
                NSString *str1 = [[NSString alloc] initWithFormat:@"%f",loc.coordinate.latitude];
                NSString *str2 = [[NSString alloc] initWithFormat:@"%f",loc.coordinate.longitude];
                NSArray *locdata = [[NSArray alloc] initWithObjects:str1,str2, nil];
                [locdata writeToFile:path atomically:YES];}
                break;
            case 2:
            {NSString *path = [documentsDirectory stringByAppendingPathComponent:@"photo3.plist"];
                loc = manager1.location;
                NSString *str1 = [[NSString alloc] initWithFormat:@"%f",loc.coordinate.latitude];
                NSString *str2 = [[NSString alloc] initWithFormat:@"%f",loc.coordinate.longitude];
                NSArray *locdata = [[NSArray alloc] initWithObjects:str1,str2, nil];
                [locdata writeToFile:path atomically:YES];}
                break;
            case 3:
            {NSString *path = [documentsDirectory stringByAppendingPathComponent:@"photo4.plist"];
                loc = manager1.location;
                NSString *str1 = [[NSString alloc] initWithFormat:@"%f",loc.coordinate.latitude];
                NSString *str2 = [[NSString alloc] initWithFormat:@"%f",loc.coordinate.longitude];
                NSArray *locdata = [[NSArray alloc] initWithObjects:str1,str2, nil];
                [locdata writeToFile:path atomically:YES];}
                break;
            case 4:
            {NSString *path = [documentsDirectory stringByAppendingPathComponent:@"photo5.plist"];
                loc = manager1.location;
                NSString *str1 = [[NSString alloc] initWithFormat:@"%f",loc.coordinate.latitude];
                NSString *str2 = [[NSString alloc] initWithFormat:@"%f",loc.coordinate.longitude];
                NSArray *locdata = [[NSArray alloc] initWithObjects:str1,str2, nil];
                [locdata writeToFile:path atomically:YES];}
                break;
            case 5:
            {NSString *path = [documentsDirectory stringByAppendingPathComponent:@"photo6.plist"];
                loc = manager1.location;
                NSString *str1 = [[NSString alloc] initWithFormat:@"%f",loc.coordinate.latitude];
                NSString *str2 = [[NSString alloc] initWithFormat:@"%f",loc.coordinate.longitude];
                NSArray *locdata = [[NSArray alloc] initWithObjects:str1,str2, nil];
                [locdata writeToFile:path atomically:YES];}
                break;
            case 6:{NSString *path1 = [documentsDirectory stringByAppendingPathComponent:@"photo1.plist"];
                NSString *path2 = [documentsDirectory stringByAppendingPathComponent:@"photo2.plist"];
                NSString *path3 = [documentsDirectory stringByAppendingPathComponent:@"photo3.plist"];
                NSString *path4 = [documentsDirectory stringByAppendingPathComponent:@"photo4.plist"];
                NSString *path5 = [documentsDirectory stringByAppendingPathComponent:@"photo5.plist"];
                NSString *path6 = [documentsDirectory stringByAppendingPathComponent:@"photo6.plist"];
                loc = manager1.location;
                NSString *str1 = [[NSString alloc] initWithFormat:@"%f",loc.coordinate.latitude];
                NSString *str2 = [[NSString alloc] initWithFormat:@"%f",loc.coordinate.longitude];
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
            }break;
        }
    self.navigationController.navigationBar.backItem.hidesBackButton=YES;
    self.viewController1 = [[ViewController1 alloc] initWithNibName:@"ViewController1" bundle:nil];
    //[self.navigationController pushViewController:self.viewController1 animated:YES];
    [self.viewController1 loadView];
    self.viewController1.lab.hidden=YES;
    [self.tabBarController setSelectedIndex:1];

}

-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status{
    NSLog(@"1");
}




- (void) useCamera
{  // mapView.hidden=YES;
    if ([UIImagePickerController isSourceTypeAvailable:
         UIImagePickerControllerSourceTypeCamera])
    {
        UIImagePickerController *imagePicker =
        [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        imagePicker.sourceType =
        UIImagePickerControllerSourceTypeCamera;
        imagePicker.mediaTypes = [NSArray arrayWithObjects:
                                  (NSString *) kUTTypeImage,
                                  nil];
        imagePicker.allowsEditing = NO;
        [self presentModalViewController:imagePicker
                                animated:YES];
        newMedia = YES;
    }
}


-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissModalViewControllerAnimated:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return 0;
}

-(void)dealloc{
    
}

@end
