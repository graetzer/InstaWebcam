//
//  SGVideoViewController.m
//  InstantWebcam
//
//  Created by Simon Grätzer on 17.09.13.
//  Copyright (c) 2013 Simon Grätzer. All rights reserved.
//

#import "SGVideoViewController.h"
#import "SGVideoDriver.h"

@implementation SGVideoViewController

- (void)loadView {
    [super loadView];
    
    __strong AVCaptureVideoPreviewLayer *avLayer = [AVCaptureVideoPreviewLayer layerWithSession:
                                                    [SGVideoDriver shared].captureSession];
    avLayer.frame = self.view.bounds;
    avLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.view.layer addSublayer:avLayer];
    _previewLayer = avLayer;
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    [self _layout:self.interfaceOrientation];
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscape;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [self _layout:toInterfaceOrientation];
}

- (void)_layout:(UIInterfaceOrientation)orientation {
    _previewLayer.frame = self.view.bounds;
    if (orientation == UIInterfaceOrientationLandscapeLeft) {
        _previewLayer.connection.videoOrientation = AVCaptureVideoOrientationLandscapeLeft;
    } else {
        _previewLayer.connection.videoOrientation = AVCaptureVideoOrientationLandscapeRight;
    }
    _previewLayer.position = CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds));
}

@end
