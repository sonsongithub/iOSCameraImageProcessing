//
//  NormalCameraViewController.m
//  cv
//
//  Created by sonson on 11/04/28.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NormalCameraViewController.h"


@implementation NormalCameraViewController

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	// add toolbar
	UIToolbar *bar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 44, self.view.frame.size.width, 44)];
	[self.view addSubview:bar];
	[bar release];
	
	UIBarButtonItem *closeButton = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Close", nil) style:UIBarButtonItemStyleBordered target:self action:@selector(close:)] autorelease];
	[bar setItems:[NSArray arrayWithObject:closeButton]];
}

- (void)close:(id)sender {
	[self dismissModalViewControllerAnimated:YES];
}

@end
