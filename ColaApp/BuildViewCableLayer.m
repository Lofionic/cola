//
//  BuildViewCableLayer.m
//  ColaApp
//
//  Created by Chris on 24/03/2015.
//  Copyright (c) 2015 Chris Rivers. All rights reserved.
//

#import "BuildViewCableLayer.h"

@implementation BuildViewCableLayer

-(void)drawInContext:(CGContextRef)ctx {
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
        
        CGContextSetStrokeColorWithColor(ctx, [cable.colour CGColor]);
        CGContextSetLineWidth(ctx, 10);
        CGContextSetLineCap(ctx, kCGLineCapRound);
        
        CGFloat hang = MIN(abs(cable.point2.x - cable.point1.x), 40);
        CGFloat bottom = MAX(cable.point1.y, cable.point2.y) + hang;
        
        CGFloat hangLeft = cable.point1.x + ((cable.point2.x - cable.point1.x) * 0.25);
        CGFloat hangRight = cable.point1.x + ((cable.point2.x - cable.point1.x) * 0.75);
        
        CGPoint controlPoint1 = CGPointMake(hangLeft, bottom);
        CGPoint controlPoint2 = CGPointMake(hangRight, bottom);
        
        UIBezierPath *bezierPath = [UIBezierPath bezierPath];
        [bezierPath moveToPoint:(cable.point1)];
        [bezierPath addCurveToPoint:cable.point2 controlPoint1:controlPoint1 controlPoint2:controlPoint2];
        
        CGContextAddPath(ctx, bezierPath.CGPath);
        CGContextStrokePath(ctx);
        
        CGContextSetStrokeColorWithColor(ctx, [[UIColor colorWithWhite:0 alpha:0.2] CGColor]);
        CGContextAddPath(ctx, bezierPath.CGPath);
        CGContextStrokePath(ctx);
        
        CGContextSetStrokeColorWithColor(ctx, [cable.colour CGColor]);
        CGContextTranslateCTM(ctx, 0, -2);
        CGContextAddPath(ctx, bezierPath.CGPath);
        CGContextStrokePath(ctx);
        
        CGContextSetStrokeColorWithColor(ctx, [[UIColor colorWithWhite:1 alpha:0.2] CGColor]);
        CGContextSetLineWidth(ctx, 4);
        CGContextAddPath(ctx, bezierPath.CGPath);
        CGContextStrokePath(ctx);
        
        CGContextRestoreGState(ctx);
    }
}

@end

