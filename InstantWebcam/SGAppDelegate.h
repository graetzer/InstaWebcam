//
//  SGAppDelegate.h
//  InstantWebcam
//
//  Created by Simon Grätzer on 16.09.13.
//  Copyright (c) 2013 Simon Grätzer. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GCDWebServer, SGVideoViewController;

@interface SGAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) GCDWebServer *webserver;
@property (strong, nonatomic) SGVideoViewController *videoController;

@end
