//
//  AppDelegate.h
//  ColaApp
//
//  Created by Chris on 11/02/2015.
//  Copyright (c) 2015 Chris Rivers. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <ColaLib/ColaLib.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate, COLAudioEnvironmentInfoDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, strong) COLAudioEnvironment *audioEnvironment;

@end

