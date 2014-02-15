//
//  MapViewAnnotation.m
//  Where-is-it
//
//  Created by Mac on 30.07.13.
//  Copyright (c) 2013 IT-insign. All rights reserved.
//

#import "MapViewAnnotation.h"

@implementation MapViewAnnotation

@synthesize title, coordinate;

- (id)initWithTitle:(NSString *)ttl andCoordinate:(CLLocationCoordinate2D)c2d {
	title = ttl;
	coordinate = c2d;
	return self;
}

@end