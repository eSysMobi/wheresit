//
//  PhotosViewController.m
//  Where-is-it
//
//  Created by Mac on 30.07.13.
//  Copyright (c) 2013 IT-insign. All rights reserved.
//

#import "PhotosViewController.h"
#import "SinglePhotoViewController.h"

@interface PhotosViewController ()

@end

@implementation PhotosViewController
@synthesize inf,lab;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = NSLocalizedString(@"Photos", @"Photos");
        self.tabBarItem.image = [UIImage imageNamed:@"fotos25(1).png"];
        [self.tabBarItem setFinishedSelectedImage:[UIImage imageNamed:@"fotos25.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"fotos25h.png"]];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    int j,k;
    l=0;
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc]
                                   initWithTitle: @"Back1"
                                   style: UIBarButtonItemStyleBordered
                                   target: nil action: nil];
    
    [self.navigationItem setBackBarButtonItem: backButton];
    lab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 440)];
    lab.backgroundColor = [[UIColor alloc] initWithRed:0 green:0 blue:0 alpha:0.5];
    lab.hidden=YES;
    lab.textColor=[UIColor whiteColor];
    lab.textAlignment=UITextAlignmentCenter;
    [lab setFont:[UIFont systemFontOfSize:24]];
    [lab setNumberOfLines:4];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeInfoDark];
    [button addTarget:self action:@selector(infopressed) forControlEvents:UIControlEventTouchUpInside];
    inf = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.rightBarButtonItem = inf;
    NSString *language = [[NSLocale currentLocale] localeIdentifier];
    if ([language isEqualToString:@"ru_RU"]) {
        lab.text=@"Нажмите на нужную\nфотографию";}
    else {
        lab.text=@"Tap on the\nneedful photo";}
//    j=0;k=0;
    inf = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.rightBarButtonItem = inf;
    self.navigationItem.title=@"Where is it?";
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSFileManager *filemgr = [NSFileManager defaultManager];
    NSArray *filelist = [filemgr contentsOfDirectoryAtPath:documentsDirectory error:nil];
    NSLog(@"filelist count %i",[filelist count]);
    
    int x = 0;
    int y = 0;
    for(int i = 0; i < [filelist count]/2; i++){
        if(x == 3){
            y++;
            x = 0;
        }
        NSString *pathstr = [NSString stringWithFormat:@"imageName%i.png",i+1];
        NSString *path = [documentsDirectory stringByAppendingPathComponent:pathstr];
        UIImage *image = [UIImage imageWithContentsOfFile:path];
        button= [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        [button setBackgroundImage:image forState:UIControlStateNormal];
//         button.transform =CGAffineTransformMakeRotation(3.14/2);
        [button setFrame:CGRectMake(6+108*x,8+158*y, 100, 150)];
        [button setTag:i+1];
        [self.view addSubview:button];
        x++;

            
    }
    [self.view addSubview:lab];
    lab.hidden=YES;
}

-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status{
    NSLog(@"Changed");
}

-(IBAction)buttonClick:(UIButton *)sender{
    NSLog(@"tag %i", sender.tag);
    self.detailViewController = [[SinglePhotoViewController alloc] initWithNibName:@"SinglePhotoViewController" bundle:nil];
    self.detailViewController.detailItem = sender.tag;
    self.detailViewController.hidesBottomBarWhenPushed=YES;
    [self.navigationController pushViewController:self.detailViewController animated:YES];
}

-(void)infopressed{
    if (l==0){
        lab.hidden=NO;
        l=1;
    }
    else{
        lab.hidden=YES;
        l=0;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)resetView
{
    //reset your view components.
    [self.view setNeedsDisplay];
}

-(void)viewWillAppear:(BOOL)animated{
    [self resetView];
    [self viewDidLoad];
}

-(void)viewWillDisappear:(BOOL)animated{
    if (l==1) {
        [self performSelector:@selector(infopressed) withObject:nil];}
}

@end
