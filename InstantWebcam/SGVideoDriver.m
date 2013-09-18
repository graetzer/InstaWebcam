//
//  SGVideoDriver.m
//  iDriveRobot
//
//  Created by Simon Grätzer on 31.07.13.
//  Copyright (c) 2013 Simon Grätzer. All rights reserved.
//

#import "SGVideoDriver.h"

@implementation SGVideoDriver{
    CMVideoDimensions _videoSize;
    BOOL _recording;
    
    NSData *_jpegImage;
}

+ (SGVideoDriver *)shared {
    static id shared;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        shared = [[self alloc] init];
    });
    return shared;
}

- (id)init {
    if (self = [super init]) {
        [self initCapture];
    }
    
    return self;
}

- (void)dealloc {
    [self stop];
}

- (void)initCapture {
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if (!device) {
        NSLog(@"Not running on a device with video camera!");
        exit(1);
    }
    
    AVCaptureDeviceInput *captureInput = [AVCaptureDeviceInput
                                          deviceInputWithDevice:device
                                          error:nil];
    /*We setupt the output*/
    AVCaptureVideoDataOutput *captureOutput = [[AVCaptureVideoDataOutput alloc] init];
    /*While a frame is processes in -captureOutput:didOutputSampleBuffer:fromConnection: delegate methods no other frames are added in the queue.
     If you don't want this behaviour set the property to NO */
    captureOutput.alwaysDiscardsLateVideoFrames = YES;
    
    /*We create a serial queue to handle the processing of our frames*/
    dispatch_queue_t queue = dispatch_queue_create("cameraQueue", DISPATCH_QUEUE_SERIAL);
    [captureOutput setSampleBufferDelegate:self queue:queue];
    
    // Set the video output to store frame in BGRA (It is supposed to be faster)
    NSDictionary* videoSettings = @{(id)kCVPixelBufferPixelFormatTypeKey : @(kCVPixelFormatType_32BGRA)};
    [captureOutput setVideoSettings:videoSettings];
    
    /*And we create a capture session*/
    _captureSession = [[AVCaptureSession alloc] init];
    /*We add input and output*/
    [self.captureSession addInput:captureInput];
    [self.captureSession addOutput:captureOutput];
    [self.captureSession setSessionPreset:AVCaptureSessionPreset640x480];
    _videoSize.width = 640;
    _videoSize.height = 480;
    
//    AVCaptureConnection *conn = [captureOutput connectionWithMediaType:AVMediaTypeVideo];
//    if (conn.isVideoMinFrameDurationSupported) conn.videoMinFrameDuration = CMTimeMake(1, 15);
//    if (conn.isVideoMaxFrameDurationSupported) conn.videoMaxFrameDuration = CMTimeMake(1, 15);
//    
//    
//    _videoSize.height = 0;
//    for (AVCaptureInputPort *port in captureInput.ports) {
//        if ([port mediaType] == AVMediaTypeVideo) {
//            _videoSize = CMVideoFormatDescriptionGetDimensions([port formatDescription]);
//            break;
//        }
//    }
//    if (_videoSize.height == 0) {
//        _videoSize.width = 480;
//        _videoSize.height = 360;
//    }
}

- (void)start {
    if (!self.captureSession.running) {
        _recording = YES;
        [self.captureSession startRunning];
    }
}

- (void)stop {
    if (self.captureSession.running) {
        _recording = NO;
        [self.captureSession stopRunning];
    }
}

- (int32_t)videoHeight {
    return _videoSize.height;
}

- (int32_t)videoWidth {
    return _videoSize.width;
}

- (NSData *)jpegImage {
    return _jpegImage;
}

#pragma mark - AVCaptureSession delegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection *)connection {
    
    UIImage *image = [self imageFromSampleBuffer:sampleBuffer];
    _jpegImage = UIImageJPEGRepresentation(image, 0.2);
}

// Create a UIImage from sample buffer data

- (UIImage *) imageFromSampleBuffer:(CMSampleBufferRef) sampleBuffer {
    
    // Get a CMSampleBuffer's Core Video image buffer for the media data
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    
    // Lock the base address of the pixel buffer
    CVPixelBufferLockBaseAddress(imageBuffer, 0);

    // Get the number of bytes per row for the pixel buffer
    void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
    // Get the number of bytes per row for the pixel buffer
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    
    // Get the pixel buffer width and height
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);

    // Create a device-dependent RGB color space
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    // Create a bitmap graphics context with the sample buffer data
    
    CGContextRef context = CGBitmapContextCreate(baseAddress, width, height, 8,
                                                 bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    
    // Create a Quartz image from the pixel data in the bitmap graphics context
    CGImageRef quartzImage = CGBitmapContextCreateImage(context);
    // Unlock the pixel buffer
    CVPixelBufferUnlockBaseAddress(imageBuffer,0);
    // Free up the context and color space
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    // Create an image object from the Quartz image
    UIImage *image = [UIImage imageWithCGImage:quartzImage];
    
    // Release the Quartz image
    CGImageRelease(quartzImage);
    return (image);
}

@end
