//
//  RotaryEncoder.m
//  ColaApp
//
//  Created by Chris on 23/03/2015.
//  Copyright (c) 2015 Chris Rivers. All rights reserved.
//

#import "RotaryEncoder.h"

#import "defines.h"
#import "ModuleDescription.h"
#import <ColaLib/COLAudioEnvironment.h>

@interface RotaryEncoder ()

@property (nonatomic, strong) CALayer               *needleLayer;

@end

@implementation RotaryEncoder {
    BOOL        tracking;
    CGFloat     trackingY;
    double      trackingValue;
}

-(instancetype)initWithParameter:(CCOLParameterAddress)parameter Description:(ControlDescription*)controlDescription {
    if (self = [super initWithParameter:parameter Description:controlDescription]) {
        self.value = 0;
        
        // Default assets
        NSString *encoderAssetName = @"encoder";
        NSString *needleAssetName = @"encoder_needle";
        
        // Custom assets included in user info
        if ([controlDescription.userInfo objectForKey:CONTROL_USERINFO_ASSET_KEY]) {
            encoderAssetName = [NSString stringWithFormat:@"%@_%@", encoderAssetName, [controlDescription.userInfo objectForKey:CONTROL_USERINFO_ASSET_KEY]];
            needleAssetName = [NSString stringWithFormat:@"%@_%@", needleAssetName, [controlDescription.userInfo objectForKey:CONTROL_USERINFO_ASSET_KEY]];
        }
        
        // Load the assets
        NSString *encoderAsset = [ASSETS_PATH_CONTROLS stringByAppendingString:encoderAssetName];
        UIImage *encoderImage = [UIImage imageNamed:encoderAsset];
        if (encoderImage) {
            [self.layer setContents:(id)encoderImage.CGImage];
        }

        NSString *needleAsset = [ASSETS_PATH_CONTROLS stringByAppendingString:needleAssetName];
        UIImage *needleImage = [UIImage imageNamed:needleAsset];
        if (needleImage) {
            self.needleLayer = [CALayer layer];
            [self.needleLayer setContents:(id)needleImage.CGImage];
            [self.layer addSublayer:self.needleLayer];
        }
        
        CGFloat size = encoderImage.size.width;

        [self setFrame:CGRectMake(0, 0, size, size)];
        [self.needleLayer setFrame:self.bounds];
        
        [self updateFromParameter];
    }
    return  self;
}

-(void)updateFromParameter {
    [self setValue:[[COLAudioEnvironment sharedEnvironment] getParameterValue:self.parameter]];
}


-(void)updateNeedleAnimated:(BOOL)animated {
    double theta = ((M_PI * 2.0) * self.value * (5.0 / 6.0)) + (M_PI * (2.0 / 3.0));
    
    BOOL disableActions = [CATransaction disableActions];
    [CATransaction setDisableActions:!animated];
    [self.needleLayer setAffineTransform:CGAffineTransformRotate(CGAffineTransformIdentity, theta)];
    [CATransaction setDisableActions:disableActions];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    tracking = YES;
    
    UITouch *touch = [touches anyObject];
    trackingY = [touch locationInView:self].y;
    trackingValue = self.value;
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    if (tracking) {
        UITouch *touch = [touches anyObject];
        CGFloat translation = trackingY - [touch locationInView:self].y;
        CGFloat delta = translation / 200.0;
        self.value = trackingValue + delta;
        
        self.value = MIN(1.0, self.value);
        self.value = MAX(0.0, self.value);
        
        [self setNeedsDisplay];
        
        [[COLAudioEnvironment sharedEnvironment] setParameter:self.parameter value:self.value];
    }
}

@synthesize value = _value;

-(double)value {
    return _value;
}

-(void)setValue:(double)value {
    _value = value;
    [self updateNeedleAnimated:NO];
}

-(NSObject *)getDictionaryObject {
    return [NSNumber numberWithDouble:self.value];
}

-(void)setFromDictionaryObject:(NSObject *)object {
    self.value = [((NSNumber*)object) doubleValue];
    [self setNeedsDisplay];
    
    [[COLAudioEnvironment sharedEnvironment] setParameter:self.parameter value:self.value];
}

@end
