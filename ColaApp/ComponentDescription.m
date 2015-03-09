//
//  ComponentDescription.m
//  ColaApp
//
//  Created by Chris on 09/03/2015.
//  Copyright (c) 2015 Chris Rivers. All rights reserved.
//

#import "ComponentDescription.h"

@implementation ComponentDescription

-(instancetype)initWithDictionary:(NSDictionary*)dictionary {
    if (self = [super init]) {
        
        if ([dictionary objectForKey:kCOLComponentDescriptionNameKey]) {
            self.name = [dictionary objectForKey:kCOLComponentDescriptionNameKey];
        }
        
        if ([dictionary objectForKey:kCOLComponentDescriptionTypeKey]) {
            self.type = [dictionary objectForKey:kCOLComponentDescriptionTypeKey];
        }
        
        if ([dictionary valueForKey:kCOLComponentDescriptionWidthKey]) {
            self.width = [[dictionary valueForKey:kCOLComponentDescriptionWidthKey] integerValue];
        }
        
        if ([dictionary valueForKey:kCOLComponentDescriptionHeightKey]) {
            self.height = [[dictionary valueForKey:kCOLComponentDescriptionHeightKey] integerValue];
        }
    }
    
    return self;
}

@end
