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
-(void)addNewPreset;
-(void)updatePresetAtIndex:(NSUInteger)index withDictionary:(NSDictionary*)dictionary name:(NSString*)name thumbnail:(UIImage*)thumbnail progress:(ProgressBlock)progress;
-(void)removePresetAtIndex:(NSUInteger)index;
-(void)removePresetsAtIndexes:(NSIndexSet *)indexes;

-(Preset*)presetAtIndex:(NSUInteger)index;

@property (nonatomic, readonly) NSInteger selectedPresetIndex;

@end

@interface Preset : NSObject <NSCoding>

@property (readonly, strong) NSString       *name;
@property (readonly, strong) NSDictionary   *dictionary;
@property (readonly, strong) UIImage        *thumbnail;
@property (readonly, strong) NSDate         *saveDate;

-(instancetype)initWithDictionary:(NSDictionary*)dictionary name:(NSString*)name thumbnail:(UIImage*)thumbnail;
-(void)updateWithDictionary:(NSDictionary*)dictionary name:(NSString*)name thumbnail:(UIImage*)thumbnail;

@end