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
extern CGFloat kBuildViewPadding;
extern CGFloat kBuildViewRowHeight;
extern CGFloat kBuildViewColumnWidth;
extern CGFloat kKeyboardHeight;

#define ASSETS_PATH             @"ImageAssets/"
#define ASSETS_PATH_COMPONENTS  [ASSETS_PATH stringByAppendingString:@"components/"]
#define ASSETS_PATH_CONNECTORS  [ASSETS_PATH stringByAppendingString:@"connectors/"]
#define ASSETS_PATH_CONTROLS    [ASSETS_PATH stringByAppendingString:@"encoders/"]
#define TOOLBAR_BUILD_ICON_SELECTED         @"Icons/742-wrench-toolbar-selected"
#define TOOLBAR_BUILD_ICON                  @"Icons/742-wrench-toolbar"
#define TOOLBAR_PIANO_ICON_SELECTED         @"Icons/967-piano-toolbar-selected"
#define TOOLBAR_PIANO_ICON                  @"Icons/967-piano-toolbar"
#define TOOLBAR_FILES_ICON                  @"Icons/928-inbox-files-toolbar"
#define TOOLBAR_COPY_ICON                   @"Icons/808-documents-toolbar"
#define TOOLBAR_PLAY_ICON                   @"Icons/1241-play-toolbar"
#define TOOLBAR_STOP_ICON                   @"Icons/1243-stop-toolbar"
#define TOOLBAR_SAVE_ICON                   @"Icons/785-floppy-disk-toolbar"

// Transport Buttons
#define TRANSPORT_ICON_PLAY         @"Icons/Transport/play_button"
#define TRANSPORT_ICON_PAUSE        @"Icons/Transport/pause_button"
#define TRANSPORT_ICON_RECORD       @"Icons/Transport/record_button"
#define TRANSPORT_ICON_RECORD_ON    @"Icons/Transport/record_button_on"
#define TRANSPORT_ICON_REWIND       @"Icons/Transport/rewind_button"
#define TRANSPROT_ICON_REWIND_ON    @"Icons/Transport/rewind_button_on"

// Preset Dictionary Keys
#define PRESET_KEY_MODULES              @"MODULES"
#define PRESET_KEY_MODULE_CENTER        @"MODULE_CENTER"
#define PRESET_KEY_MODULE_TYPE          @"MODULE_TYPE"
#define PRESET_KEY_MODULE_IDENTIFIER    @"MODULE_ID"
#define PRESET_KEY_MODULE_CONTROLS      @"MODULE_CONTROLS"
#define PRESET_KEY_CONTROL_PARAMETER    @"CONTROL_PARAMETER"
#define PRESET_KEY_CONTROL_VALUE        @"CONTROL_VALUE"
#define PRESET_KEY_CABLES               @"CABLES"
#define PRESET_KEY_CABLE_INPUT          @"CABLE_INPUT"
#define PRESET_KEY_CABLE_OUTPUT         @"CABLE_OUTPUT"

