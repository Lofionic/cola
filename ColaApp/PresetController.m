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
#import "NSString+Random.h"

#define FILE_EXTENSION @"col"
#define DEFAULT_FILE_NAME @"New File.%@"
#define DEFAULT_FILE_NAME_OVERFLOW @"New File %d.%@"

@interface PresetController ()

@property (nonatomic) NSString*         selectedPresetFilename;
@property (nonatomic, strong) NSArray*  files;

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
        self.selectedPresetFilename = @"";
    }
    return self;
}

-(void)loadPresets {
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *presetsPath = [self presetsPath];
    
    if (![fm fileExistsAtPath:presetsPath]) {
        NSLog(@"PresetController: Presets directory not found. Creating %@...", presetsPath);
        NSError *error;
        [fm createDirectoryAtPath:presetsPath withIntermediateDirectories:YES attributes:nil error:&error];
        if (error) {
            NSLog(@"PresetController: Error creating presets directory : %@", error.debugDescription);
            self.files = @[];
            return;
        } else {
            NSLog(@"PresetController: Created presets directory.");
        }
    }
    
    NSError *error;
    NSArray *presetsContents = [fm contentsOfDirectoryAtPath:presetsPath error:&error];
    
    if (error) {
        NSLog(@"PresetController: Error listing presets : %@", error.debugDescription);
        self.files = @[];
        return;
    }
    
    NSMutableArray *presetsFound = [[NSMutableArray alloc] initWithCapacity:presetsContents.count];
    for (NSString *thisFileName in presetsContents) {
        if ([thisFileName hasSuffix:FILE_EXTENSION]) {
            [presetsFound addObject:thisFileName];
        }
    }
    
    NSLog(@"PresetController: Found %lu files.", (unsigned long)presetsFound.count);
    
    self.files = [NSArray arrayWithArray:presetsFound];
    [self sortFiles];
}

-(void)sortFiles {
    // Sort files by date modified
    NSFileManager *fm = [NSFileManager defaultManager];
    
    NSMutableArray *fileInfos = [[NSMutableArray alloc] initWithCapacity:self.files.count];
    for (NSString *thisFile in self.files) {
        NSError* error;
        NSDictionary *properties = [fm attributesOfItemAtPath:[self fullPathForFilename:thisFile] error:&error];
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
    
    self.files = [NSArray arrayWithArray:sortedFiles];
}

-(NSString*)nameOfPresetAtIndex:(NSUInteger)index {
    return [[self.files objectAtIndex:index] stringByDeletingPathExtension];
}

-(NSDate*)dateOfPresetAtIndex:(NSUInteger)index {
    NSError* error;
    NSDictionary *properties = [[NSFileManager defaultManager] attributesOfItemAtPath:[self fullPathForFilename:[self.files objectAtIndex:index]] error:&error];
    if (error) {
//        NSLog(@"PresetController: Error reading properties of file %@. %@", thisFile, error.debugDescription);
        return nil;
    } else {
        return [properties objectForKey:NSFileModificationDate];
        
    }
}

-(void)fetchThumbnailForPresetAtIndex:(NSUInteger)index onCompletion:(void (^)(NSUInteger index, UIImage *image))completion {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^ {
        Preset *thisPreset = [self presetAtIndex:index];
        UIImage *result = thisPreset.thumbnail;
        
        if (completion) {
            dispatch_async(dispatch_get_main_queue(), ^ {
                completion(index, result);
            });
        }
    });
}

-(Preset*)recallPresetAtIndex:(NSUInteger)index {
    if (self.files.count == 0) {
        // No files yet - create an empty one
        NSLog(@"PresetController: No files yet. Creating blank.");
        [self addNewPreset];
    }
    
    NSLog(@"PresetController: Recalling preset %lu.", (unsigned long)index);
    self.selectedPresetFilename = [self.files objectAtIndex:index];
    return [self loadPresetFromFilename:self.selectedPresetFilename];
}


-(Preset*)presetAtIndex:(NSUInteger)index {
    return [self loadPresetFromFilename:[self.files objectAtIndex:index]];
}

-(Preset*)loadPresetFromFilename:(NSString*)filename {
    
//    NSLog(@"PresetController: Opening file %@.", filename);
    NSString *path = [self fullPathForFilename:filename];
    
    NSError *error;
    NSData *presetData = [NSData dataWithContentsOfFile:path options:0 error:&error];
    
    if (error) {
        NSLog(@"PresetController: Error reading preset %@. %@", path, error.debugDescription);
        return nil;
    }
    
    Preset *preset = [NSKeyedUnarchiver unarchiveObjectWithData:presetData];
    return preset;
}

