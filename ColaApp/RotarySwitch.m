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

@property (nonatomic, strong) CALayer   *needleLayer;
@property (nonatomic) NSUInteger        maxIndex;
@property (nonatomic) NSUInteger        selectedIndex;

@end

@implementation RotarySwitch {
    BOOL        tracking;
    CGFloat     trackingY;
    NSUInteger  trackingValue;
    double      needleOffset;
}

-(instancetype)initWithParameter:(CCOLParameterAddress)parameter Description:(ControlDescription *)description {
    if (self = [super initWithParameter:parameter Description:description]) {
        self.maxIndex = [[description.userInfo objectForKey:@"maxindex"] integerValue];
        self.selectedIndex = 0;
        
        NSString *encoderAsset = [ASSETS_PATH_CONTROLS stringByAppendingString:@"encoder"];
        UIImage *encoderImage = [UIImage imageNamed:encoderAsset];
        if (encoderImage) {
            [self.layer setContents:(id)encoderImage.CGImage];
        }
        
        NSString *needleAsset = [ASSETS_PATH_CONTROLS stringByAppendingString:@"encoder_needle"];
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
    [self setSelectedIndex:floor([[COLAudioEnvironment sharedEnvironment] getParameterValue:self.parameter] * self.maxIndex)];
    [self updateNeedleAnimated:NO];
}


-(void)updateNeedleAnimated:(BOOL)animated {

    double offset = (M_PI / 2.0) + (((self.maxIndex - 1) / 12.0) * M_PI);
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
    if (value < self.maxIndex) {
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
            [[COLAudioEnvironment sharedEnvironment] setParameter:self.parameter value:self.selectedIndex / (float)self.maxIndex];
            [self updateNeedleAnimated:YES];
        }
    }
}

-(NSObject *)getDictionaryObject {
    return [NSNumber numberWithInteger:self.selectedIndex];
}

-(void)setFromDictionaryObject:(NSObject *)object {
    NSNumber *number = (NSNumber*)object;
    NSUInteger value = [number integerValue];
    self.selectedIndex = value;
    [self updateNeedleAnimated:NO];
    
    [[COLAudioEnvironment sharedEnvironment] setParameter:self.parameter value:self.selectedIndex / (float)self.maxIndex];
}

@end
