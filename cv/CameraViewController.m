//
//  CameraViewController.m
//  cv
//
//  Created by sonson on 11/04/23.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CameraViewController.h"


@implementation CameraViewController

- (void)initCamera {
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
	[session setSessionPreset:AVCaptureSessionPreset1280x720];
	[session commitConfiguration];
	
	// setting preview layer
	previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:session];
}

#pragma mark -
#pragma mark AVCaptureVideoDataOutputSampleBufferDelegate

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
	if ([session isRunning]) {
		CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
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

- (void)dealloc
{
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	float width = self.view.frame.size.width;
	float height = self.view.frame.size.width / 9.0 * 16.0;
	
	previewLayer.frame = CGRectMake(0, 0, width, height);
	[self.view.layer addSublayer:previewLayer];
	[session startRunning];
	
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	CATransform3D m;
	CGRect f = previewLayer.frame;
	
	float offsetx = (f.size.height - f.size.width)/2;
	float offsety = (f.size.width - f.size.height)/2;
	
	switch(toInterfaceOrientation) {
		case UIInterfaceOrientationLandscapeLeft:
			m = CATransform3DMakeTranslation(offsetx, offsety, 0);
			m = CATransform3DRotate(m, M_PI/2, 0, 0, 1);
			previewLayer.transform = m;
			break;
		case UIInterfaceOrientationLandscapeRight:
			m = CATransform3DMakeTranslation(offsetx, offsety, 0);
			m = CATransform3DRotate(m, 3*M_PI/2, 0, 0, 1);
			previewLayer.transform = m;
			break;
		case UIInterfaceOrientationPortrait:
			m = CATransform3DMakeTranslation(0, -2, 0);
			m = CATransform3DRotate(m, 0, 0, 0, 1);
			previewLayer.transform = m;
			break;
		case UIInterfaceOrientationPortraitUpsideDown:
			m = CATransform3DMakeTranslation(0, -2, 0);
			m = CATransform3DRotate(m, M_PI, 0, 0, 1);
			previewLayer.transform = m;
			break;
	}

}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {

}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;//(interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
