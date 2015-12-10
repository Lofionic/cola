//
//  AppDelegate.m
//  ColaApp
//
//  Created by Chris on 11/02/2015.
//  Copyright (c) 2015 Chris Rivers. All rights reserved.
//
#import "defines.h"
#import "AppDelegate.h"
#import "BuildViewController.h"
#import "ModuleDescription.h"
#import "ModuleCatalog.h"
#import "PresetController.h"
#import "FilesViewController.h"

@interface AppDelegate ()

@end

CGFloat kComponentShelfHeight;
CGFloat kBuildViewWidth;
CGFloat kBuildViewPadding;
CGFloat kBuildViewColumnWidth;
CGFloat kBuildViewRowHeight;
CGFloat kKeyboardHeight;

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [self initLayoutMetrics];
    
    // Initialize module catalog
    [[ModuleCatalog sharedCatalog] loadFromURL:[[NSBundle mainBundle] URLForResource:@"moduleCatalog" withExtension:@"json"]];
    
    // Initialize presets
    [[PresetController sharedController] loadPresets];
    
    // Start audio engine
    [[COLAudioEnvironment sharedEnvironment] start];
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [self.window setBackgroundColor:[UIColor blackColor]];
    [self.window makeKeyAndVisible];
    
    BuildViewController *buildViewController = [[BuildViewController alloc] init];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:buildViewController];
    
//    FilesViewController *fvc = [[FilesViewController alloc] initWithBuildViewController:nil];
//    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:fvc];
    
    [navigationController.navigationBar setBarStyle:UIBarStyleBlackTranslucent];
    [navigationController.navigationBar setTintColor:[UIColor whiteColor]];

    [self.window setRootViewController:navigationController];
    
    return YES;
}

- (void)initLayoutMetrics {
    // Setup metrics
    kBuildViewPadding =     24;
    kBuildViewColumnWidth = 90;
    kBuildViewRowHeight =   320;
    kComponentShelfHeight = 150;
    kKeyboardHeight =       150;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        kBuildViewPadding =         12;
        kBuildViewColumnWidth =     72;
        kBuildViewRowHeight =       256;
    }
    
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    CGFloat screenWidth = MIN(screenSize.width, screenSize.height);
    
    NSInteger widthInModules = floor((screenWidth - (kBuildViewPadding * 2)) / kBuildViewColumnWidth);
    kBuildViewWidth = (widthInModules * kBuildViewColumnWidth);
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

-(NSDictionary *)interAppInfoDictionary {
    return @{
             kDictionaryKeyComponentName : @"Cola Out",
             kDictionaryKeyComponentMaufacturer : @"lfnc"
             };
}

@end
