//
//  cvViewController.m
//  cv
//
//  Created by sonson on 11/04/22.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "cvViewController.h"

#import "CameraViewController.h"

@implementation cvViewController

- (IBAction)openCameraViewController:(id)sender {
	CameraViewController *controller = [[CameraViewController alloc] initWithNibName:nil bundle:nil];
	[self presentModalViewController:controller animated:YES];
	[controller release];
}

@end
