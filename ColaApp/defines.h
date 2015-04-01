//
//  defines.h
//  ColaApp
//
//  Created by Chris on 09/03/2015.
//  Copyright (c) 2015 Chris Rivers. All rights reserved.
//
#import <UIKit/UIKit.h>

extern CGFloat kComponentShelfHeight;
extern CGFloat kToolbarHeight;
extern CGFloat kBuildViewWidth;
extern CGFloat kBuildViewRowHeight;
extern CGFloat kBuildViewColumnWidth;

extern NSArray *moduleCatalog;

#define ASSETS_PATH             @"ImageAssets/"
#define ASSETS_PATH_COMPONENTS  [ASSETS_PATH stringByAppendingString:@"components/"]
#define ASSETS_PATH_CONNECTORS  [ASSETS_PATH stringByAppendingString:@"connectors/"]
#define ASSETS_PATH_CONTROLS    [ASSETS_PATH stringByAppendingString:@"encoders/"]