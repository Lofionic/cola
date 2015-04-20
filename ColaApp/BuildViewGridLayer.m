//
//  BuildViewGridLayer.m
//  ColaApp
//
//  Created by Chris on 24/03/2015.
//  Copyright (c) 2015 Chris Rivers. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "BuildViewGridLayer.h"

@interface BuildViewGridLayer()

@property (nonatomic) UIImage *rackUpperImageRef;
@property (nonatomic) UIImage *rackLowerImageRef;

@end


@implementation BuildViewGridLayer

-(instancetype)init {
    
    if (self = [super init]) {
        self.rackUpperImageRef = [UIImage imageNamed:@"ImageAssets/rack_upper"];
        self.rackLowerImageRef = [UIImage imageNamed:@"ImageAssets/rack_lower"];
        
        self.contentsScale = [[UIScreen mainScreen] scale];
    }
    
    return self;
}

-(void)drawInContext:(CGContextRef)ctx {
    
    CGContextSetStrokeColorWithColor(ctx, [UIColor darkGrayColor].CGColor);
    CGContextSetLineWidth(ctx, 0.5);
    
    CGFloat yPosition = self.buildView.headerHeight - 16;
    do {
        for (CGFloat xPosition = 0; xPosition < self.bounds.size.width; xPosition += self.buildView.cellSize.width) {
            CGRect rect = CGRectMake(xPosition, yPosition, self.buildView.cellSize.width, 16);
            CGContextDrawImage(ctx, rect, [self.rackUpperImageRef CGImage]);
            
            rect = CGRectOffset(rect, 0, 16);
            CGContextDrawImage(ctx, rect, [self.rackLowerImageRef CGImage]);
        }
        
        yPosition += self.buildView.cellSize.height;
        
    } while (yPosition <= self.bounds.size.height);
}

@end
