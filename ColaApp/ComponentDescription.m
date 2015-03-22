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
        
        if ([dictionary objectForKey:@"name"]) {
            self.name = [dictionary objectForKey:@"name"];
        }
        
        if ([dictionary objectForKey:@"type"]) {
            self.type = [dictionary objectForKey:@"type"];
        }
        
        if ([dictionary valueForKey:@"width"]) {
            self.width = [[dictionary valueForKey:@"width"] integerValue];
        }
        
        if ([dictionary valueForKey:@"height"]) {
            self.height = [[dictionary valueForKey:@"height"] integerValue];
        }
        
        if ([dictionary objectForKey:@"view"]) {
            NSDictionary *viewInfo = [dictionary objectForKey:@"view"];
            if ([viewInfo objectForKey:@"connectors"]) {
                NSArray *connectors = [viewInfo objectForKey:@"connectors"];
                NSMutableArray *connectorDescriptions = [[NSMutableArray alloc] initWithCapacity:[connectors count]];
                for (NSDictionary *thisConnector in connectors) {
                    ConnectorDescription *connectorDescription = [[ConnectorDescription alloc] initWithDictionary:thisConnector];
                    [connectorDescriptions addObject:connectorDescription];
                }
                self.connectors = [NSArray arrayWithArray:connectorDescriptions];
            }
        }
    }
    
    return self;
}

@end

@implementation ConnectorDescription

-(instancetype)initWithDictionary:(NSDictionary*)dictionary {
    if (self = [super init]) {
        
        if ([dictionary objectForKey:@"type"]) {
            self.type = [dictionary objectForKey:@"type"];
        }
        
        if ([dictionary objectForKey:@"connection"]) {
            self.connectionName = [dictionary objectForKey:@"connection"];
        }
        
        if ([dictionary valueForKey:@"x"] && [dictionary valueForKey:@"y"]) {
            self.position = CGPointMake([[dictionary valueForKey:@"x"] integerValue], [[dictionary valueForKey:@"y"] integerValue]);
        }
        
    }
    return self;
}

@end
