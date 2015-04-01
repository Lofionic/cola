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
#import "RotaryEncoder.h"

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
        
        if (moduleDescription.encoders) {
            [self addEncoders:moduleDescription.encoders];
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


-(instancetype)initWithModuleDescription:(ModuleDescription *)moduleDescription {
    
    CGRect frame = CGRectMake(0, 0, moduleDescription.width * kBuildViewColumnWidth, 1 * kBuildViewRowHeight);
    if (self = [self initWithModuleDescription:moduleDescription inFrame:frame]) {
        
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
        } else {
            NSLog(@"Warning: Parametner '%@' not found on component of type %@", thisEncoder.parameterName, [self.component class]);
        }
    }
}

-(UIImage*)snapshot {
    
    CGSize imageSize = self.frame.size;
    UIGraphicsBeginImageContextWithOptions(imageSize, NO, [[UIScreen mainScreen] scale]);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSaveGState(context);
    [self.layer renderInContext:context];
    CGContextRestoreGState(context);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return image;
}

@end
