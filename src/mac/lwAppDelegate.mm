//
//  lwAppDelegate.m
//  lw
//
//  Created by Li Wei on 11-4-2.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "lwAppDelegate.h"
#import "EAGLView.h"
#import "lwViewController.h"
#include "app.h"

LWApp* g_pApp = NULL;

@implementation lwAppDelegate

@synthesize window=_window;

@synthesize viewController=_viewController;

namespace {
    UIViewController* g_viewController = nil;
}

UIViewController* getViewController(){
    return g_viewController;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    g_viewController = self.viewController;
    g_pApp = new LWApp;
    g_pApp->init();
    // Override point for customization after application launch.
    self.window.rootViewController = self.viewController;
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
    [self.viewController stopAnimation];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
    [self.viewController startAnimation];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
    g_pApp->quit();
    delete g_pApp;
    [self.viewController stopAnimation];
}

- (void)dealloc
{
    [_window release];
    [_viewController release];
    [super dealloc];
}


@end
