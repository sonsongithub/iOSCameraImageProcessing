/*
 * Real time image processing framework for iOS
 * CameraViewController.h
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

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreGraphics/CoreGraphics.h>

#define _MULTI_THREADING	// support multi-threading or not.

void _tic();				// not thread safe
double _toc();
double _tocp();				// with printf

typedef enum {
	BufferTypeMask				= 0x0f,
	BufferGrayColor				= 0,
	BufferRGBColor				= 1,
}CameraViewControllerType;

typedef enum {
	BufferSizeMask				= 0xf0,
	BufferSize1280x720			= 0 << 4,
	BufferSize640x480			= 1 << 4,
	BufferSize480x360			= 2 << 4,
	BufferSize192x144			= 3 << 4,
}CameraViewControllerSize;

typedef enum {
	MultiThreadingMask			= 0x100,
	NotSupportMultiThreading	= 0 << 5,
	SupportMultiThreading		= 1 << 5,
}CameraViewControllerMultiThreading;

@class CameraViewController;

@protocol CameraViewControllerDelegate <NSObject>
- (void)didUpdateBufferCameraViewController:(CameraViewController*)CameraViewController;
@end

@interface CameraViewController : UIViewController <AVCaptureVideoDataOutputSampleBufferDelegate> {
	CGSize							bufferSize;
	unsigned char					*buffer;
	AVCaptureSession				*session;
	AVCaptureVideoPreviewLayer		*previewLayer;
	float							aspectRatio;
	CameraViewControllerType		type;
	id<CameraViewControllerDelegate>delegate;
}
- (id)initWithCameraViewControllerType:(CameraViewControllerType)value;
@property (nonatomic, readonly) CGSize bufferSize;
@property (nonatomic, assign) id <CameraViewControllerDelegate> delegate;
@end
