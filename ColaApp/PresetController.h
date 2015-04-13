//
//  PresetController.h
//  ColaApp
//
//  Created by Chris on 11/04/2015.
//  Copyright (c) 2015 Chris Rivers. All rights reserved.
//
#import <Foundation/Foundation.h>

@class Preset;
@interface PresetController : NSObject

+(PresetController*)sharedController;
-(void)loadPresets;
-(NSArray*)getPresetNames;
-(Preset*)getSelectedPreset;

@end

@interface Preset : NSObject <NSCoding>

@property (readonly, strong) NSString *name;
@property (readonly, strong) NSDictionary *dictionary;

-(instancetype)initWithName:(NSString*)name dictionary:(NSDictionary*)dictionary;

@end