/*
     File: AVCamViewController.m
 Abstract: A view controller that coordinates the transfer of information between the user interface and the capture manager.
  Version: 1.2
 
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple
 Inc. ("Apple") in consideration of your agreement to the following
 terms, and your use, installation, modification or redistribution of
 this Apple software constitutes acceptance of these terms.  If you do
 not agree with these terms, please do not use, install, modify or
 redistribute this Apple software.
 
 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a personal, non-exclusive
 license, under Apple's copyrights in this original Apple software (the
 "Apple Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may
 be used to endorse or promote products derived from the Apple Software
 without specific prior written permission from Apple.  Except as
 expressly stated in this notice, no other rights or licenses, express or
 implied, are granted by Apple herein, including but not limited to any
 patent rights that may be infringed by your derivative works or by other
 works in which the Apple Software may be incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 
 Copyright (C) 2011 Apple Inc. All Rights Reserved.
 
 */

#import "AVCamViewController.h"
#import "AVCamCaptureManager.h"
#import "AVCamRecorder.h"
#import <AVFoundation/AVFoundation.h>
#import "ViewController1.h"


static void *AVCamFocusModeObserverContext = &AVCamFocusModeObserverContext;

@interface AVCamViewController () <UIGestureRecognizerDelegate>
@end

@interface AVCamViewController (InternalMethods)
- (CGPoint)convertToPointOfInterestFromViewCoordinates:(CGPoint)viewCoordinates;
- (void)tapToAutoFocus:(UIGestureRecognizer *)gestureRecognizer;
- (void)tapToContinouslyAutoFocus:(UIGestureRecognizer *)gestureRecognizer;
- (void)updateButtonStates;
@end

@interface AVCamViewController (AVCamCaptureManagerDelegate) <AVCamCaptureManagerDelegate>
@end

@implementation AVCamViewController

@synthesize reMake;
@synthesize useButton;
@synthesize captureManager;
@synthesize cameraToggleButton;
@synthesize stillButton;
@synthesize focusModeLabel;
@synthesize videoPreviewView;
@synthesize captureVideoPreviewLayer;
@synthesize imageData, image;
//@synthesize loc;

- (NSString *)stringForFocusMode:(AVCaptureFocusMode)focusMode
{
	NSString *focusString = @"";
	
	switch (focusMode) {
		case AVCaptureFocusModeLocked:
			focusString = @"locked";
			break;
		case AVCaptureFocusModeAutoFocus:
			focusString = @"auto";
			break;
		case AVCaptureFocusModeContinuousAutoFocus:
			focusString = @"continuous";
			break;
	}
	
	return focusString;
}

- (void)dealloc
{
    [self removeObserver:self forKeyPath:@"captureManager.videoInput.device.focusMode"];
}
- (void)viewDidLoad
{
    NSLog(@"AVCamViewController viewDidLoad");
    [[self reMake] setTitle:NSLocalizedString(@"re photo", @"re photo camera button title")];
    [[self useButton] setTitle:NSLocalizedString(@"use this", @"Use this camera button title")];
    [self.useButton setEnabled:NO];
    [self.reMake setEnabled:NO];
    
    
    [[self cameraToggleButton] setTitle:NSLocalizedString(@"Camera", @"Toggle camera button title")];
    [[self stillButton] setTitle:NSLocalizedString(@"Photo", @"Capture still image button title")];
    
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
			
            // Create the focus mode UI overlay
			UILabel *newFocusModeLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, viewLayer.bounds.size.width - 20, 20)];
			[newFocusModeLabel setBackgroundColor:[UIColor clearColor]];
			[newFocusModeLabel setTextColor:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.50]];
			AVCaptureFocusMode initialFocusMode = [[[captureManager videoInput] device] focusMode];
			[newFocusModeLabel setText:[NSString stringWithFormat:@"focus: %@", [self stringForFocusMode:initialFocusMode]]];
			[view addSubview:newFocusModeLabel];
			[self addObserver:self forKeyPath:@"captureManager.videoInput.device.focusMode" options:NSKeyValueObservingOptionNew context:AVCamFocusModeObserverContext];
			[self setFocusModeLabel:newFocusModeLabel];
//            [newFocusModeLabel release];
            
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
			
