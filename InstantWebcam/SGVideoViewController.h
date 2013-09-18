//
//  SGVideoViewController.h
//  InstantWebcam
//
//  Created by Simon Grätzer on 17.09.13.
//  Copyright (c) 2013 Simon Grätzer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <QuartzCore/QuartzCore.h>

@interface SGVideoViewController : UIViewController

@property (weak, readonly) AVCaptureVideoPreviewLayer *previewLayer;

@end
