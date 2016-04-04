//
//  PresetController.m
//  ColaApp
//
//  Created by Chris on 11/04/2015.
//  Copyright (c) 2015 Chris Rivers. All rights reserved.
//

#import "Preset.h"
#import "NSString+Random.h"

#define FILE_EXTENSION @"col"

@interface Preset ()

@property (nonatomic, strong) NSDictionary *dictionary;
@property (nonatomic, strong) UIImage *thumbnail;

@end

#define kPresetDictionaryKey    @"kPresetDictionaryKey"
#define kPresetThumbnailKey     @"kPresetThumbnailKey"
#define kPresetSaveDateKey      @"kPresetSaveDateKey"

@implementation Preset

-(instancetype)initWithDictionary:(NSDictionary*)dictionary thumbnail:(UIImage*)thumbnail {
    if (self = [super init]) {
        self.dictionary = dictionary;
        self.thumbnail = thumbnail;
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.dictionary forKey:kPresetDictionaryKey];
    [aCoder encodeObject:self.thumbnail forKey:kPresetThumbnailKey];
}

-(id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.dictionary = [aDecoder decodeObjectForKey:kPresetDictionaryKey];
        self.thumbnail = [aDecoder decodeObjectForKey:kPresetThumbnailKey];
    }
    return self;
}

// Class methods
+(NSArray*)getPresets {
    NSFileManager *fm = [NSFileManager defaultManager];
    
    NSString *presetsPath = [self presetsPath];
    
    if (![fm fileExistsAtPath:presetsPath]) {
        NSLog(@"PresetController: Presets directory not found. Creating %@...", presetsPath);
        NSError *error;
        [fm createDirectoryAtPath:presetsPath withIntermediateDirectories:YES attributes:nil error:&error];
        if (error) {
            NSLog(@"PresetController: Error creating presets directory : %@", error.debugDescription);
            return @[];
        } else {
            NSLog(@"PresetController: Created presets directory.");
        }
    }
    
    NSError *error;
    NSArray *presetsContents = [fm contentsOfDirectoryAtPath:presetsPath error:&error];
    
    if (error) {
        NSLog(@"PresetController: Error listing presets : %@", error.debugDescription);
        return @[];
    }
    
    NSMutableArray *presetsFound = [[NSMutableArray alloc] initWithCapacity:presetsContents.count];
    for (NSString *thisFileName in presetsContents) {
        if ([thisFileName hasSuffix:FILE_EXTENSION]) {
            [presetsFound addObject:thisFileName];
        }
    }
    
    NSLog(@"PresetController: Found %lu files.", (unsigned long)presetsFound.count);
    
    return [Preset sortFilesByDate:[NSArray arrayWithArray:presetsFound]];
}

+ (NSString*)presetsPath {
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *presetsPath = documentsPath;
    return presetsPath;
}

+(NSArray*)sortFilesByDate:(NSArray*)files {
    // Sort files by date modified
    NSFileManager *fm = [NSFileManager defaultManager];
    
    NSMutableArray *fileInfos = [[NSMutableArray alloc] initWithCapacity:files.count];
    for (NSString *thisFile in files) {
        NSError* error;
        NSDictionary *properties = [fm attributesOfItemAtPath:[self fullPathForPreset:thisFile] error:&error];
        if (error) {
            NSLog(@"PresetController: Error reading properties of file %@. %@", thisFile, error.debugDescription);
        } else {
            NSDate *modDate = [properties objectForKey:NSFileModificationDate];
            [fileInfos addObject:@{
                                   @"file" : thisFile,
                                   @"date" : modDate
                                   }];
        }
    }
    
    NSArray* sortedFileInfos = [fileInfos sortedArrayUsingComparator:
                                ^(id path1, id path2)
                                {
                                    // compare
                                    NSComparisonResult comp = [[path1 objectForKey:@"date"] compare:
                                                               [path2 objectForKey:@"date"]];
                                    // invert ordering
                                    if (comp == NSOrderedDescending) {
                                        comp = NSOrderedAscending;
                                    }
                                    else if(comp == NSOrderedAscending){
                                        comp = NSOrderedDescending;
                                    }
                                    return comp;
                                }];
    
    NSMutableArray *sortedFiles = [[NSMutableArray alloc] initWithCapacity:sortedFileInfos.count];
    
    for (NSDictionary *thisDictionary in sortedFileInfos) {
        [sortedFiles addObject:[thisDictionary objectForKey:@"file"]];
    }
    
    return [NSArray arrayWithArray:sortedFiles];
}

+(void)fetchThumbnailForPreset:(NSString*)presetPath onCompletion:(void (^)(NSString *, UIImage *))completion {
    // Fetch a preset thumbnail asynchronously.
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^ {
        Preset *thisPreset = [self loadPreset:presetPath];
        UIImage *result = thisPreset.thumbnail;
        
        if (completion) {
            dispatch_async(dispatch_get_main_queue(), ^ {
                completion(presetPath, result);
            });
        }
    });
}


