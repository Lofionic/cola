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

@interface AppDelegate ()

@end

CGFloat kComponentShelfHeight;
CGFloat kToolbarHeight;
CGFloat kBuildViewWidth;
CGFloat kBuildViewColumnWidth;
CGFloat kBuildViewRowHeight;
NSArray *componentCatalog;

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [self initLayoutMetrics];
    [self initComponentCatalog];
    
    // Start audio engine
    [[COLAudioEnvironment sharedEnvironment] start];
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [self.window setBackgroundColor:[UIColor blackColor]];
    [self.window makeKeyAndVisible];
    
    BuildViewController *buildViewController = [[BuildViewController alloc] init];
    [self.window setRootViewController:buildViewController];
    
    return YES;
}

- (void)initLayoutMetrics {
    // Setup metrics
    kBuildViewWidth =       768;
    kBuildViewColumnWidth = 96;
    kBuildViewRowHeight =   320;
    kToolbarHeight =        64;
    kComponentShelfHeight = 120;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        kBuildViewWidth =           320;
        kBuildViewColumnWidth =     64;
    }
}

- (void)initComponentCatalog {
    NSURL *componentCatalogURL = [[NSBundle mainBundle] URLForResource:@"componentCatalog" withExtension:@"json"];
    if (componentCatalogURL) {
        NSError *dataError;
        NSData *componentCatalogData = [NSData dataWithContentsOfURL:componentCatalogURL options:0 error:&dataError];
        if (!dataError && componentCatalogData) {
            NSError *dictError;
            NSDictionary *componentCatalogJSON = [NSJSONSerialization JSONObjectWithData:componentCatalogData options:0 error:&dictError];
            if (!dictError && componentCatalogJSON) {
                NSArray *components = [componentCatalogJSON objectForKey:@"components"];
                __block NSMutableArray *componentDescriptions = [[NSMutableArray alloc] initWithCapacity:[components count]];
                
                [components enumerateObjectsUsingBlock:^(id obj, NSUInteger index, BOOL *stop) {
                    NSDictionary *componentDictionary = (NSDictionary*)obj;
                    [componentDescriptions addObject:[[ComponentDescription alloc] initWithDictionary:componentDictionary]];
                }];
                    
                componentCatalog = [NSArray arrayWithArray:componentDescriptions];
            }
        }
    }
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
             kDictionaryKeyComponentName : @"Cola Demo App",
             kDictionaryKeyComponentMaufacturer : @"lfnc"
             };
}

@end
