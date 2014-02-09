//
//  MapViewAnnotation.m
//  Where is it
//
//  Created by Vladimir P. Starkov on 13.09.12.
//  Copyright (c) 2012 Vladimir P. Starkov. All rights reserved.
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