//
//  ModuleDescription.m
//  ColaApp
//
//  Created by Chris on 09/03/2015.
//  Copyright (c) 2015 Chris Rivers. All rights reserved.
//

#import "ModuleDescription.h"
#import "ModuleView.h"
#import "UIView+Snapshot.h"
#import "UIImage+Resize.h"

@interface ModuleDescription ()

@property (nonatomic, strong) NSString *identifier;
@property (nonatomic, strong) NSString *component;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *asset;

@property (nonatomic) NSUInteger width;

@property (nonatomic, strong) NSArray *connectors;
@property (nonatomic, strong) NSArray *controls;

@property (nonatomic, strong) UIImage *thumbnail;

@end

@implementation ModuleDescription

-(instancetype)initWithDictionary:(NSDictionary*)dictionary {
    if (self = [super init]) {
        
        if ([dictionary objectForKey:@"id"]) {
            self.identifier = [dictionary objectForKey:@"id"];
        }
        
        if ([dictionary objectForKey:@"name"]) {
            self.name = [dictionary objectForKey:@"name"];
        }
        
        if ([dictionary objectForKey:@"type"]) {
            self.component = [dictionary objectForKey:@"type"];
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
            
            if ([viewInfo objectForKey:@"controls"]) {
                NSArray *controls = [viewInfo objectForKey:@"controls"];
                NSMutableArray *controlDescriptions = [[NSMutableArray alloc] initWithCapacity:[controls count]];
                for (NSDictionary *thisControl in controls) {
                    ControlDescription *controlDescription = [[ControlDescription alloc] initWithDictionary:thisControl];
                    [controlDescriptions addObject:controlDescription];
                }
                self.controls = [NSArray arrayWithArray:controlDescriptions];
            }
        }
        
        // Create the thumbnail
        ModuleView *thumbnailView = [[ModuleView alloc] initWithModuleDescription:self];
        
        if (!thumbnailView) {
            return nil;
        } 
        
        self.thumbnail = [[thumbnailView snapshot] resizeTo:CGSizeMake(100, 100)];
        [thumbnailView trash];
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

@interface ControlDescription ()

@property (nonatomic, strong) NSString      *type;
@property (nonatomic, strong) NSString      *parameterName;
@property (nonatomic, strong) NSString      *asset;
@property (nonatomic) CGPoint               location;
@property (nonatomic, strong) NSDictionary  *userInfo;

@end

@implementation ControlDescription

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
        
        if ([dictionary valueForKey:@"userinfo"]) {
            self.userInfo = [dictionary objectForKey:@"userinfo"];
        }
    }
    return self;
}

@end