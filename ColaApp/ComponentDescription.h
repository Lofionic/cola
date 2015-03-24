//
//  ComponentDescription.h
//  ColaApp
//
//  Created by Chris on 09/03/2015.
//  Copyright (c) 2015 Chris Rivers. All rights reserved.
//
@import UIKit;
@import Foundation;

@interface ComponentDescription : NSObject

@property (readonly, strong) NSString   *type;
@property (readonly, strong) NSString   *name;

@property (readonly) NSUInteger         width;
@property (readonly) NSUInteger         height;

@property (readonly, strong) NSArray    *connectors;
@property (readonly, strong) NSArray    *encoders;

-(instancetype)initWithDictionary:(NSDictionary*)dictionary;

@end

@interface ConnectorDescription : NSObject

@property (readonly, strong) NSString   *type;
@property (readonly, strong) NSString   *connectionName;
@property (readonly) CGPoint            location;

-(instancetype)initWithDictionary:(NSDictionary*)dictionary;

@end

@interface EncoderDescription : NSObject

@property (readonly, strong) NSString   *type;
@property (readonly, strong) NSString   *parameterName;
@property (readonly) CGPoint            location;

-(instancetype)initWithDictionary:(NSDictionary*)dictionary;

@end