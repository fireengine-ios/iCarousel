//
//  AppDelegate.m
//  Depo
//
//  Created by Mahir on 9/18/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "AppDelegate.h"
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import <DropboxSDK/DropboxSDK.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <AVFoundation/AVFoundation.h>
#import "SDImageCache.h"

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    _window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    application.statusBarHidden = NO;
    application.statusBarStyle = UIStatusBarStyleLightContent;
    
    [Fabric with:@[[Crashlytics class]]];
    
    RouterVC *router = [[RouterVC alloc] init];
    _window.rootViewController = [router vcForCurrentState];
    [self.window makeKeyAndVisible];
    
    [AppConfigurator applicationStarted];
    
    // Facebook
    [[FBSDKApplicationDelegate sharedInstance] application:application didFinishLaunchingWithOptions:launchOptions];
    
    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    if ([[DBSession sharedSession] handleOpenURL:url]) {
        if ([[DBSession sharedSession] isLinked]) {
            [[NSNotificationCenter defaultCenter] postNotificationName: @"DBDidLogin" object:nil];
            return YES;
        } else {
            [[NSNotificationCenter defaultCenter] postNotificationName: @"DBDidNotLogin" object:nil];
            return NO;
        }
    } else if ([[FBSDKApplicationDelegate sharedInstance] application:application openURL:url sourceApplication:sourceApplication annotation:annotation]) {
        return YES;
    }
    
    return NO;
}

- (void)applicationDidBecomeActive:(UIApplication *)application{
    [[ApplicationSessionManager shared] checkSession];
}

- (void)remoteControlReceivedWithEvent:(UIEvent *)receivedEvent {
    
    if (receivedEvent.type == UIEventTypeRemoteControl) {
        SingleSong *song = [SingleSong default];
        switch (receivedEvent.subtype) {
                
            case  UIEventSubtypeRemoteControlPlay:
                [song play];
                break;
            case   UIEventSubtypeRemoteControlPause:
                [song pause];
                break;
            case UIEventSubtypeRemoteControlTogglePlayPause:
                break;
            case UIEventSubtypeRemoteControlPreviousTrack:
                [song playBefore];
                break;
            case UIEventSubtypeRemoteControlNextTrack:
                [song playNext];
                break;
            default:
                break;
        }
    }
}
@end
