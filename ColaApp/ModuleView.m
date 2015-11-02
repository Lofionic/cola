//
//  ComponentView.m
//  ColaApp
//
//  Created by Chris on 23/03/2015.
//  Copyright (c) 2015 Chris Rivers. All rights reserved.
//
#import "ModuleView.h"
#import <ColaLib/COLAudioEnvironment.h>

#import "BuildViewController.h"

#import "defines.h"
#import "ModuleView.h"
#import "ModuleDescription.h"
#import "ConnectorView.h"
#import "ControlView.h"
#import "NSString+Random.h"
#import "BuildView.h"
#import "ModuleCatalog.h"

#import "RotaryEncoder.h"
#import "RotarySwitch.h"

#define BACKGROUND_COLOUR [UIColor colorWithRed:64/255.0 green:64/255.0 blue:64/255.0 alpha:1]

@interface ModuleView ()

@property (nonatomic) CCOLComponentAddress      component;
@property (nonatomic, strong) NSString          *asset;
@property (nonatomic, strong) ModuleDescription *moduleDescription;

@end

@implementation ModuleView

-(instancetype)initWithModuleDescription:(ModuleDescription *)moduleDescription inFrame:(CGRect)frame identifier:(NSString*)identifier {
    
    CCOLComponentAddress component = [[COLAudioEnvironment sharedEnvironment] createCComponentOfType:(char*)[moduleDescription.component UTF8String]];

    if (component == 0) {
        return nil;
    }
    
    if (self = [super initWithFrame:frame]) {
        self.component = component;
        self.moduleDescription = moduleDescription;

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
            UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 16)];
            [titleLabel setFont:[UIFont systemFontOfSize:10]];
            [titleLabel setTextColor:[UIColor whiteColor]];
            [titleLabel setText:[moduleDescription.name uppercaseString]];
            [titleLabel setTextAlignment:NSTextAlignmentCenter];
            [titleLabel setFont:[UIFont fontWithName:@"DINAlternate-Bold" size:10]];
            [self addSubview:titleLabel];
        }
        
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
        [longPress setMinimumPressDuration:0.5f];
        [longPress setCancelsTouchesInView:NO];
        [self addGestureRecognizer:longPress];
        
        if (!identifier) {
            self.identifier = [NSString randomIdentifier];
        } else {
            self.identifier = identifier;
        }
    }
    return self;
}


-(instancetype)initWithModuleDescription:(ModuleDescription *)moduleDescription {
    
    CGRect frame = CGRectMake(0, 0, moduleDescription.width * kBuildViewColumnWidth, 1 * kBuildViewRowHeight);
    if (self = [self initWithModuleDescription:moduleDescription inFrame:frame identifier:nil]) {
        
    }
    return self;
}

-(void)addConnectors:(NSArray*)connectors {
    
    COLAudioEnvironment *cae = [COLAudioEnvironment sharedEnvironment];
    
    NSMutableArray *connectorViews = [[NSMutableArray alloc] initWithCapacity:[connectors count]];
    
    for (ConnectorDescription *thisConnector in connectors) {
        CCOLConnectorAddress componentIO = 0;
        if ([thisConnector.type isEqualToString:@"output"]) {
            componentIO = [cae getOutputNamed:thisConnector.connectionName onComponent:self.component];
        } else if ([thisConnector.type isEqualToString:@"input"]) {
            componentIO = [cae getInputNamed:thisConnector.connectionName onComponent:self.component];
        }
        
        if (componentIO > 0) {
            ConnectorView *connectorView = [[ConnectorView alloc] initWithComponentIO:componentIO];
            [connectorView setCenter:thisConnector.location];
            [connectorView setDelegate:[BuildViewController buildView]];
            [self addSubview:connectorView];
            [connectorViews addObject:connectorView];
        } else {
            NSLog(@"ModuleView: Unable to find connector named %@", thisConnector.connectionName);
        }
    }
    
    self.connectorViews = [NSArray arrayWithArray:connectorViews];
}

