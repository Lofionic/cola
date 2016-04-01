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
-(void)updateSelectedPresetWithDictionary:(NSDictionary*)dictionary thumbnail:(UIImage*)thumbnail progress:(ProgressBlock)progress;

-(void)removeFilesAtIndexes:(NSArray *)indexes;
-(void)renameFileAtIndex:(NSUInteger)index to:(NSString*)newFilename;
-(Preset*)presetAtIndex:(NSUInteger)index;

-(NSString*)nameOfPresetAtIndex:(NSUInteger)index;
-(NSDate*)dateOfPresetAtIndex:(NSUInteger)index;
-(void)fetchThumbnailForPresetAtIndex:(NSUInteger)index onCompletion:(void (^)(NSUInteger index, UIImage *image))completion;



@end

@interface Preset : NSObject <NSCoding>

@property (readonly, strong) NSDictionary   *dictionary;
@property (readonly, strong) UIImage        *thumbnail;

-(instancetype)initWithDictionary:(NSDictionary*)dictionary thumbnail:(UIImage*)thumbnail;
-(void)updateWithDictionary:(NSDictionary*)dictionary thumbnail:(UIImage*)thumbnail;

@end