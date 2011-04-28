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

//#define _TEST_COLOR

#import "QuartzHelpLibrary.h"

@implementation BenchmarkCameraViewController

#pragma mark - Instance method

- (void)close:(id)sender {
	[self dismissModalViewControllerAnimated:YES];
}

#pragma mark - Override

- (id)init {
#ifdef _TEST_COLOR
    self = [super initWithCameraViewControllerType:BufferRGBColor|BufferSize640x480];
#else
    self = [super initWithCameraViewControllerType:BufferGrayColor|BufferSize640x480];
#endif
    if (self) {
		binarizedPixels = (unsigned char*)malloc(sizeof(unsigned char) * (int)self.bufferSize.width * (int)self.bufferSize.height);
		
		// fit to view
		float ratio = self.bufferSize.width / self.bufferSize.height;
		cameraImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, (int)self.view.frame.size.width, (int)self.view.frame.size.width * ratio)];
		[self.view addSubview:cameraImageView];
		[cameraImageView release];
    }
    return self;
}

#pragma mark - CameraViewControllerDelegate

- (void)didUpdateBufferCameraViewController:(CameraViewController*)CameraViewController {
#ifdef _TEST_COLOR
	_tic();
	int width = self.bufferSize.width;
	int height = self.bufferSize.height;
	
	for (int y = 0; y < height; y++) {
		for (int x = 0; x < width; x++) {
			int k = (buffer[4 * y * width + 4 * x + 0] >> 2) + (buffer[4 * y * width + 4 * x + 1] >> 1) + (buffer[4 * y * width + 4 * x + 2] >> 2);
			binarizedPixels[y * width + x] = k;
		}
	}
	_tocp();
	
	_tic();
	// Make CGImage from pixel array, with Quartz Help Library
	CGImageRef imageRef = CGImageGrayColorCreateWithGrayPixelBuffer(binarizedPixels, width, height);
	_tocp();
	
	_tic();
	
	// Have to update UIImageView with CGImageRef on main-thread.
	if (![NSThread isMainThread]) {
		dispatch_sync(dispatch_get_main_queue(), ^{
			[cameraImageView setImage:[UIImage imageWithCGImage:imageRef]];
		});
	}
	else {
		[cameraImageView setImage:[UIImage imageWithCGImage:imageRef]];
	}
	
	_tocp();
	
	// release image
	CGImageRelease(imageRef);
#else
	_tic();
	int width = self.bufferSize.width;
	int height = self.bufferSize.height;
	int threshold = 120;
	for (int y = 0; y < height; y++) {
		for (int x = 0; x < width; x++) {
			binarizedPixels[y * width + x] = buffer[y * width + x] > threshold ? 255 : 0;
		}
	}
	_tocp();
	
	_tic();
	// Make CGImage from pixel array, with Quartz Help Library
	CGImageRef imageRef = CGImageGrayColorCreateWithGrayPixelBuffer(binarizedPixels, width, height);
	_tocp();
	
	_tic();
	
	// Have to update UIImageView with CGImageRef on main-thread.
	if (![NSThread isMainThread]) {
		dispatch_sync(dispatch_get_main_queue(), ^{
			[cameraImageView setImage:[UIImage imageWithCGImage:imageRef]];
		});
	}
	else {
		[cameraImageView setImage:[UIImage imageWithCGImage:imageRef]];
	}
	
	_tocp();
	
	// release image
	CGImageRelease(imageRef);
#endif
}

#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
	
	NSAutoreleasePool *pool = nil;
	if (![NSThread isMainThread])
		pool = [NSAutoreleasePool new];
	
	CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
	
	if ([session isRunning]) {
		_tic();
		if ((type & BufferTypeMask) == BufferGrayColor) {
			size_t width= CVPixelBufferGetWidth(imageBuffer); 
			size_t height = CVPixelBufferGetHeight(imageBuffer); 
			
			CVPixelBufferLockBaseAddress(imageBuffer, 0);
			
			CVPlanarPixelBufferInfo_YCbCrBiPlanar *planar = CVPixelBufferGetBaseAddress(imageBuffer);
			
			size_t offset = NSSwapBigLongToHost(planar->componentInfoY.offset);
			
			unsigned char* baseAddress = (unsigned char *)CVPixelBufferGetBaseAddress(imageBuffer);
			unsigned char* pixelAddress = baseAddress + offset;
			
			if (buffer == NULL)
				buffer = (unsigned char*)malloc(sizeof(unsigned char) * width * height);
			
			memcpy(buffer, pixelAddress, sizeof(unsigned char) * width * height);
			
			CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
		}
		else if ((type & BufferTypeMask) == BufferRGBColor) {
			size_t width = CVPixelBufferGetWidth(imageBuffer);
			size_t height = CVPixelBufferGetHeight(imageBuffer); 
			CVPixelBufferLockBaseAddress(imageBuffer, 0);
			
			unsigned char* baseAddress = (unsigned char *)CVPixelBufferGetBaseAddress(imageBuffer);
			
			if (buffer == NULL)
				buffer = (unsigned char*)malloc(sizeof(unsigned char) * width * height * 4);
			
			memcpy(buffer, baseAddress, sizeof(unsigned char) * width * height * 4);
			CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
		}
		_tocp();
		if ([delegate respondsToSelector:@selector(didUpdateBufferCameraViewController:)])
			[delegate didUpdateBufferCameraViewController:self];
		
	}
	if (![NSThread isMainThread])
		[pool release];
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
	
	[self.view bringSubviewToFront:cameraImageView];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}

#pragma mark - dealloc

- (void)dealloc {
    free(binarizedPixels);
    [super dealloc];
}

@end
