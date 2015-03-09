//
//  ComponentDescription.h
//  ColaApp
//
//  Created by Chris on 09/03/2015.
//  Copyright (c) 2015 Chris Rivers. All rights reserved.
//

#define kCOLComponentDescriptionTypeKey     @"kCOLComponentDescriptionTypeKey"
#define kCOLComponentDescriptionNameKey     @"kCOLComponentDescriptionNameKey"
#define kCOLComponentDescriptionWidthKey    @"kCOLComponentDescriptionWidthKey"
#define kCOLComponentDescriptionHeightKey   @"kCOLComponentDescriptionHeightKey"

#import <Foundation/Foundation.h>

@interface ComponentDescription : NSObject

@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSString *name;

@property (nonatomic) NSUInteger width;
@property (nonatomic) NSUInteger height;

-(instancetype)initWithDictionary:(NSDictionary*)dictionary;
@end
