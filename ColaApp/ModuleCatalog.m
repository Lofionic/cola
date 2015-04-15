//
//  ModuleCatalog.m
//  ColaApp
//
//  Created by Chris on 09/04/2015.
//  Copyright (c) 2015 Chris Rivers. All rights reserved.
//
#import "ModuleCatalog.h"
#import "ModuleDescription.h"

@interface ModuleCatalog ()

@property (nonatomic, strong) NSArray *moduleDescriptions;

@end

@implementation ModuleCatalog

+(ModuleCatalog*)sharedCatalog {
    
    static ModuleCatalog *sharedCatalog = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedCatalog = [[ModuleCatalog alloc] init];
    });
    
    return sharedCatalog;
}

-(void)loadFromURL:(NSURL*)url {
    NSError *dataError;
    NSData *moduleCatalogData = [NSData dataWithContentsOfURL:url options:0 error:&dataError];
    if (!dataError && moduleCatalogData) {
        NSError *dictError;
        NSDictionary *moduleCatalogJSON = [NSJSONSerialization JSONObjectWithData:moduleCatalogData options:0 error:&dictError];
        if (!dictError && moduleCatalogJSON) {
            NSArray *modules = [moduleCatalogJSON objectForKey:@"modules"];
            __block NSMutableArray *moduleDescriptions = [[NSMutableArray alloc] initWithCapacity:[modules count]];
            
            [modules enumerateObjectsUsingBlock:^(id obj, NSUInteger index, BOOL *stop) {
                NSDictionary *moduleDictionary = (NSDictionary*)obj;
                [moduleDescriptions addObject:[[ModuleDescription alloc] initWithDictionary:moduleDictionary]];
            }];
            self.moduleDescriptions = [NSArray arrayWithArray:moduleDescriptions];
            NSLog(@"Module Catalog loaded : %lu module decsriptions", (unsigned long)[self.moduleDescriptions count]);
        }
    } else {
        NSLog(@"Error loading Module Catalog");
    }
}

-(NSArray*)allModules {
    return [self moduleDescriptions];
}

-(ModuleDescription*)moduleOfType:(NSString*)type {
    __block ModuleDescription *result = nil;
    
    [self.moduleDescriptions enumerateObjectsUsingBlock:^(ModuleDescription* thisModule, NSUInteger index, BOOL* stop) {
        if ([thisModule.type isEqualToString:type]) {
            result = thisModule;
            *stop = YES;
        }
    }];
    
    return result;
}

-(ModuleDescription*)moduleWithIdentifier:(NSString*)identifier {
    __block ModuleDescription *result = nil;
    
    [self.moduleDescriptions enumerateObjectsUsingBlock:^(ModuleDescription* thisModule, NSUInteger index, BOOL* stop) {
        if ([thisModule.identifier isEqualToString:identifier]) {
            result = thisModule;
            *stop = YES;
        }
    }];
    
    return result;
}

@end
