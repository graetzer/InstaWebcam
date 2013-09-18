//
//  SGVideoDriver.h
//  iDriveRobot
//
//  Created by Simon Grätzer on 31.07.13.
//  Copyright (c) 2013 Simon Grätzer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreVideo/CoreVideo.h>

@interface SGVideoDriver : NSObject  <AVCaptureVideoDataOutputSampleBufferDelegate>

/*!
 @brief The capture session takes the input from the camera and capture it
 */
@property (nonatomic, readonly) AVCaptureSession *captureSession;

+ (SGVideoDriver *)shared;

- (NSData *)jpegImage;
- (void)start;
- (void)stop;
- (int32_t)videoWidth;
- (int32_t)videoHeight;

@end
