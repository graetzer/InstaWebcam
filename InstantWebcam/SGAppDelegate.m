//
//  SGAppDelegate.m
//  InstantWebcam
//
//  Created by Simon Grätzer on 16.09.13.
//  Copyright (c) 2013 Simon Grätzer. All rights reserved.
//

#import "SGAppDelegate.h"
#import "BLWebSocketsServer.h"
#import "GCDWebServer.h"
#import "SGVideoDriver.h"
#import "SGVideoViewController.h"

@implementation SGAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.webserver = [[GCDWebServer alloc] init];
    [self _setupWebServer];
    [self.webserver startWithPort:80 bonjourName:nil];
    [[SGVideoDriver shared] start];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    
    self.videoController = [SGVideoViewController new];
    self.window.rootViewController = self.videoController;
    [self.window makeKeyAndVisible];
    

    
    return YES;
}

- (void)_setupWebServer {
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Web" ofType:@"bundle"];
    [self.webserver addHandlerForBasePath:@"/"
                                localPath:path
                            indexFilename:@"index.html"
                                 cacheAge:3600];
    
    [self.webserver addHandlerForMethod:@"GET"
                                   path:@"/livefeed.jpeg"
                           requestClass:[GCDWebServerRequest class]
                           processBlock:^GCDWebServerResponse *(GCDWebServerRequest* request) {
                               return [GCDWebServerDataResponse responseWithData:[[SGVideoDriver shared] jpegImage]
                                                                     contentType:@"image/jpeg"];
                           }];
}

- (void)_setupWebSocket {
    //every request made by a client will trigger the execution of this block.
//    [[BLWebSocketsServer sharedInstance] setHandleRequestBlock:^NSData *(NSData *data) {
//        //simply echo what has been received
//        return data;
//    }];
//    //Start the server
//    [[BLWebSocketsServer sharedInstance] startListeningOnPort:9000 withProtocolName:@"my-protocol-name" andCompletionBlock:^(NSError *error) {
//        if (!error) {
//            NSLog(@"Server started");
//        } else {
//            NSLog(@"%@", error);
//        }
//    }];
//    //Push a message to every connected clients
//    [[BLWebSocketsServer sharedInstance] pushToAll:[@"pushed message" dataUsingEncoding:NSUTF8StringEncoding]];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    [[SGVideoDriver shared] stop];
    [self.webserver stop];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    [self.webserver startWithPort:80 bonjourName:nil];
    [[SGVideoDriver shared] start];
}


@end
