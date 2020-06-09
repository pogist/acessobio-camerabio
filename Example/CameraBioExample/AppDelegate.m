//
//  AppDelegate.m
//  CameraBioExample
//
//  Created by Murilo Paixão on 09/06/20.
//  Copyright © 2020 Murilo Paixão. All rights reserved.
//

#import "AppDelegate.h"
#import <Firebase/Firebase.h>

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  // Override point for customization after application launch.
  [FIRApp configure];
  return YES;
}

@end
