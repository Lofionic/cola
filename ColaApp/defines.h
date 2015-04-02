//
//  defines.h
//  ColaApp
//
//  Created by Chris on 09/03/2015.
//  Copyright (c) 2015 Chris Rivers. All rights reserved.
//
#import <UIKit/UIKit.h>

extern CGFloat kComponentShelfHeight;
extern CGFloat kBuildViewWidth;
extern CGFloat kBuildViewRowHeight;
extern CGFloat kBuildViewColumnWidth;
extern CGFloat kKeyboardHeight;

extern NSArray *moduleCatalog;

#define ASSETS_PATH             @"ImageAssets/"
#define ASSETS_PATH_COMPONENTS  [ASSETS_PATH stringByAppendingString:@"components/"]
#define ASSETS_PATH_CONNECTORS  [ASSETS_PATH stringByAppendingString:@"connectors/"]
#define ASSETS_PATH_CONTROLS    [ASSETS_PATH stringByAppendingString:@"encoders/"]

#define TOOLBAR_BUILD_ICON_SELECTED         @"Icons/742-wrench-toolbar-selected"
#define TOOLBAR_BUILD_ICON                  @"Icons/742-wrench-toolbar"
#define TOOLBAR_KEYBOARD_ICON_SELECTED      @"Icons/967-piano-toolbar-selected"