-(NSUInteger)addNewPreset {
    NSLog(@"PresetController: Creating empty preset.");
    Preset *newPreset = [self getEmptyPreset];
    
    NSString *filename;
    filename = [NSString stringWithFormat:DEFAULT_FILE_NAME, FILE_EXTENSION];
    
    int i = 0;
    while ([self doesFileExist:filename]) {
        filename = [NSString stringWithFormat:DEFAULT_FILE_NAME_OVERFLOW, ++i, FILE_EXTENSION];
    }
    
    [self savePreset:newPreset withFilename:filename thumbnail:nil overwrite:NO progress:nil];
    
    NSMutableArray *mutablePresets = [NSMutableArray arrayWithArray:self.files];
    [mutablePresets insertObject:filename atIndex:0];
    self.files = [NSArray arrayWithArray:mutablePresets];
    
    return [self.files indexOfObject:filename];
}

-(Preset*)getEmptyPreset {
    return [[Preset alloc] initWithDictionary:@{@"model" : @"", @"modules" : @{}}
                                    thumbnail:nil];
}

-(void)updateSelectedPresetWithDictionary:(NSDictionary*)dictionary thumbnail:(UIImage*)thumbnail progress:(ProgressBlock)progress {
    Preset *preset = [[Preset alloc] initWithDictionary:dictionary thumbnail:thumbnail];
    [self savePreset:preset withFilename:self.selectedPresetFilename thumbnail:thumbnail overwrite:YES progress:progress];
    [self loadPresets];
}

-(BOOL)savePreset:(Preset*)preset withFilename:(NSString*)filename thumbnail:(UIImage*)thumbnail overwrite:(BOOL)overwrite progress:(ProgressBlock)progress {
    NSLog(@"PresetController: Writing %@.", filename);
   
    if (progress) {
        dispatch_async(dispatch_get_main_queue(), ^ {
            progress(1/5.0);
        });
    }
    
    NSString *path = [self fullPathForFilename:filename];
    
    // Check if file exists
    NSFileManager *fm = [NSFileManager defaultManager];
    if ([fm fileExistsAtPath:filename]) {
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

-(void)removeFilesAtIndexes:(NSArray *)indexPaths {
    NSFileManager *fm = [NSFileManager defaultManager];
    NSMutableArray *filesMutable = [NSMutableArray arrayWithArray:self.files];
    for (NSIndexPath *thisIndexPath in indexPaths) {
        NSString *filename = [self.files objectAtIndex:thisIndexPath.row];
        NSLog(@"PresetController: Removing %@...", filename);
        NSError *error;
        [fm removeItemAtPath:[self fullPathForFilename:filename] error:&error];
        if (error) {
            NSLog(@"PresetController: Error removing file %@. %@", filename, error.debugDescription);
        } else {
            [filesMutable removeObject:filename];
            NSLog(@"PresetController: Done.");
        }
    };
    self.files = filesMutable;
}

-(NSUInteger)presetCount {
    return [self.files count];
}

- (NSString*)presetsPath {
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *presetsPath = [documentsPath stringByAppendingPathComponent:@"presets"];
    
    return presetsPath;
}

-(NSString*)fullPathForFilename:(NSString*)filename {
    return [[self presetsPath] stringByAppendingPathComponent:filename];
}

-(BOOL)doesFileExist:(NSString*)filename {
    NSFileManager *fm = [NSFileManager defaultManager];
    return [fm fileExistsAtPath:[self fullPathForFilename:filename]];
}

-(void)renameFileAtIndex:(NSUInteger)index to:(NSString*)newFilename{
    
    NSString *oldFilename = [self.files objectAtIndex:index];
    newFilename = [[newFilename stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] stringByAppendingPathExtension:FILE_EXTENSION];
    
    NSString *oldPath = [self fullPathForFilename:oldFilename];
    NSString *newPath = [self fullPathForFilename:newFilename];
    
    NSFileManager *fm = [NSFileManager defaultManager];
    NSError *error;
    [fm moveItemAtPath:oldPath toPath:newPath error:&error];
    
    if (error) {
        NSLog(@"PresetController: Error renaming file %@", error.localizedDescription);
    } else {
        NSMutableArray *mutableFiles = [self.files mutableCopy];
        [mutableFiles setObject:newFilename atIndexedSubscript:index];
        self.files = [NSArray arrayWithArray:mutableFiles];
    }
}

@end

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

-(void)updateWithDictionary:(NSDictionary*)dictionary thumbnail:(UIImage*)thumbnail {
    if (dictionary) {
        self.dictionary = dictionary;
    }

    if (thumbnail) {
        self.thumbnail = thumbnail;
    }
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

@end

