//
//  CameraViewController.h
//  cv
//
//  Created by sonson on 11/04/23.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreGraphics/CoreGraphics.h>

@interface CameraViewController : UIViewController <AVCaptureVideoDataOutputSampleBufferDelegate> {
	AVCaptureSession				*session;
	AVCaptureVideoPreviewLayer		*previewLayer;
	float							aspectRatio;
}
@end
