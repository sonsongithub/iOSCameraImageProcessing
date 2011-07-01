/*
 * Real time image processing framework for iOS
 * NormalCameraViewController.m
 *
 * Copyright (c) Yuichi YOSHIDA, 11/04/20
 * All rights reserved.
 * 
 * BSD License
 *
 * Redistribution and use in source and binary forms, with or without modification, are 
 * permitted provided that the following conditions are met:
 * - Redistributions of source code must retain the above copyright notice, this list of
 *  conditions and the following disclaimer.
 * - Redistributions in binary form must reproduce the above copyright notice, this list
 *  of conditions and the following disclaimer in the documentation and/or other materia
 * ls provided with the distribution.
 * - Neither the name of the "Yuichi Yoshida" nor the names of its contributors may be u
 * sed to endorse or promote products derived from this software without specific prior 
 * written permission.
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY E
 * XPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES O
 * F MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SH
 * ALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENT
 * AL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROC
 * UREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS I
 * NTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRI
 * CT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF T
 * HE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "NormalCameraViewController.h"


@implementation NormalCameraViewController

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

	CGRect frame;
	switch(self.interfaceOrientation) {
		case UIInterfaceOrientationLandscapeLeft:
			frame = CGRectMake(0, self.view.frame.size.width - 44, self.view.frame.size.height, 44);
			break;
		case UIInterfaceOrientationLandscapeRight:
			frame = CGRectMake(0, self.view.frame.size.width - 44, self.view.frame.size.height, 44);
			break;
		case UIInterfaceOrientationPortrait:
			frame = CGRectMake(0, self.view.frame.size.height - 44, self.view.frame.size.width, 44);
			break;
		case UIInterfaceOrientationPortraitUpsideDown:
			frame = CGRectMake(0, self.view.frame.size.height - 44, self.view.frame.size.width, 44);
			break;
		default:
			frame = CGRectMake(0, self.view.frame.size.height - 44, self.view.frame.size.width, 44);
			break;
	}
	
	// add toolbar
	UIToolbar *bar = [[UIToolbar alloc] initWithFrame:frame];//CGRectMake(0, self.view.frame.size.height - 44, self.view.frame.size.width, 44)];
	[bar setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleWidth];
	[self.view addSubview:bar];
	[bar release];
	
	// add button
	UIBarButtonItem *closeButton = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Close", nil) style:UIBarButtonItemStyleBordered target:self action:@selector(close:)] autorelease];
	[bar setItems:[NSArray arrayWithObject:closeButton]];
}

- (void)close:(id)sender {
	[self dismissModalViewControllerAnimated:YES];
}

@end
