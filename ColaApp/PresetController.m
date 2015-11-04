//
//  PresetController.m
//  ColaApp
//
//  Created by Chris on 11/04/2015.
//  Copyright (c) 2015 Chris Rivers. All rights reserved.
//

#define kPresetsKey @"kPresetsKey"
#define kNoPreset   -1

#import "PresetController.h"

@interface PresetController ()

@property (nonatomic) NSInteger         selectedPresetIndex;
@property (nonatomic, strong) NSArray   *presets;

@end

@implementation PresetController

+(PresetController*)sharedController {
    
    static PresetController *sharedController = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedController = [[PresetController alloc] init];
    });
    
    return sharedController;
}

-(instancetype)init {
    if (self = [super init]) {
        self.selectedPresetIndex = kNoPreset;
    }
    return self;
}

-(Preset*)recallPresetAtIndex:(NSUInteger)index {
    if (index < [self.presets count]) {
        NSLog(@"PresetController: Recalling preset %lu", (long)index);
        self.selectedPresetIndex = index;
        return [self.presets objectAtIndex:index];
    } else {
        return nil;
    }
}

-(void)loadPresets {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if ([userDefaults objectForKey:kPresetsKey]) {
        NSData *presetData = [userDefaults objectForKey:kPresetsKey];
        self.presets = [NSKeyedUnarchiver unarchiveObjectWithData:presetData];
        NSLog(@"PresetController: Recalled %lu preset(s)", (unsigned long)[self.presets count]);
    } else {
        NSLog(@"PresetController: Initializing factory presets");
        [self initFactoryPresets];
    }
}

-(void)initFactoryPresets {
    self.presets = @[[self getEmptyPreset]];
    [self syncPresets];
}

-(void)syncPresets {
    NSLog(@"PresetController: Syncing presets...");
    
    NSLog(@"PresetController: Archiving preset data...");
    NSData *presetData = [NSKeyedArchiver archivedDataWithRootObject:self.presets];
    
    NSLog(@"PresetController: %lu bytes.", (unsigned long)[presetData length]);
    
    NSLog(@"PresetController: Writing to UserDefaults...");
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:presetData forKey:kPresetsKey];
    
    NSLog(@"PresetController: Synchronizing...");
    [userDefaults synchronize];
    
    NSLog(@"PresetController: Presets synced.");
}

-(Preset*)getEmptyPreset {
    return [[Preset alloc] initWithDictionary:@{@"modules" : @{}, @"cables"  : @{}}
                                         name:@"Empty Preset"
                                    thumbnail:nil];
}

- (NSURL *)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory
                                                   inDomains:NSUserDomainMask] lastObject];
}

-(Preset*)presetAtIndex:(NSUInteger)index {
    return [self.presets objectAtIndex:index];
}

-(void)addNewPreset {
    NSMutableArray *mutablePresets = [[NSMutableArray alloc] initWithArray:self.presets];
    Preset *newPreset = [self getEmptyPreset];
    [mutablePresets addObject:newPreset];
    self.presets = [NSArray arrayWithArray:mutablePresets];
    
    [self syncPresets];
}

-(void)savePresetWithDictionary:(NSDictionary*)dictionary name:(NSString*)name thumbnail:(UIImage*)thumbnail {
    NSMutableArray *mutablePresets = [[NSMutableArray alloc] initWithArray:self.presets];
    Preset *newPreset = [[Preset alloc] initWithDictionary:dictionary name:name thumbnail:nil];
    [mutablePresets addObject:newPreset];
    self.presets = [NSArray arrayWithArray:mutablePresets];
    
    [self syncPresets];
}

-(void)updatePresetAtIndex:(NSUInteger)index withDictionary:(NSDictionary*)dictionary name:(NSString*)name thumbnail:(UIImage*)thumbnail progress:(ProgressBlock)progress {
    NSLog(@"PresetController: Updating preset %lu", (long)index);
    
    if (progress) {
        dispatch_async(dispatch_get_main_queue(), ^ {
            progress(0.33);
        });
    }

    Preset *preset = [self.presets objectAtIndex:index];
    
    if (progress) {
        dispatch_async(dispatch_get_main_queue(), ^ {
            progress(0.66);
        });
    }
    
    [preset updateWithDictionary:dictionary name:name thumbnail:thumbnail];
    if (progress) {
        dispatch_async(dispatch_get_main_queue(), ^ {
            progress(1.0);
        });
    }
    
    [self syncPresets];
    
    if (progress) {
        dispatch_async(dispatch_get_main_queue(), ^ {
            progress(1.0);
        });
    }
}

-(void)removePresetAtIndex:(NSUInteger)index {
    NSLog(@"PresetController: Removing preset %lu", (long)index);

    NSMutableArray *mutablePresets = [[NSMutableArray alloc] initWithArray:self.presets];
    [mutablePresets removeObjectAtIndex:index];
    self.presets = [NSArray arrayWithArray:mutablePresets];
    
    [self syncPresets];
    
    if (self.selectedPresetIndex == index) {
        self.selectedPresetIndex = kNoPreset;
    }
}

-(void)removePresetsAtIndexes:(NSIndexSet *)indexes {
    NSMutableArray *mutablePresets = [[NSMutableArray alloc] initWithArray:self.presets];
    [mutablePresets removeObjectsAtIndexes:indexes];
    self.presets = [NSArray arrayWithArray:mutablePresets];
    [self syncPresets];
    
    if ([indexes containsIndex:self.selectedPresetIndex]) {
        self.selectedPresetIndex = kNoPreset;
    }
}

-(NSUInteger)presetCount {
    return [self.presets count];
}

@end

@interface Preset ()

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSDictionary *dictionary;
@property (nonatomic, strong) UIImage *thumbnail;
@property (nonatomic, strong) NSDate *saveDate;

@end

#define kPresetNameKey          @"kPresetNameKey"
#define kPresetDictionaryKey    @"kPresetDictionaryKey"
#define kPresetThumbnailKey     @"kPresetThumbnailKey"
#define kPresetSaveDateKey      @"kPresetSaveDateKey"

@implementation Preset

-(instancetype)initWithDictionary:(NSDictionary*)dictionary name:(NSString*)name thumbnail:(UIImage*)thumbnail {
    if (self = [super init]) {
        self.name = name;
        self.dictionary = dictionary;
        self.thumbnail = thumbnail;
        self.saveDate = [NSDate date];
    }
    return self;
}

-(void)updateWithDictionary:(NSDictionary*)dictionary name:(NSString*)name thumbnail:(UIImage*)thumbnail {
    if (dictionary) {
        self.dictionary = dictionary;
        self.saveDate = [NSDate date];
    }
    
    if (name) {
        self.name = name;
    }
    
    if (thumbnail) {
        self.thumbnail = thumbnail;
    }
}

-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.name forKey:kPresetNameKey];
    [aCoder encodeObject:self.dictionary forKey:kPresetDictionaryKey];
    [aCoder encodeObject:self.thumbnail forKey:kPresetThumbnailKey];
    [aCoder encodeObject:self.saveDate forKey:kPresetSaveDateKey];
}

-(id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.name = [aDecoder decodeObjectForKey:kPresetNameKey];
        self.dictionary = [aDecoder decodeObjectForKey:kPresetDictionaryKey];
        self.thumbnail = [aDecoder decodeObjectForKey:kPresetThumbnailKey];
        self.saveDate = [aDecoder decodeObjectForKey:kPresetSaveDateKey];
    }
    return self;
}

@end

