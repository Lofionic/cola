//
//  RotaryEncoder.m
//  ColaApp
//
//  Created by Chris on 23/03/2015.
//  Copyright (c) 2015 Chris Rivers. All rights reserved.
//

#import "RotaryEncoder.h"

#define DIAL_COLOUR     [UIColor colorWithRed:50/255.0 green:50/255.0 blue:50/255.0 alpha:1]
#define OUTLINE_COLOUR  [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.5]
#define NEEDLE_COLOUR   [UIColor colorWithRed:255/255.0 green:0/255.0 blue:0/255.0 alpha:1]

@interface RotaryEncoder ()

@property (nonatomic, weak) COLComponentParameter *parameter;
@property (nonatomic, strong) CALayer *needleLayer;
@property NSInteger needleRotation;

@end

@implementation RotaryEncoder {
    BOOL        tracking;
    CGFloat     trackingY;
    double      trackingValue;
}

-(instancetype)initWithParameter:(COLComponentParameter *)parameter {
    if (self = [super initWithFrame:CGRectMake(0, 0, 40, 40)]) {
        self.parameter = parameter;
        self.value = 0;
        
        UIImage *encoderImage = [UIImage imageNamed:@"ImageAssets/encoder_white"];
        if (encoderImage) {
            [self.layer setContents:(id)encoderImage.CGImage];
        }
        
        UIImage *needleImage = [UIImage imageNamed:@"ImageAssets/encoder_needle_grey"];
        if (needleImage) {
            self.needleLayer = [CALayer layer];
            [self.needleLayer setFrame:CGRectMake(0, 0, 40, 40)];
            [self.needleLayer setContents:(id)needleImage.CGImage];
            [self.layer addSublayer:self.needleLayer];
        }
    }
    return  self;
}


-(void)updateNeedleAnimated:(BOOL)animated {
    double theta = ((M_PI * 2.0) * self.value * 0.75) + (M_PI * (3.0 / 4.0));
    
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
        
        [self.parameter setNormalizedValue:self.value];
        
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

@end
