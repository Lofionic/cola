//
//  SequenerKnob.m
//  ColaApp
//
//  Created by Chris on 04/02/2016.
//  Copyright © 2016 Chris Rivers. All rights reserved.
//

#import "SequencerKnob.h"
#import "SequencerSubview.h"



@interface SequencerKnob ()

@property (nonatomic, strong) UIImage *baseImage;
@property (nonatomic, strong) UIImage *dialImage;
@property (nonatomic, strong) CALayer *dialLayer;

@property (nonatomic) double level;

@end

@implementation SequencerKnob {
    BOOL        tracking;
    CGFloat     trackingY;
    double      trackingValue;
}

-(void)didMoveToSuperview {
    // Load images
    self.baseImage = [UIImage imageNamed:@"sequencer_knobbase"];
    self.dialImage = [UIImage imageNamed:@"sequencer_knobdial"];
    
    // Set images in layer
    [self.layer setContents:(id)self.baseImage.CGImage];
    
    self.dialLayer = [CALayer layer];
    [self.dialLayer setFrame:self.bounds];
    [self.dialLayer setContents:(id)self.dialImage.CGImage];
    [self.layer addSublayer:self.dialLayer];
    
    [self setLevel:0];
}

-(void)setLevel:(double)level animated:(BOOL)animated {
    _level = level;
    [self updateNeedleAnimated:YES];
}

-(void)setLevel:(double)level {
    _level = level;
    [self updateNeedleAnimated:NO];
}

-(void)updateNeedleAnimated:(BOOL)animated {
    double theta = ((M_PI * 2.0) * self.level * (5.0 / 6.0)) + (M_PI * (2.0 / 3.0));
    
    BOOL disableActions = [CATransaction disableActions];
    [CATransaction setDisableActions:!animated];
    [self.dialLayer setAffineTransform:CGAffineTransformRotate(CGAffineTransformIdentity, theta)];
    [CATransaction setDisableActions:disableActions];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    tracking = YES;
    
    UITouch *touch = [touches anyObject];
    trackingY = [touch locationInView:self].y;
    trackingValue = self.level;
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    if (tracking) {
        double prevLevel = self.level;
        
        UITouch *touch = [touches anyObject];
        CGFloat translation = trackingY - [touch locationInView:self].y;
        CGFloat delta = translation / 200.0;
        self.level = trackingValue + delta;
        
        self.level = MIN(1.0, self.level);
        self.level = MAX(0.0, self.level);
        
        if (prevLevel != self.level) {
            // Notify delegate that level has changed
            if (self.delegate) {
                [self.delegate sequencerKnob:self didChangeLevelTo:self.level];
            }
        }
        
        [self setNeedsDisplay];
    }
}

@end
