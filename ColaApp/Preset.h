//
//  PresetController.h
//  ColaApp
//
//  Created by Chris on 11/04/2015.
//  Copyright (c) 2015 Chris Rivers. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Preset : NSObject <NSCoding>

typedef void (^ProgressBlock)(float progress);

@property (readonly, strong) NSDictionary   *dictionary;
@property (readonly, strong) UIImage        *thumbnail;

-(instancetype)initWithDictionary:(NSDictionary*)dictionary thumbnail:(UIImage*)thumbnail;

+(NSString*)presetsPath;
+(NSArray*)getPresets;
+(NSDate*)getDateForPreset:(NSString*)preset;
+(void)fetchThumbnailForPreset:(NSString*)preset onCompletion:(void (^)(NSString *presetPath, UIImage *image))completion;
+(NSString*)fullPathForPreset:(NSString*)preset;

+(Preset*)loadPreset:(NSString*)preset;
+(BOOL)savePresetWithName:(NSString*)presetName
               dictionary:(NSDictionary*)dictionary
                thumbnail:(UIImage*)thumbnail
                overwrite:(BOOL)overwrite
                 progress:(ProgressBlock)progress;
+(BOOL)renamePreset:(NSString*)oldName to:(NSString*)newName;
+(BOOL)removePreset:(NSString*)presetName;

+(NSString*)getNewFilename;
+(BOOL)isFilenameUnique:(NSString*)filename ;

@end