+(NSDate*)getDateForPreset:(NSString*)preset {
    NSError* error;
    NSDictionary *properties = [[NSFileManager defaultManager] attributesOfItemAtPath:[Preset fullPathForPreset:preset] error:&error];
    if (error) {
        NSLog(@"PresetController: Error reading properties of file %@. %@", preset, error.debugDescription);
        return nil;
    } else {
        return [properties objectForKey:NSFileModificationDate];
        
    }
}

+(Preset*)loadPreset:(NSString*)presetName {
    
    NSError *error;
    NSData *presetData = [NSData dataWithContentsOfFile:[Preset fullPathForPreset:presetName] options:0 error:&error];
    
    if (error) {
        NSLog(@"PresetController: Error reading preset %@. %@", presetName, error.debugDescription);
        return nil;
    }
    
    Preset *preset = [NSKeyedUnarchiver unarchiveObjectWithData:presetData];
    return preset;
}

+(BOOL)savePresetWithName:(NSString*)presetName
               dictionary:(NSDictionary*)dictionary
                thumbnail:(UIImage*)thumbnail
                overwrite:(BOOL)overwrite
                 progress:(ProgressBlock)progress {
    
    
    NSLog(@"PresetController: Writing %@.", presetName);
    
    if (progress) {
        dispatch_async(dispatch_get_main_queue(), ^ {
            progress(1/5.0);
        });
    }
    
    NSString *path = [Preset fullPathForPreset:presetName];
    
    // Check if file exists
    NSFileManager *fm = [NSFileManager defaultManager];
    if ([fm fileExistsAtPath:path]) {
        if (overwrite) {
            // Overwrite - remove the file and continue
            NSError *error;
            [fm removeItemAtPath:path error:&error];
            if (error) {
                NSLog(@"PresetController: Write failed - cannot overwrite existing file.");
                return false;
            }
        } else {
            // Fail
            NSLog(@"PresetController: Write failed - file already exists.");
            return false;
        }
    }
    
    if (progress) {
        dispatch_async(dispatch_get_main_queue(), ^ {
            progress(2/5.0);
        });
    }
    
    Preset *preset = [[Preset alloc] initWithDictionary:dictionary thumbnail:thumbnail];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:preset];
    
    if (progress) {
        dispatch_async(dispatch_get_main_queue(), ^ {
            progress(3/5.0);
        });
    }
    
    NSError *error;
    [data writeToFile:path options:0 error:&error];
    
    if (progress) {
        dispatch_async(dispatch_get_main_queue(), ^ {
            progress(4/5.0);
        });
    }
    
    if (error) {
        NSLog(@"PresetController: Error writing file. %@", error.debugDescription);
        return false;
    }
    
    NSLog(@"PresetController: Done.");
    
    if (progress) {
        dispatch_async(dispatch_get_main_queue(), ^ {
            progress(5/5.0);
        });
    }
    
    return true;
}

+(BOOL)removePreset:(NSString*)presetName {
    
    NSString *path = [Preset fullPathForPreset:presetName];
    
    NSFileManager *fm = [NSFileManager defaultManager];
    NSError *error = nil;
    
    [fm removeItemAtPath:path error:&error];
    
    if (error) {
        NSLog(@"Error removing %@. %@", presetName, error.localizedDescription);
        return false;
    } else {
        return true;
    }
}

// Old name should have file extension, new name should not.
+(BOOL)renamePreset:(NSString*)oldName to:(NSString*)newName {
    
    NSString *oldPath = [Preset fullPathForPreset:oldName];
    NSString *newPath = [[Preset fullPathForPreset:newName] stringByAppendingPathExtension:FILE_EXTENSION];
    
    // Check if file exists
    NSFileManager *fm = [NSFileManager defaultManager];
    NSError *error = nil;
    
    [fm moveItemAtPath:oldPath toPath:newPath error:&error];
    
    if (error) {
        NSLog(@"Error renaming %@ -> %@. %@", oldName, newName, error.localizedDescription);
        return false;
    } else {
        return true;
    }
}

+(NSString*)getNewFilename {
    NSString *filename = NSLocalizedString(@"New_File", @"New file");
    
    int i = 1;
    while (![Preset isFilenameUnique:filename]) {
        filename = [NSString stringWithFormat:NSLocalizedString(@"New_File_Overflow", @"New file overflow"), ++i];
    }
    
    return [filename stringByAppendingPathExtension:FILE_EXTENSION];
}

+(NSString*)fullPathForPreset:(NSString*)preset {
    return [[self presetsPath] stringByAppendingPathComponent:preset];
}

+(BOOL)isFilenameUnique:(NSString*)filename {
    NSFileManager *fm = [NSFileManager defaultManager];
    return ![fm fileExistsAtPath:[[Preset fullPathForPreset:filename] stringByAppendingPathExtension:FILE_EXTENSION]];
}

@end