-(ConnectorView*)connectorForName:(NSString*)name {
    __block ConnectorView *result = nil;
    
    [self.connectorViews enumerateObjectsUsingBlock:^(ConnectorView *obj, NSUInteger index, BOOL *stop) {
        NSString *connectorName = [[COLAudioEnvironment sharedEnvironment] getConnectorName:obj.connector];
        if ([connectorName isEqualToString:name]) {
            result = obj;
            *stop = YES;
        }
    }];
    
    return result;
}

-(void)addControls:(NSArray*)controls {
    
    COLAudioEnvironment *cae = [COLAudioEnvironment sharedEnvironment];
    
    NSMutableArray *controlViews = [[NSMutableArray alloc] initWithCapacity:[controls count]];
    
    for (ControlDescription *thisControl in controls) {
        CCOLParameterAddress parameter = 0;
        parameter = [cae getParameterNamed:thisControl.parameterName onComponent:self.component];
        
        ControlType type;
        if ([thisControl.type isEqualToString:@"discrete"]) {
            type = Discrete;
        } else if ([thisControl.type isEqualToString:@"continuous"]) {
            type = Continuous;
        }
        
        ControlView *controlView = [ControlView controlForParameter:parameter Description:thisControl ControlType:type];
        if (controlView) {
            [controlView setCenter:thisControl.location];
            [self addSubview:controlView];
            [controlViews addObject:controlView];
        }
    }
    
    self.controlViews = [NSArray arrayWithArray:controlViews];
}

-(void)setParametersFromDictionary:(NSDictionary*)parametersDictionary {
    
    COLAudioEnvironment *cae = [COLAudioEnvironment sharedEnvironment];
    
    for (NSString *thisParameter in [parametersDictionary allKeys]) {
        [self.controlViews enumerateObjectsUsingBlock:^(ControlView *obj, NSUInteger index, BOOL *stop) {
            if ([obj isKindOfClass:[RotaryEncoder class]]) {
                RotaryEncoder *rotaryEncoder = (RotaryEncoder*)obj;
                NSString *thisEncoderParameterName = [cae getParameterName:rotaryEncoder.parameter];
                if ([thisEncoderParameterName isEqualToString:thisParameter]) {
                    [cae setContinuousParameter:rotaryEncoder.parameter value:[[parametersDictionary objectForKey:thisParameter] floatValue]];
                    [rotaryEncoder updateFromParameter];
                }
            }
            
            if ([obj isKindOfClass:[RotarySwitch class]]) {
                RotaryEncoder *rotaryEncoder = (RotaryEncoder*)obj;
                NSString *thisEncoderParameterName = [cae getParameterName:rotaryEncoder.parameter];
                if ([thisEncoderParameterName isEqualToString:thisParameter]) {
                    [cae setDiscreteParameterSelectedIndex:rotaryEncoder.parameter index:(CCOLDiscreteParameterIndex)[[parametersDictionary objectForKey:thisParameter] integerValue]];
                    [rotaryEncoder updateFromParameter];
                }
            }
        }];
    }
}

-(void)handleLongPress:(UIGestureRecognizer*)uigr {
    UILongPressGestureRecognizer *longPressGesture = (UILongPressGestureRecognizer*)uigr;
    
    if (longPressGesture.state == UIGestureRecognizerStateBegan) {
        if ([self.delegate respondsToSelector:@selector(moduleView:didBeginDraggingWithGesture:)]) {
            [self.delegate moduleView:self didBeginDraggingWithGesture:uigr];
        }
    } else if (longPressGesture.state == UIGestureRecognizerStateChanged) {
        if ([self.delegate respondsToSelector:@selector(moduleView:didContinueDraggingWithGesture:)]) {
            [self.delegate moduleView:self didContinueDraggingWithGesture:uigr];
        }
    } else if (longPressGesture.state == UIGestureRecognizerStateEnded) {
        if ([self.delegate respondsToSelector:@selector(moduleView:didEndDraggingWithGesture:)]) {
            [self.delegate moduleView:self didEndDraggingWithGesture:uigr];
        }
    }
}

