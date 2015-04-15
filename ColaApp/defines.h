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

#define ASSETS_PATH             @"ImageAssets/"
#define ASSETS_PATH_COMPONENTS  [ASSETS_PATH stringByAppendingString:@"components/"]
#define ASSETS_PATH_CONNECTORS  [ASSETS_PATH stringByAppendingString:@"connectors/"]
#define ASSETS_PATH_CONTROLS    [ASSETS_PATH stringByAppendingString:@"encoders/"]

#define TOOLBAR_BUILD_ICON_SELECTED         @"Icons/742-wrench-toolbar-selected"
#define TOOLBAR_BUILD_ICON                  @"Icons/742-wrench-toolbar"

#define TOOLBAR_FILES_ICON                  @"Icons/928-inbox-files-toolbar"

#define TOOLBAR_NEW_ICON                    @"Icons/709-plus-toolbar"