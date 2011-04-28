/*
 * Real time image processing framework for iOS
 * BinarizedCameraViewController.m
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

#import "BinarizedCameraViewController.h"
#import "QuartzHelpLibrary.h"

@implementation BinarizedCameraViewController

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	// alloc buffer
	binarizedPixels = (unsigned char*)malloc(sizeof(unsigned char) * (int)self.bufferSize.width * (int)self.bufferSize.height);
	
	// fit to view
	float ratio = self.bufferSize.width / self.bufferSize.height;
	binarizedImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, (int)self.view.frame.size.width, (int)self.view.frame.size.width * ratio)];
	[self.view addSubview:binarizedImageView];
	[binarizedImageView release];
	
	// add toolbar
	UIToolbar *bar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 44, self.view.frame.size.width, 44)];
	[self.view addSubview:bar];
	[bar release];
	
	UIBarButtonItem *closeButton = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Close", nil) style:UIBarButtonItemStyleBordered target:self action:@selector(close:)] autorelease];
	[bar setItems:[NSArray arrayWithObject:closeButton]];
	
	[self setDelegate:self];
}

- (void)didUpdateBufferCameraViewController:(CameraViewController*)CameraViewController {
	// Rotate pixel array in order to display it on this view controller's view.
	int width = self.bufferSize.height;
	int height = self.bufferSize.width;
	int threshold = 120;
	for (int y = 0; y < height; y++) {
		for (int x = 0; x < width; x++) {
			binarizedPixels[y * width + x] = buffer[(width - 1 - x) * height + y] > threshold ? 255 : 0;
		}
	}
	
	// Make CGImage from pixel array, with Quartz Help Library
	CGImageRef imageRef = CGImageGrayColorCreateWithGrayPixelBuffer(binarizedPixels, width, height);
	
	// Update UIImageView with CGImageRef
	// support multi-threading
#ifdef _MULTI_THREADING
	dispatch_sync(dispatch_get_main_queue(), ^{
		[binarizedImageView setImage:[UIImage imageWithCGImage:imageRef]];
	});
#else
	[binarizedImageView setImage:[UIImage imageWithCGImage:imageRef]];
#endif
	
	// release image
	CGImageRelease(imageRef);
}

- (void)close:(id)sender {
	[self dismissModalViewControllerAnimated:YES];
}

- (void)dealloc {
    free(binarizedPixels);
    [super dealloc];
}

@end