-(void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    if (!self.asset) {
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        CGContextSetStrokeColorWithColor(ctx, [[UIColor blackColor] CGColor]);
        CGContextSetLineWidth(ctx, 2);
        
        CGRect insetRect = CGRectInset(self.bounds, 1 , 1);
    
        CGContextStrokeRect(ctx, insetRect);
    }
}

-(void)trash {
    //[[COLAudioEnvironment sharedEnvironment] removeComponent:self.component];
    [self removeFromSuperview];
}

// Return a dictionary for adding to preset
-(NSDictionary*)getDictionary {
    
    NSMutableDictionary *controls = [[NSMutableDictionary alloc] initWithCapacity:[self.controlViews count]];
    for (ControlView *thisControl in self.controlViews) {
        NSString *controlName = [[COLAudioEnvironment sharedEnvironment] getParameterName:thisControl.parameter];
        [controls setObject:thisControl.getDictionaryObject forKey:controlName];
    }
    
    return @{
             PRESET_KEY_MODULE_TYPE         : self.moduleDescription.identifier,
             PRESET_KEY_MODULE_IDENTIFIER   : self.identifier,
             PRESET_KEY_MODULE_CENTER       : [NSValue valueWithCGPoint:self.center],
             PRESET_KEY_MODULE_CONTROLS     : [NSDictionary dictionaryWithDictionary:controls],
             };
}

// Initialize a module from a preset dictionary
-(instancetype)initWithDictionary:(NSDictionary*)dictionary {
    
    ModuleDescription *moduleDescription = [[ModuleCatalog sharedCatalog] moduleWithIdentifier:[dictionary objectForKey:PRESET_KEY_MODULE_TYPE]];
    
    if (moduleDescription) {
        if (self = [self initWithModuleDescription:moduleDescription]) {
            [self setCenter:[[dictionary objectForKey:PRESET_KEY_MODULE_CENTER] CGPointValue]];
            
            // Set parameters from dictionary
            NSDictionary *controlsDictionary = [dictionary objectForKey:PRESET_KEY_MODULE_CONTROLS];
            if (controlsDictionary) {
                for (ControlView *thisControl in self.controlViews) {
                    NSString *controlName = [[COLAudioEnvironment sharedEnvironment] getParameterName:thisControl.parameter];
                    [thisControl setFromDictionaryObject:[controlsDictionary objectForKey:controlName]];
                }
            }
        }
    }
    return self;
}

//    
//    COLComponent *component = [moduleView component];
//    
//    NSMutableDictionary *parameterDictionary = [[NSMutableDictionary alloc] initWithCapacity:[component numberOfParameters]];
//    
//    for (NSUInteger i = 0; i < [component numberOfParameters]; i++) {
//        COLParameter *parameter = [component parameterForIndex:i];
//        
//        NSNumber *value;
//        if ([parameter isKindOfClass:[COLDiscreteParameter class]]) {
//            COLDiscreteParameter *discreteParameter = (COLDiscreteParameter*)parameter;
//            value = [NSNumber numberWithFloat:[discreteParameter selectedIndex]];
//        } else if ([parameter isKindOfClass:[COLContinuousParameter class]]) {
//            COLContinuousParameter *continuousParameter = (COLContinuousParameter*)parameter;
//            value = [NSNumber numberWithFloat:[continuousParameter getNormalizedValue]];
//        }
//        
//        [parameterDictionary setValue:value forKey:parameter.name];
//    }
//    
//    NSDictionary *moduleDictionary = @{
//                                       @"id"        :   moduleView.moduleDescription.identifier,
//                                       @"params"    :   parameterDictionary,
//                                       @"center"    :   [NSValue valueWithCGPoint:moduleView.center]
//                                       };

@end
