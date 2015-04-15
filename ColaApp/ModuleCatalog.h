//
//  ModuleCatalog.h
//  ColaApp
//
//  Created by Chris on 09/04/2015.
//  Copyright (c) 2015 Chris Rivers. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ModuleDescription;
@interface ModuleCatalog : NSObject

+(ModuleCatalog*)sharedCatalog;

-(void)loadFromURL:(NSURL*)url;
-(NSArray*)allModules;
-(ModuleDescription*)moduleOfType:(NSString*)type;
-(ModuleDescription*)moduleWithIdentifier:(NSString*)identifier;

@end
