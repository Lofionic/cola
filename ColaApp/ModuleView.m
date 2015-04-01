//
//  ComponentView.m
//  ColaApp
//
//  Created by Chris on 23/03/2015.
//  Copyright (c) 2015 Chris Rivers. All rights reserved.
//
#import "BuildViewController.h"

#import "defines.h"
#import "ModuleView.h"
#import "ModuleDescription.h"
#import "ConnectorView.h"
#import "ModuleControl.h"

#define BACKGROUND_COLOUR [UIColor colorWithRed:64/255.0 green:64/255.0 blue:64/255.0 alpha:1]

@interface ModuleView ()

@property (nonatomic, weak) COLComponent    *component;
@property (nonatomic, strong) NSString      *asset;

@end

@implementation ModuleView

-(instancetype)initWithModuleDescription:(ModuleDescription *)moduleDescription inFrame:(CGRect)frame {
    
    COLComponent *component = [[COLAudioEnvironment sharedEnvironment] createComponentOfType:moduleDescription.type];
    if (!component) {
        return nil;
    }
    
    
    if (self = [super initWithFrame:frame]) {
        self.component = component;
        
        if (moduleDescription.connectors) {
            [self addConnectors:moduleDescription.connectors];
        }
        
        if (moduleDescription.controls) {
            [self addControls:moduleDescription.controls];
        }
        
        UIImage *assetImage = nil;
        if (moduleDescription.asset) {
            self.asset = [ASSETS_PATH_COMPONENTS stringByAppendingString:moduleDescription.asset];
            assetImage = [UIImage imageNamed:self.asset];
        }
        
        if (assetImage) {
            [self.layer setContents:(id)assetImage.CGImage];
        } else {
            [self setBackgroundColor:BACKGROUND_COLOUR];
        }
    }
    return self;
}

-(void)addConnectors:(NSArray*)connectors {
    for (ConnectorDescription *thisConnector in connectors) {
        
        COLComponentIO *componentIO = nil;
        if ([thisConnector.type isEqualToString:@"output"]) {
            componentIO = [self.component outputNamed:thisConnector.connectionName];
        } else if ([thisConnector.type isEqualToString:@"input"]) {
            componentIO = [self.component inputNamed:thisConnector.connectionName];
        }
        
        if (componentIO) {
            ConnectorView *connectorView = [[ConnectorView alloc] initWithComponentIO:componentIO];
            [connectorView setCenter:thisConnector.location];
            [connectorView setDelegate:[BuildViewController buildView]];
            [self addSubview:connectorView];
        }
    }
}

-(void)addControls:(NSArray*)controls {
  
    for (ControlDescription *thisControl in controls) {
        // Find the parameter
        COLParameter *parameter = [self.component parameterNamed:thisControl.parameterName];
        ModuleControl *newControl = [ModuleControl controlForParameter:parameter Description:thisControl];
        if (newControl) {
            [newControl setCenter:thisControl.location];
            [self addSubview:newControl];
        }
    }
}

@end
