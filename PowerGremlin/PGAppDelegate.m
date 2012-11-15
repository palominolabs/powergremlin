//
//  PGAppDelegate.m
//  PowerGremlin
//
//  Created by Manuel Wudka-Robles on 11/9/12.
//  Copyright (c) 2012 Palomino Labs, Inc. All rights reserved.
//

#import "PGAppDelegate.h"
#import "PGPowerDetailsTableViewController.h"

@implementation PGAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    PG_loadOSDBattery();

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = [PGPowerDetailsTableViewController new];
    [self.window makeKeyAndVisible];

    return YES;
}


@end
