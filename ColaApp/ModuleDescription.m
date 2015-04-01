//
//  ModuleDescription.m
//  ColaApp
//
//  Created by Chris on 09/03/2015.
//  Copyright (c) 2015 Chris Rivers. All rights reserved.
//

#import "ModuleDescription.h"
#import "ModuleView.h"

@interface ModuleDescription ()

@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *asset;

@property (nonatomic) NSUInteger width;

@property (nonatomic, strong) NSArray *connectors;
@property (nonatomic, strong) NSArray *encoders;

@property (nonatomic, strong) UIImage *thumbnail;

@end

@implementation ModuleDescription

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

        if ([dictionary objectForKey:@"view"]) {
            NSDictionary *viewInfo = [dictionary objectForKey:@"view"];
            if ([viewInfo objectForKey:@"asset"]) {
                self.asset = [viewInfo objectForKey:@"asset"];
            }
            
            if ([viewInfo objectForKey:@"connectors"]) {
                NSArray *connectors = [viewInfo objectForKey:@"connectors"];
                NSMutableArray *connectorDescriptions = [[NSMutableArray alloc] initWithCapacity:[connectors count]];
                for (NSDictionary *thisConnector in connectors) {
                    ConnectorDescription *connectorDescription = [[ConnectorDescription alloc] initWithDictionary:thisConnector];
                    [connectorDescriptions addObject:connectorDescription];
                }
                self.connectors = [NSArray arrayWithArray:connectorDescriptions];
            }
            
            if ([viewInfo objectForKey:@"encoders"]) {
                NSArray *encoders = [viewInfo objectForKey:@"encoders"];
                NSMutableArray *encoderDescriptions = [[NSMutableArray alloc] initWithCapacity:[encoders count]];
                for (NSDictionary *thisEncoder in encoders) {
                    EncoderDescription *encoderDescription = [[EncoderDescription alloc] initWithDictionary:thisEncoder];
                    [encoderDescriptions addObject:encoderDescription];
                }
                self.encoders = [NSArray arrayWithArray:encoderDescriptions];
            }
        }
        
        // Create the thumbnail
        ModuleView *thumbnailView = [[ModuleView alloc] initWithModuleDescription:self];
        self.thumbnail = [thumbnailView snapshot];
    }
    
    return self;
}

@end

@interface ConnectorDescription ()

@property (nonatomic, strong) NSString      *type;
@property (nonatomic, strong) NSString      *connectionName;
@property (nonatomic) CGPoint               location;

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
            self.location = CGPointMake([[dictionary valueForKey:@"x"] integerValue], [[dictionary valueForKey:@"y"] integerValue]);
        }
        
    }
    return self;
}

@end

@interface EncoderDescription ()

@property (nonatomic, strong) NSString   *type;
@property (nonatomic, strong) NSString   *parameterName;
@property (nonatomic, strong) NSString   *asset;
@property (nonatomic) CGPoint            location;

@end

@implementation EncoderDescription

-(instancetype)initWithDictionary:(NSDictionary*)dictionary {
    if (self = [super init]) {
        
        if ([dictionary objectForKey:@"type"]) {
            self.type = [dictionary objectForKey:@"type"];
        }
        
        if ([dictionary objectForKey:@"parameter"]) {
            self.parameterName = [dictionary objectForKey:@"parameter"];
        }
        
        if ([dictionary objectForKey:@"asset"]) {
            self.asset = [dictionary objectForKey:@"asset"];
        }
        
        if ([dictionary valueForKey:@"x"] && [dictionary valueForKey:@"y"]) {
            self.location = CGPointMake([[dictionary valueForKey:@"x"] integerValue], [[dictionary valueForKey:@"y"] integerValue]);
        }
        
    }
    return self;
}

@end