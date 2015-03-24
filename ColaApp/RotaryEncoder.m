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
        
        [self setBackgroundColor:[UIColor clearColor]];
    }
    return  self;
}

-(void)drawRect:(CGRect)rect {
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGRect ellipseRect = CGRectInset(rect, 4, 4);
    
    // Draw dial
    CGContextSetFillColorWithColor(ctx, [DIAL_COLOUR CGColor]);
    CGContextFillEllipseInRect(ctx, ellipseRect);
    
    // Draw Needle
    CGFloat radius = ellipseRect.size.width / 2.0;
    CGPoint centre = CGPointMake(rect.size.width / 2.0,
                                 rect.size.height / 2.0 );
    
    double theta = ((M_PI * 2.0) * self.value * 0.75) + (M_PI * (3.0 / 4.0));
    
    CGPoint endPoint = CGPointMake(centre.x + (cos(theta) * radius),
                                   centre.y + (sin(theta) * radius));
    
    CGContextSetLineWidth(ctx, 2);
    CGContextSetStrokeColorWithColor(ctx, [NEEDLE_COLOUR CGColor]);
    CGContextMoveToPoint(ctx, centre.x, centre.y);
    CGContextAddLineToPoint(ctx, endPoint.x, endPoint.y);
    CGContextStrokePath(ctx);
    
    CGContextSetStrokeColorWithColor(ctx, [OUTLINE_COLOUR CGColor]);
    CGContextStrokeEllipseInRect(ctx, ellipseRect);
    
    [super drawRect:rect];
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
        CGFloat delta = translation / 500.0;
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
    [self setNeedsDisplay];
}

@end