//			[doubleTap release];
//			[singleTap release];
		}		
	}
		
    [super viewDidLoad];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == AVCamFocusModeObserverContext) {
        // Update the focus UI overlay string when the focus mode changes
		[focusModeLabel setText:[NSString stringWithFormat:@"focus: %@", [self stringForFocusMode:(AVCaptureFocusMode)[[change objectForKey:NSKeyValueChangeNewKey] integerValue]]]];
	} else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark Toolbar Actions
- (IBAction)toggleCamera:(id)sender
{
    // Toggle between cameras when there is more than one
    [[self captureManager] toggleCamera];
    
    // Do an initial focus
    [[self captureManager] continuousFocusAtPoint:CGPointMake(.5f, .5f)];
}

- (IBAction)captureStillImage:(id)sender
{
    // Capture a still image
    [[self stillButton] setEnabled:NO];
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


- (IBAction)closeCam:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
    [self.tabBarController setSelectedIndex:1];
}
@end

@implementation AVCamViewController (InternalMethods)

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
	NSUInteger cameraCount = [[self captureManager] cameraCount];
	NSUInteger micCount = [[self captureManager] micCount];
    
    CFRunLoopPerformBlock(CFRunLoopGetMain(), kCFRunLoopCommonModes, ^(void) {
        if (cameraCount < 2) {
            [[self cameraToggleButton] setEnabled:NO]; 
            
            if (cameraCount < 1) {
                [[self stillButton] setEnabled:NO];
                
            } else {
                [[self stillButton] setEnabled:YES];
            }
        } else {
            [[self cameraToggleButton] setEnabled:YES];
            [[self stillButton] setEnabled:YES];
        }
    });
}

@end

@implementation AVCamViewController (AVCamCaptureManagerDelegate)

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
    NSLog(@"captureManagerStillImageCaptured");
    
    self.image = [captureManager image];
    self.imageData = [captureManager imageData];
    
    CFRunLoopPerformBlock(CFRunLoopGetMain(), kCFRunLoopCommonModes, ^(void) {
        [[self stillButton] setEnabled:YES];
    });
    [[[self captureManager] session] stopRunning];
    
    [self.useButton setEnabled:YES];
    [self.reMake setEnabled:YES];
}

- (void)captureManagerDeviceConfigurationChanged:(AVCamCaptureManager *)captureManager
{
	[self updateButtonStates];
}


-(IBAction)rePhoto:(id)sender{
    [self.useButton setEnabled:NO];
    [self.reMake setEnabled:NO];
    [[[self captureManager] session] startRunning];
}
- (IBAction)usePhoto:(id)sender{
    NSLog(@"use Photo");
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSFileManager *filemgr = [NSFileManager defaultManager];
    NSArray *filelist = [filemgr contentsOfDirectoryAtPath:documentsDirectory error:nil];
    
    [self dismissModalViewControllerAnimated:YES];
    //if ([mediaType isEqualToString:(NSString *)kUTTypeImage])
    {
        UIImage *image = self.image;    //[info   objectForKey:UIImagePickerControllerOriginalImage];
        UIGraphicsBeginImageContext(CGSizeMake(242,324));
        
        CGContextRef            context = UIGraphicsGetCurrentContext();
        
        [image drawInRect: CGRectMake(0, 0, 242, 324 )];
        
        UIImage        *smallImage = UIGraphicsGetImageFromCurrentImageContext();
        
        UIGraphicsEndImageContext();
        NSData *imageData = UIImagePNGRepresentation(smallImage);
//        [picker isBeingDismissed];
//        [acv hidesWhenStopped];
//        [acv startAnimating];
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
//        [acv stopAnimating];
    }
}
-(void)savedata{
    CLLocationManager *manager1 = [[CLLocationManager alloc] init];
    [manager1 startUpdatingLocation];
    loc = manager1.location;
    NSLog(@"LOC %@",loc);
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
    [self.navigationController pushViewController:self.viewController1 animated:YES];
    [self.viewController1 loadView];
    self.viewController1.lab.hidden=YES;
    [self.tabBarController setSelectedIndex:1];
    NSLog(@"bla bla bla %i", self.tabBarController.selectedIndex);
    
}

@end
