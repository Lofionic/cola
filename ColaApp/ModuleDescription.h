//
//  ModuleDescription.h
//  ColaApp
//
//  Created by Chris on 09/03/2015.
//  Copyright (c) 2015 Chris Rivers. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface ModuleDescription : NSObject

@property (readonly, strong) NSString   *identifier;
@property (readonly, strong) NSString   *type;
@property (readonly, strong) NSString   *name;
@property (readonly, strong) NSString   *asset;

@property (readonly) NSUInteger         width;

@property (readonly, strong) NSArray    *connectors;
@property (readonly, strong) NSArray    *controls;

@property (readonly, strong) UIImage    *thumbnail;

-(instancetype)initWithDictionary:(NSDictionary*)dictionary;

@end

@interface ConnectorDescription : NSObject

@property (readonly, strong) NSString   *type;
@property (readonly, strong) NSString   *connectionName;
@property (readonly) CGPoint            location;

-(instancetype)initWithDictionary:(NSDictionary*)dictionary;

@end

@interface ControlDescription : NSObject

@property (readonly, strong) NSString   *type;
@property (readonly, strong) NSString   *parameterName;
@property (readonly, strong) NSString   *asset;
@property (readonly) CGPoint            location;

-(instancetype)initWithDictionary:(NSDictionary*)dictionary;

@end