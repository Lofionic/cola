//
//  ComponentView.m
//  ColaApp
//
//  Created by Chris on 23/03/2015.
//  Copyright (c) 2015 Chris Rivers. All rights reserved.
//

#import "BuildViewController.h"

#import "ComponentView.h"
#import "ConnectorView.h"
#import "RotaryEncoder.h"

#define BACKGROUND_COLOUR [UIColor colorWithRed:64/255.0 green:64/255.0 blue:64/255.0 alpha:1]

@interface ComponentView ()

@property (nonatomic, weak) COLComponent    *component;
@property (nonatomic, strong) NSString      *asset;

@end

@implementation ComponentView

-(instancetype)initWithComponentDescription:(ComponentDescription *)componentDescription inFrame:(CGRect)frame {
    
    COLComponent *component = [[COLAudioEnvironment sharedEnvironment] createComponentOfType:componentDescription.type];
    
    if (component && (self = [super initWithFrame:frame])) {
        self.component = component;
        
        if (componentDescription.connectors) {
            [self addConnectors:componentDescription.connectors];
        }
        
        if (componentDescription.encoders) {
            [self addEncoders:componentDescription.encoders];
        }
        
        UIImage *assetImage = nil;
        if (componentDescription.asset) {
            self.asset = [NSString stringWithFormat:@"ImageAssets/Components/%@", componentDescription.asset];
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

-(void)addEncoders:(NSArray*)encoders {
  
    for (EncoderDescription *thisEncoder in encoders) {
        
        RotaryEncoder *rotaryEncoder = [[RotaryEncoder alloc] initWithDescription:thisEncoder forComponent:self.component];
        if (rotaryEncoder) {
            [rotaryEncoder setCenter:thisEncoder.location];
            [self addSubview:rotaryEncoder];
        }
    }
}

@end
