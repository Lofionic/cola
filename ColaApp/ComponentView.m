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

@property (nonatomic, weak) COLComponent *component;

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
        
        [self setBackgroundColor:BACKGROUND_COLOUR];
        
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
        
        COLComponentParameter *componentParameter = nil;
        componentParameter = [self.component parameterNamed:thisEncoder.parameterName];

        if (componentParameter) {
            RotaryEncoder *rotaryEncoder = [[RotaryEncoder alloc] initWithParameter:componentParameter];
            [rotaryEncoder setCenter:thisEncoder.location];
            [rotaryEncoder setValue:componentParameter.getNormalizedValue];
            [self addSubview:rotaryEncoder];
        }
    }
}

-(void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGContextSetStrokeColorWithColor(ctx, [[UIColor colorWithRed:0 green:0 blue:0 alpha:0.5] CGColor]);
    CGContextSetLineWidth(ctx, 2);
    CGContextStrokeRect(ctx, rect);
}

@end
