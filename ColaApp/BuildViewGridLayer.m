//
//  BuildViewGridLayer.m
//  ColaApp
//
//  Created by Chris on 24/03/2015.
//  Copyright (c) 2015 Chris Rivers. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "BuildViewGridLayer.h"

@implementation BuildViewGridLayer

-(void)drawInContext:(CGContextRef)ctx {
    // Draw grid
    CGContextSetStrokeColorWithColor(ctx, [UIColor darkGrayColor].CGColor);
    CGContextSetLineWidth(ctx, 0.5);
    
    CGFloat yPosition = self.buildView.headerHeight;
    do {
        CGContextMoveToPoint(ctx, 0, yPosition);
        CGContextAddLineToPoint(ctx, self.bounds.size.width, yPosition);
        yPosition += self.buildView.cellSize.height;
    } while (yPosition < self.bounds.size.height);
    
    CGFloat xPosition = self.buildView.cellSize.width;
    do {
        CGContextMoveToPoint(ctx, xPosition, self.buildView.headerHeight);
        CGContextAddLineToPoint(ctx, xPosition, self.bounds.size.height);
        xPosition += self.buildView.cellSize.width;
    } while (xPosition < self.bounds.size.width);
    
    CGContextStrokePath(ctx);
}

@end
