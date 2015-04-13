//
//  PresetController.h
//  ColaApp
//
//  Created by Chris on 11/04/2015.
//  Copyright (c) 2015 Chris Rivers. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PresetController : NSObject

+(PresetController*)sharedController;
-(void)loadPresets;

@end

@interface Preset : NSObject

@property (readonly, strong) NSString *name;
@property (readonly, strong) NSDictionary *dictionary;

-(instancetype)initWithName:(NSString*)name dictionary:(NSDictionary*)dictionary;
-(NSArray*)getPresetNames;
-(Preset*)getSelectedPreset;

@end