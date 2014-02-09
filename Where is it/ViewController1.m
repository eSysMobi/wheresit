//
//  ViewController1.m
//  Where is it
//
//  Created by Vladimir P. Starkov on 04.12.12.
//  Copyright (c) 2012 Vladimir P. Starkov. All rights reserved.
//

#import "ViewController1.h"
#import "ViewController2.h"


@interface ViewController1 ()

@end

@implementation ViewController1
@synthesize inf,lab;
- (void)viewDidLoad
{
    [super viewDidLoad];
    int j,k;
    l=0;
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc]
                                   initWithTitle: @"Back"
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
    j=0;k=0;
    inf = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.rightBarButtonItem = inf;
    self.navigationItem.title=@"Where is it?";
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSFileManager *filemgr = [NSFileManager defaultManager];
    NSArray *filelist = [filemgr contentsOfDirectoryAtPath:documentsDirectory error:nil];
    NSLog(@"%i",[filelist count]);
 
    for (int i=0; i<[filelist count]/2; i++) {
        if (j ==2)  k=k+1;
        if (j ==2)  j=j-2;
        NSString *pathstr = [NSString stringWithFormat:@"imageName%i.png",i+1];
        NSString *path = [documentsDirectory stringByAppendingPathComponent:pathstr];
        UIImage *image = [UIImage imageWithContentsOfFile:path];
        button= [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        [button setBackgroundImage:image forState:UIControlStateNormal];
       // button.transform =CGAffineTransformMakeRotation(3.14/2);
        [button setFrame:CGRectMake(6+158*j,8+118*k, 150, 110)];
        [button setTag:i+1];
        [self.view addSubview:button];j++;}
        [self.view addSubview:lab];
    lab.hidden=YES;
   
}

-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status{
    NSLog(@"Changed");
}

-(IBAction)buttonClick:(UIButton *)sender{
    self.viewController2 = [[ViewController2 alloc] initWithNibName:@"ViewController2" bundle:nil];
    self.viewController2.detailItem = sender.tag;
    self.viewController2.hidesBottomBarWhenPushed=YES;
    [self.navigationController pushViewController:self.viewController2 animated:YES];
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


-(void)dealloc{
    
}



@end
