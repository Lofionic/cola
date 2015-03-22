//
//  ComponentDescription.h
//  ColaApp
//
//  Created by Chris on 09/03/2015.
//  Copyright (c) 2015 Chris Rivers. All rights reserved.
//
@import UIKit;
@import Foundation;

@interface ConnectorDescription : NSObject

@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSString *connectionName;
@property (nonatomic) CGPoint position;

-(instancetype)initWithDictionary:(NSDictionary*)dictionary;

@end

@interface ComponentDescription : NSObject

@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSString *name;

@property (nonatomic) NSUInteger width;
@property (nonatomic) NSUInteger height;

@property (nonatomic, strong) NSArray *connectors;

-(instancetype)initWithDictionary:(NSDictionary*)dictionary;

@end
