/*
 * Real time image processing framework for iOS
 * CameraViewController.m
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

#import "CameraViewController.h"

#include <stdlib.h>
#include <stdio.h>
#include <sys/time.h>

static struct timeval _start, _end;

void _tic() {
	gettimeofday(&_start, NULL);
}

double _toc() {
	gettimeofday(&_end, NULL);
	long int e_sec = _end.tv_sec * 1000000 + _end.tv_usec;
	long int s_sec = _start.tv_sec * 1000000 + _start.tv_usec;
	return (double)((e_sec - s_sec) / 1000.0);
}

double _tocp() {
	gettimeofday(&_end, NULL);
	long int e_sec = _end.tv_sec * 1000000 + _end.tv_usec;
	long int s_sec = _start.tv_sec * 1000000 + _start.tv_usec;
	double t = (double)((e_sec - s_sec) / 1000.0);
	printf("%6.3f\n", t);
	return t;
}

@implementation CameraViewController

@synthesize delegate, bufferSize;

#pragma mark - Instance method

- (void)prepareWithCameraViewControllerType:(CameraViewControllerType)value {
	//
	type = value;
	
	NSString *sessionPreset = nil;
	int pixelFormat = 0;
	
	// decide camera type
	switch (type & BufferSizeMask) {
		case BufferSize1280x720:
			sessionPreset = AVCaptureSessionPreset1280x720;
			bufferSize = CGSizeMake(1280, 720);
			break;
		case BufferSize640x480:
			sessionPreset = AVCaptureSessionPreset640x480;
			bufferSize = CGSizeMake(640, 480);
			break;
		case BufferSize480x360:
			sessionPreset = AVCaptureSessionPresetMedium;
			bufferSize = CGSizeMake(480, 360);
			break;
		case BufferSize192x144:
			sessionPreset = AVCaptureSessionPresetLow;
			bufferSize = CGSizeMake(192, 144);
			break;
		default:
			sessionPreset = AVCaptureSessionPreset640x480;
			break;
	}
	
	// decide camera pixel type
	switch (type & BufferTypeMask) {
		case BufferGrayColor:
			pixelFormat = kCVPixelFormatType_420YpCbCr8BiPlanarFullRange;
			break;
		case BufferRGBColor:
			pixelFormat = kCVPixelFormatType_32BGRA;
			break;
		default:
			pixelFormat = kCVPixelFormatType_420YpCbCr8BiPlanarFullRange;
			break;
	}
	
	// set background color
	[self.view setBackgroundColor:[UIColor blackColor]];
	
	NSError *error = nil;
	
	// make capture session
	session = [[AVCaptureSession alloc] init];
	
	// get default video device
	AVCaptureDevice * videoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
	
	// setup video input
	AVCaptureDeviceInput *videoInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:&error];
	
	// setup video output
	NSDictionary *settingInfo = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:pixelFormat] forKey:(id)kCVPixelBufferPixelFormatTypeKey];
	
	AVCaptureVideoDataOutput * videoDataOutput = [[[AVCaptureVideoDataOutput alloc] init] autorelease];
	[videoDataOutput setAlwaysDiscardsLateVideoFrames:YES];
	[videoDataOutput setMinFrameDuration:CMTimeMake(1, 30)];
	[videoDataOutput setVideoSettings:settingInfo];	

	// support multi-threading
	if ((type & MultiThreadingMask) == SupportMultiThreading) {
		dispatch_queue_t queue = dispatch_queue_create("captureQueue", NULL);
		[videoDataOutput setSampleBufferDelegate:self queue:queue];
		dispatch_release(queue);
	}
	else {
		[videoDataOutput setSampleBufferDelegate:self queue:dispatch_get_main_queue()];
	}
	
	// attach video to session
	[session beginConfiguration];
	[session addInput:videoInput];
	[session addOutput:videoDataOutput];
	[session setSessionPreset:sessionPreset];
	[session commitConfiguration];
	
	if ([session.sessionPreset isEqualToString:AVCaptureSessionPreset1280x720]) {
		aspectRatio = 16.0 / 9.0;
	}
	else {
		aspectRatio = 4.0 / 3.0;
	}
		
	// setting preview layer
	previewView = [[UIView alloc] initWithFrame:CGRectZero];
	[previewView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
	
	previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:session];
}

- (id)initWithCameraViewControllerType:(CameraViewControllerType)value {
    self = [super initWithNibName:nil bundle:nil];
	if (self) {
        // Custom initialization
		[self prepareWithCameraViewControllerType:value];
	}
	return self;
}

- (void)adjustCameraPreviewLayerOrientaion:(UIInterfaceOrientation)orientation {
	CATransform3D m;
	CGRect f = previewLayer.frame;
	
	float offsetx = (f.size.height - f.size.width)/2;
	float offsety = (f.size.width - f.size.height)/2;
	
	switch(orientation) {
		case UIInterfaceOrientationLandscapeLeft:
			m = CATransform3DMakeTranslation(offsetx, offsety, 0);
			m = CATransform3DRotate(m, M_PI/2, 0, 0, 1);
			break;
		case UIInterfaceOrientationLandscapeRight:
			m = CATransform3DMakeTranslation(offsetx, offsety, 0);
			m = CATransform3DRotate(m, 3 * M_PI/2, 0, 0, 1);
			break;
		case UIInterfaceOrientationPortrait:
			m = CATransform3DMakeTranslation(0, -2, 0);
			m = CATransform3DRotate(m, 0, 0, 0, 1);
			break;
		case UIInterfaceOrientationPortraitUpsideDown:
			m = CATransform3DMakeTranslation(0, -2, 0);
			m = CATransform3DRotate(m, M_PI, 0, 0, 1);
			break;
		default:
			m = CATransform3DMakeTranslation(0, -2, 0);
			m = CATransform3DRotate(m, 0, 0, 0, 1);
			break;
	}
	
	previewLayer.transform = m;
}

- (void)waitForSessionStopRunning {
	// this is magical code
	// if you want to remove session object and preview layer, you have to wait some minitunes like following code.
	// maybe, this is bug.
	while ([session isRunning]) {
		NSLog(@"waiting...");
		[session stopRunning];
		[NSThread sleepForTimeInterval:0.1];
	}
	[previewLayer removeFromSuperlayer];
}

#pragma mark - Override

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
		[self prepareWithCameraViewControllerType:BufferGrayColor|BufferSize640x480];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
		[self prepareWithCameraViewControllerType:BufferGrayColor|BufferSize640x480];
    }
    return self;
}

#pragma mark - View lifecycle

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	float width = self.view.frame.size.width;
	float height = self.view.frame.size.width * aspectRatio;
	
	previewLayer.frame = CGRectMake(0, 0, width, height);
	[previewView.layer addSublayer:previewLayer];
	[self.view addSubview:previewView];
	[session startRunning];
	
	[self adjustCameraPreviewLayerOrientaion:self.interfaceOrientation];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	[self waitForSessionStopRunning];
}

#pragma mark - To support orientaion

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	[self adjustCameraPreviewLayerOrientaion:toInterfaceOrientation];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
	// for orientation test
	//return YES;
}

#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
	NSAutoreleasePool *pool = nil;
	if (![NSThread isMainThread])
		pool = [NSAutoreleasePool new];
	
	CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
	
	if ([session isRunning]) {
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
		if ([delegate respondsToSelector:@selector(didUpdateBufferCameraViewController:)])
			[delegate didUpdateBufferCameraViewController:self];
		
	}
	if (![NSThread isMainThread])
		[pool release];
}

#pragma mark - dealloc

- (void)dealloc {
	free(buffer);
	[session release];
	[previewView release];
    [super dealloc];
}

@end
