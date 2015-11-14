//
//  PresetController.h
//  ColaApp
//
//  Created by Chris on 11/04/2015.
//  Copyright (c) 2015 Chris Rivers. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class Preset;
@interface PresetController : NSObject

typedef void (^ProgressBlock)(float progress);

+(PresetController*)sharedController;

-(void)loadPresets;

-(NSUInteger)presetCount;

-(Preset*)recallPresetAtIndex:(NSUInteger)index;
-(NSUInteger)addNewPreset;
-(void)updateSelectedPresetWithDictionary:(NSDictionary*)dictionary name:(NSString*)name thumbnail:(UIImage*)thumbnail progress:(ProgressBlock)progress;

-(void)removeFilesAtIndexes:(NSArray *)indexes;

-(Preset*)presetAtIndex:(NSUInteger)index;

@end

@interface Preset : NSObject <NSCoding>

@property (readonly, strong) NSString       *name;
@property (readonly, strong) NSDictionary   *dictionary;
@property (readonly, strong) UIImage        *thumbnail;
@property (readonly, strong) NSDate         *saveDate;

-(instancetype)initWithDictionary:(NSDictionary*)dictionary name:(NSString*)name thumbnail:(UIImage*)thumbnail;
-(void)updateWithDictionary:(NSDictionary*)dictionary name:(NSString*)name thumbnail:(UIImage*)thumbnail;

@end