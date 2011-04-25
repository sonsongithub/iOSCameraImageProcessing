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


@implementation CameraViewController

- (void)initCamera {
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
	NSDictionary *settingInfo = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCVPixelFormatType_420YpCbCr8BiPlanarFullRange] forKey:(id)kCVPixelBufferPixelFormatTypeKey];
	
	AVCaptureVideoDataOutput * videoDataOutput = [[[AVCaptureVideoDataOutput alloc] init] autorelease];
	[videoDataOutput setAlwaysDiscardsLateVideoFrames:YES];
	[videoDataOutput setMinFrameDuration:CMTimeMake(1, 30)];
	[videoDataOutput setVideoSettings:settingInfo];	
	[videoDataOutput setSampleBufferDelegate:self queue:dispatch_get_main_queue()];
	
	// attach video to session
	[session beginConfiguration];
	[session addInput:videoInput];
	[session addOutput:videoDataOutput];
	[session setSessionPreset:AVCaptureSessionPreset640x480];
	[session commitConfiguration];
	
	if ([session.sessionPreset isEqualToString:AVCaptureSessionPreset1280x720]) {
		aspectRatio = 16.0 / 9.0;
	}
	else {
		aspectRatio = 4.0 / 3.0;
	}
	
	// setting preview layer
	previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:session];
}

#pragma mark -
#pragma mark AVCaptureVideoDataOutputSampleBufferDelegate

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
	if ([session isRunning]) {
//		CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
	}
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
		[self initCamera];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
		[self initCamera];
    }
    return self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
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

#pragma mark - View lifecycle

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	float width = self.view.frame.size.width;
	float height = self.view.frame.size.width * aspectRatio;
	
	previewLayer.frame = CGRectMake(0, 0, width, height);
	[self.view.layer addSublayer:previewLayer];
	[session startRunning];
	
	[self adjustCameraPreviewLayerOrientaion:self.interfaceOrientation];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	
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

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	[self adjustCameraPreviewLayerOrientaion:toInterfaceOrientation];
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// defulat settings.
	// return (interfaceOrientation == UIInterfaceOrientationPortrait);
    return YES;
}

- (void)dealloc {
	[session release];
    [super dealloc];
}

@end
