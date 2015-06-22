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
#import "NSString+Random.h"
#import "BuildView.h"

#import "RotaryEncoder.h"
#import "RotarySwitch.h"

#define BACKGROUND_COLOUR [UIColor colorWithRed:64/255.0 green:64/255.0 blue:64/255.0 alpha:1]

@interface ModuleView ()

@property (nonatomic, weak) COLComponent        *component;
@property (nonatomic, strong) NSString          *asset;
@property (nonatomic, strong) ModuleDescription *moduleDescription;

@end

@implementation ModuleView

-(instancetype)initWithModuleDescription:(ModuleDescription *)moduleDescription inFrame:(CGRect)frame identifier:(NSString*)identifier {
    
    COLComponent *component = [[COLAudioEnvironment sharedEnvironment] createComponentOfType:moduleDescription.type];
    if (!component) {
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
    
    NSMutableArray *connectorViews = [[NSMutableArray alloc] initWithCapacity:[connectors count]];
    
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
            [connectorViews addObject:connectorView];
        } else {
            NSLog(@"Error!");
        }
    }
    
    self.connectorViews = [NSArray arrayWithArray:connectorViews];
}

-(ConnectorView*)connectorForName:(NSString*)name {
    __block ConnectorView *result = nil;
    
    [self.connectorViews enumerateObjectsUsingBlock:^(ConnectorView *obj, NSUInteger index, BOOL *stop) {
        if ([obj.componentIO.name isEqualToString:name]) {
            result = obj;
            *stop = YES;
        }
    }];
    
    return result;
}

-(void)addControls:(NSArray*)controls {
  
    NSMutableArray *controlViews = [[NSMutableArray alloc] initWithCapacity:[controls count]];
    
    for (ControlDescription *thisControl in controls) {
        // Find the parameter
        COLParameter *parameter = [self.component parameterNamed:thisControl.parameterName];
        ModuleControl *controlView = [ModuleControl controlForParameter:parameter Description:thisControl];
        if (controlView) {
            [controlView setCenter:thisControl.location];
            [self addSubview:controlView];
            [controlViews addObject:controlView];
        }
    }
    
    self.controlViews = [NSArray arrayWithArray:controlViews];
}

-(void)setParametersFromDictionary:(NSDictionary*)parametersDictionary {
    
    for (NSString *thisParameter in [parametersDictionary allKeys]) {
        [self.controlViews enumerateObjectsUsingBlock:^(ModuleControl *obj, NSUInteger index, BOOL *stop) {
            if ([obj isKindOfClass:[RotaryEncoder class]]) {
                RotaryEncoder *rotaryEncoder = (RotaryEncoder*)obj;
                if ([rotaryEncoder.parameter.name isEqualToString:thisParameter]) {
                    [rotaryEncoder.parameter setNormalizedValue:[[parametersDictionary objectForKey:thisParameter] floatValue]];
                    [rotaryEncoder updateFromParameter];
                }
            }
            
            if ([obj isKindOfClass:[RotarySwitch class]]) {
                RotarySwitch *rotarySwitch = (RotarySwitch*)obj;
                if ([rotarySwitch.parameter.name isEqualToString:thisParameter]) {
                    [rotarySwitch.parameter setSelectedIndex:[[parametersDictionary objectForKey:thisParameter] integerValue]];
                    [rotarySwitch updateFromParameter];
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
    [[COLAudioEnvironment sharedEnvironment] removeComponent:self.component];
    [self removeFromSuperview];
}

@end
