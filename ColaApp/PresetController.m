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

@property (nonatomic) NSInteger         currentPreset;
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
        self.currentPreset = kNoPreset;
    }
    return self;
}

-(Preset*)recallPresetAtIndex:(NSUInteger)index {
    if (index < [self.presets count]) {
        NSLog(@"Recalling preset %lu", (long)index);
        self.currentPreset = index;
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
        NSLog(@"Recalled %lu preset(s)", (unsigned long)[self.presets count]);
    } else {
        NSLog(@"Initializing factory presets");
        [self initFactoryPresets];
    }
}

-(void)initFactoryPresets {
    self.presets = @[[self getEmptyPreset]];
    [self syncPresets];
}

-(void)syncPresets {
    NSData *presetData = [NSKeyedArchiver archivedDataWithRootObject:self.presets];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:presetData forKey:kPresetsKey];
    
    [userDefaults synchronize];
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

-(NSInteger)selectedPresetIndex {
    return self.currentPreset;
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
    Preset *newPreset = [[Preset alloc] initWithDictionary:dictionary name:name thumbnail:thumbnail];
    [mutablePresets addObject:newPreset];
    self.presets = [NSArray arrayWithArray:mutablePresets];
    
    [self syncPresets];
}

-(void)updatePresetAtIndex:(NSUInteger)index withDictionary:(NSDictionary*)dictionary name:(NSString*)name thumbnail:(UIImage*)thumbnail {
    NSLog(@"Updating preset %lu", (long)index);
    
    Preset *preset = [self.presets objectAtIndex:index];
    [preset updateWithDictionary:dictionary name:name thumbnail:thumbnail];
    
    [self syncPresets];
}

-(void)removePresetAtIndex:(NSUInteger)index {
    NSLog(@"Removing preset %lu", (long)index);

    NSMutableArray *mutablePresets = [[NSMutableArray alloc] initWithArray:self.presets];
    [mutablePresets removeObjectAtIndex:index];
    self.presets = [NSArray arrayWithArray:mutablePresets];
    
    [self syncPresets];
    
    if (self.selectedPresetIndex == index) {
        self.currentPreset = kNoPreset;
    }
}

-(void)removePresetsAtIndexes:(NSIndexSet *)indexes {
    NSMutableArray *mutablePresets = [[NSMutableArray alloc] initWithArray:self.presets];
    [mutablePresets removeObjectsAtIndexes:indexes];
    self.presets = [NSArray arrayWithArray:mutablePresets];
    [self syncPresets];
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

