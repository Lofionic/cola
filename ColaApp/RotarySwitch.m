//
//  RotarySwitch.m
//  ColaApp
//
//  Created by Chris on 01/04/2015.
//  Copyright (c) 2015 Chris Rivers. All rights reserved.
//
#import "RotarySwitch.h"

#import "defines.h"
#import "ModuleDescription.h"
#import <ColaLib/COLAudioEnvironment.h>
#import <ColaLib/CCOLTypes.h>


@interface RotarySwitch ()

@property (nonatomic) CCOLParameterAddress   parameter;
@property (nonatomic, strong) CALayer               *needleLayer;

@end

@implementation RotarySwitch {
    BOOL        tracking;
    CGFloat     trackingY;
    NSUInteger  trackingValue;
    double      needleOffset;
}

-(instancetype)initWithDiscreteParameter:(CCOLParameterAddress)parameter Description:(ControlDescription*)controlDescription {
    if (self = [super init]) {
        self.parameter = parameter;
        self.selectedIndex = 0;
        
        if (controlDescription.asset) {
            NSString *encoderAsset = [ASSETS_PATH_CONTROLS stringByAppendingString:[@"encoder_" stringByAppendingString:controlDescription.asset]];
            UIImage *encoderImage = [UIImage imageNamed:encoderAsset];
            if (encoderImage) {
                [self.layer setContents:(id)encoderImage.CGImage];
            }
            
            NSString *needleAsset = [ASSETS_PATH_CONTROLS stringByAppendingString:[@"encoder_needle_" stringByAppendingString:controlDescription.asset]];
            UIImage *needleImage = [UIImage imageNamed:needleAsset];
            if (needleImage) {
                self.needleLayer = [CALayer layer];
                [self.needleLayer setContents:(id)needleImage.CGImage];
                [self.layer addSublayer:self.needleLayer];
            }
            
            [self setFrame:CGRectMake(0, 0, encoderImage.size.width, encoderImage.size.height)];
            [self.needleLayer setFrame:CGRectMake(0, 0, encoderImage.size.width, encoderImage.size.height)];
        }
        
        [self updateFromParameter];
    }
    return  self;
}

-(void)updateFromParameter {
    [self setSelectedIndex:floor([[COLAudioEnvironment sharedEnvironment] getDiscreteParameterSelectedIndex:self.parameter])];
    [self updateNeedleAnimated:NO];
}


-(void)updateNeedleAnimated:(BOOL)animated {
    CCOLDiscreteParameterIndex maxIndex = [[COLAudioEnvironment sharedEnvironment] getDiscreteParameterMaxIndex:self.parameter];
    double offset = (M_PI / 2.0) + (((maxIndex - 1) / 12.0) * M_PI);
    double theta = ((M_PI * 2.0) * (self.selectedIndex / 12.0));
    
    BOOL disableActions = [CATransaction disableActions];
    [CATransaction setDisableActions:!animated];
    [self.needleLayer setAffineTransform:CGAffineTransformRotate(CGAffineTransformIdentity, theta - offset)];
    [CATransaction setDisableActions:disableActions];
}

@synthesize selectedIndex = _selectedIndex;

-(NSUInteger)selectedIndex {
    return _selectedIndex;
}

-(void)setSelectedIndex:(NSUInteger)value {
    CCOLDiscreteParameterIndex maxIndex = [[COLAudioEnvironment sharedEnvironment] getDiscreteParameterMaxIndex:self.parameter];
    if (value < maxIndex) {
        _selectedIndex = value;
    }
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    tracking = YES;
    
    UITouch *touch = [touches anyObject];
    trackingY = [touch locationInView:self].y;
    trackingValue = self.selectedIndex;
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    if (tracking) {
        UITouch *touch = [touches anyObject];
        CGFloat translation = trackingY - [touch locationInView:self].y;
        NSInteger delta = floor(translation / 40.0);
        if (delta > 1) {
            delta = 1;
        } else if (delta < -1) {
            delta = -1;
        }
        if (self.selectedIndex != trackingValue + delta) {
            self.selectedIndex = trackingValue + delta;
            [[COLAudioEnvironment sharedEnvironment] setDiscreteParameterSelectedIndex:self.parameter index:(CCOLDiscreteParameterIndex)self.selectedIndex];
            [self updateNeedleAnimated:YES];
        }
    }
}

@end
