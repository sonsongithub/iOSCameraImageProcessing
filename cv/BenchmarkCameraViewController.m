/*
 * Real time image processing framework for iOS
 * BenchmarkCameraViewController.m
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

#import "BenchmarkCameraViewController.h"

@implementation BenchmarkCameraViewController

#pragma mark - Instance method

- (void)close:(id)sender {
	[self dismissModalViewControllerAnimated:YES];
}

#pragma mark - Override

- (id)init {
    self = [super initWithCameraViewControllerType:BufferGrayColor|BufferSize640x480];
    if (self) {
		binarizedPixels = (unsigned char*)malloc(sizeof(unsigned char) * (int)self.bufferSize.width * (int)self.bufferSize.height);
    }
    return self;
}

#pragma mark - CameraViewControllerDelegate

- (void)didUpdateBufferCameraViewController:(CameraViewController*)CameraViewController {
	
	int width = self.bufferSize.height;
	int height = self.bufferSize.width;
	int threshold = 120;
	for (int y = 0; y < height; y++) {
		for (int x = 0; x < width; x++) {
			binarizedPixels[y * width + x] = buffer[y * width + x] > threshold ? 255 : 0;
		}
	}
}

#pragma mark - Life cycle

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	// add toolbar
	UIToolbar *bar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 44, self.view.frame.size.width, 44)];
	[self.view addSubview:bar];
	[bar release];
	
	UIBarButtonItem *closeButton = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Close", nil) style:UIBarButtonItemStyleBordered target:self action:@selector(close:)] autorelease];
	[bar setItems:[NSArray arrayWithObject:closeButton]];
	
	[self setDelegate:self];
}
#pragma mark - dealloc

- (void)dealloc {
    free(binarizedPixels);
    [super dealloc];
}

@end
