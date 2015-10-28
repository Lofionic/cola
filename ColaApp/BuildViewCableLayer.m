//
//  BuildViewCableLayer.m
//  ColaApp
//
//  Created by Chris on 24/03/2015.
//  Copyright (c) 2015 Chris Rivers. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import <CoreMotion/CoreMotion.h>
#import "BuildViewCableLayer.h"
#import "BuildView.h"
#import "UIColor+Shades.h"

@interface BuildViewCableLayer ()
@property (nonatomic, strong) CADisplayLink *displayLink;
@property (nonatomic) BOOL displayLinkRunning;
@property (nonatomic, strong) CMMotionManager *motionManager;
@end


@implementation BuildViewCableLayer

-(instancetype)init {
    if (self = [super init]) {
        self.contentsScale = [[UIScreen mainScreen] scale];
    }
    return self;
}

//- (instancetype)init
//{
//    self = [super init];
//    if (self)
//    {
////        self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(setNeedsDisplay)];
////        [self.displayLink setFrameInterval:4];
////        [self setNeedsDisplayOnBoundsChange:YES];
//        
////        self.motionManager = [[CMMotionManager alloc] init];
////        [self.motionManager setDeviceMotionUpdateInterval:1/15.0];
////        if ([self.motionManager isDeviceMotionAvailable]) {
////            // to avoid using more CPU than necessary we use `CMAttitudeReferenceFrameXArbitraryZVertical`
////            [self.motionManager startDeviceMotionUpdatesUsingReferenceFrame:CMAttitudeReferenceFrameXArbitraryZVertical];
////        }
//    }
//    return self;
//}

-(void)drawInContext:(CGContextRef)ctx {

//    if (!self.displayLinkRunning) {
//        [self.displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
//        self.displayLinkRunning = YES;
//    }
    
    for (BuildViewCable *cable in self.buildView.cables) {
        CGContextSaveGState(ctx);
        
        CGContextSetFillColorWithColor(ctx, [[UIColor darkGrayColor] CGColor]);
        CGRect rect1 = CGRectMake(cable.point1.x - 8, cable.point1.y - 8, 16, 16);
        CGContextFillEllipseInRect(ctx, rect1);
        
        CGRect rect2 = CGRectMake(cable.point2.x - 8, cable.point2.y - 8, 16, 16);
        CGContextFillEllipseInRect(ctx, rect2);
        
        CGContextSetFillColorWithColor(ctx, [[UIColor lightGrayColor] CGColor]);
        CGContextFillEllipseInRect(ctx, CGRectOffset(rect1, 0, -2));
        CGContextFillEllipseInRect(ctx, CGRectOffset(rect2, 0, -2));
    }
    
    for (BuildViewCable *cable in self.buildView.cables) {
        CGFloat hang = MIN(fabs(cable.point2.x - cable.point1.x), 40);
        CGFloat bottom = MAX(cable.point1.y, cable.point2.y) + hang;
        
        CGFloat sway = (self.motionManager.deviceMotion.attitude.roll * 0.25);
        
        CGPoint left;
        CGPoint right;
        
        if (cable.point1.x < cable.point2.x) {
            left = cable.point1;
            right = cable.point2;
        } else {
            left = cable.point2;
            right = cable.point1;
        }
        
        CGFloat hangLeft = left.x + ((right.x - left.x) * (0.25 + sway));
        CGFloat hangRight = left.x + ((right.x - left.x) * (0.75 + sway));
        
        CGPoint controlPoint1 = CGPointMake(hangLeft, bottom);
        CGPoint controlPoint2 = CGPointMake(hangRight, bottom);
        
        UIBezierPath *bezierPath = [UIBezierPath bezierPath];
        [bezierPath moveToPoint:left];
        [bezierPath addCurveToPoint:right controlPoint1:controlPoint1 controlPoint2:controlPoint2];
        
        CGContextSetLineCap(ctx, kCGLineCapRound);
        
        // Stroke Shadow
        CGContextAddPath(ctx, bezierPath.CGPath);
        CGContextSetStrokeColorWithColor(ctx, [[cable.colour darkerShade] CGColor]);
        CGContextSetLineWidth(ctx, 6);

        CGContextStrokePath(ctx);
        
        // Stroke Mid
        CGContextSetStrokeColorWithColor(ctx, [[cable.colour midShade] CGColor]);
        CGContextTranslateCTM(ctx, 0, -2);
        CGContextSetLineWidth(ctx, 4);
        CGContextAddPath(ctx, bezierPath.CGPath);
        CGContextStrokePath(ctx);
        
        // Stroke Highlight
        CGContextSetStrokeColorWithColor(ctx, [[cable.colour lighterShade] CGColor]);
        CGContextTranslateCTM(ctx, 0, -2);
        CGContextSetLineWidth(ctx, 1);
        CGContextAddPath(ctx, bezierPath.CGPath);
        CGContextStrokePath(ctx);
        
        CGContextRestoreGState(ctx);
    }
}

@end

