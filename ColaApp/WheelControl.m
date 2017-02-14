//
//  PitchbendWheelControl.m
//  Ogre
//
//  Created by Chris on 10/10/2014.
//  Copyright (c) 2014 ccr. All rights reserved.
//
//#import "BuildSettings.h"
#import "WheelControl.h"
#import <ColaLib/COLAudioEnvironment.h>

#define SCREEN_SCALE [[UIScreen mainScreen] scale]

@interface WheelControl()

@property (nonatomic) WheelControlType wheelControlType;
@property (nonatomic) CGSize spriteSize;

@end

@implementation WheelControl {
    CGFloat trackingY;
    CGFloat trackingValue;
    bool tracking;
}


@synthesize value = _value;

- (instancetype)initWithControlType:(WheelControlType)controlType {
    self = [super init];
    if (self) {
        self.wheelControlType = controlType;
        self.spriteSheet = [UIImage imageNamed:@"pitchwheel"];
        self.spriteSize = CGSizeMake(60 * SCREEN_SCALE, 150 * SCREEN_SCALE);
        if (self.wheelControlType == WheelControlTypePitchbend) {
            self.value = 0.5;
        } else {
            self.value = 0;
        }
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    if (_spriteSheet) {
        // draw control
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        CGContextSaveGState(ctx);
        CGContextScaleCTM(ctx, 1.0, -1.0);
        
        int sprites = ((self.spriteSheet.size.height / self.spriteSize.height) * SCREEN_SCALE) - 1;
        int frame = (self.value * sprites);
        CGRect sourceRect = CGRectMake(0, frame * self.spriteSize.height, self.spriteSize.width, self.spriteSize.height);
        CGImageRef drawImage = CGImageCreateWithImageInRect([self.spriteSheet CGImage], sourceRect);
        
        CGContextDrawImage(ctx, CGRectMake(0, 0, self.bounds.size.width, -self.bounds.size.height), drawImage);
        CGImageRelease(drawImage);
        CGContextRestoreGState(ctx);
    }
}

-(BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    trackingY = [touch locationInView:self].y;
    trackingValue = self.value;
    return YES;
}

-(BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    
    CGFloat newPosition = [touch locationInView:self].y;
    CGFloat delta = trackingY - newPosition;

    self.value = trackingValue + (delta / self.frame.size.height);
    
    [self setNeedsDisplay];
    
    [self sendActionsForControlEvents:UIControlEventValueChanged];
    
    return YES;
}

-(void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    
    if (self.wheelControlType == WheelControlTypePitchbend) {
        self.value = 0.5;
    }
    [self setNeedsDisplay];
    [self sendActionsForControlEvents:UIControlEventValueChanged];
    
}

- (void)setValue:(CGFloat)value {
    _value = fmax(fmin(value, 1.0), 0.0);
    
    switch (self.wheelControlType) {
        case WheelControlTypePitchbend:
            [[COLAudioEnvironment sharedEnvironment] pitchBend:_value];
            break;
        case WheelControlTypeModulation:
            [[COLAudioEnvironment sharedEnvironment] modulate:_value];
            break;
    }
}

- (CGFloat)value {
    return _value;
}

@end
