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

-(void)loadPresets {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if ([userDefaults objectForKey:kPresetsKey]) {
        self.presets = [userDefaults objectForKey:kPresetsKey];
        NSLog(@"Recalled %u preset(s)", [self.presets count]);
    } else {
        NSLog(@"Initializing factory presets");
        [self initFactoryPresets];
    }
}

-(void)initFactoryPresets {
    self.presets = @[[self getEmptyPreset]];
    [self storePresets];
}

-(void)storePresets {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:self.presets forKey:kPresetsKey];
    
    [userDefaults synchronize];
}

-(Preset*)getEmptyPreset {
    return [[Preset alloc] initWithName:@"Default"
                             dictionary:@{@"modules" : @[], @"cables"  : @[]}];
}

- (NSURL *)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory
                                                   inDomains:NSUserDomainMask] lastObject];
}


-(NSArray*)getPresetNames {
    NSMutableArray *presetNames = [[NSMutableArray alloc] initWithCapacity:[self.presets count]];
    
    for (Preset *thisPreset in self.presets) {
        [presetNames addObject:thisPreset.name];
    }
    
    return [NSArray arrayWithArray:presetNames];
}

-(Preset*)getSelectedPreset {
    return [self.presets objectAtIndex:self.currentPreset];
}


@end

@interface Preset ()

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSDictionary *dictionary;

@end

@implementation Preset

-(instancetype)initWithName:(NSString*)name dictionary:(NSDictionary*)dictionary {
    if (self = [super init]) {
        self.name = name;
        self.dictionary = dictionary;
    }
    return self;
}

@end

