//
//  PPViewController.h
//  Where-is-it
//
//  Created by Mac on 05.09.13.
//  Copyright (c) 2013 IT-insign. All rights reserved.
//

#import <FacebookSDK/FacebookSDK.h>

typedef void(^ConfirmCallback)(id sender, NSString *place);

@interface PPViewController : FBPlacePickerViewController <UISearchDisplayDelegate, UISearchBarDelegate>
@property (copy, nonatomic) ConfirmCallback confirmCallback;
@end
