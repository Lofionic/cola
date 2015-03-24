//
//  BuildViewHighlightLayer.m
//  ColaApp
//
//  Created by Chris on 24/03/2015.
//  Copyright (c) 2015 Chris Rivers. All rights reserved.
//

#import "BuildViewHighlightLayer.h"

@implementation BuildViewHighlightLayer

-(void)drawInContext:(CGContextRef)ctx {
        // Draw highlighed cell
        if (self.buildView.highlightedCellSet) {
            CGRect highlightRect = [self.buildView rectForCellSet:self.buildView.highlightedCellSet];
            highlightRect = CGRectInset(highlightRect, 2, 2);
            CGContextAddRect(ctx, highlightRect);
            CGContextSetStrokeColorWithColor(ctx, [[UIColor redColor] CGColor]);
            CGContextSetLineWidth(ctx, 4);
            CGContextStrokePath(ctx);
        }
}

@end
