//
//  BuildViewScrollView.m
//  ColaApp
//
//  Created by Chris on 22/04/2015.
//  Copyright (c) 2015 Chris Rivers. All rights reserved.
//
#import "defines.h"
#import "BuildViewScrollView.h"
#define TOUCH_MOVEMENT_THRESHOLD    10

@interface BuildViewScrollView ()

@property CGPoint   touchPoint;
@property NSTimer*  autoscrollTimer;
@property BOOL      autoscrolling;

@property UIImageView *backgroundImageView;

@end

@implementation BuildViewScrollView

-(instancetype)init {
    if (self = [super init]) {
        self.enableAutoscroll = NO;
        self.clipsToBounds = NO;
        
        UIImage *backgroundImage = [[UIImage imageNamed:@"build_background"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, kBuildViewPadding, 0, kBuildViewPadding) resizingMode:UIImageResizingModeTile];
        self.backgroundImageView = [[UIImageView alloc] initWithImage:backgroundImage];
        [self addSubview:self.backgroundImageView];
    }
    return self;
}

-(void)layoutSubviews {
    [super layoutSubviews];
    
    // Stretch the background image downwards to match content
    [self.backgroundImageView setFrame:CGRectMake(0, 0, self.bounds.size.width, self.contentSize.height)];
}

-(UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    // Nothing underneath this view should be hit
    UIView *hit = [super hitTest:point withEvent:event];
    if (!hit) {
        return self;
    } else {
        return hit;
    }
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    self.touchPoint = [touch locationInView:self];
    self.autoscrollTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(autoScroll) userInfo:nil repeats:YES];
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    CGPoint previousTouchPoint = self.touchPoint;
    
    UITouch *touch = [touches anyObject];
    self.touchPoint = [touch locationInView:self];

    CGFloat touchDelta = sqrt(pow(ABS(self.touchPoint.x - previousTouchPoint.x) + ABS(self.touchPoint.y - previousTouchPoint.y),2.0));
    
    if (touchDelta > TOUCH_MOVEMENT_THRESHOLD) {
        [self.autoscrollTimer invalidate];
        self.autoscrollTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(autoScroll) userInfo:nil repeats:YES];
    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.autoscrollTimer invalidate];
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.autoscrollTimer invalidate];
}

-(void)autoScroll {
    if (!self.tracking && self.enableAutoscroll) {
        // Auto-scroll if necessary
        if (self.touchPoint.y < (self.frame.size.height * 0.3) + self.contentOffset.y) {
            // Audoscroll up
            CGFloat targetY = MAX(self.touchPoint.y - (self.frame.size.height / 2.0), 0);
            CGRect targetRect = CGRectMake(0, targetY, 1, 1);
            
            self.autoscrolling = YES;
            [self scrollRectToVisible:targetRect animated:YES];
            
            CGFloat deltaY = self.touchPoint.y - targetY;
            self.touchPoint = CGPointMake(self.touchPoint.x, self.touchPoint.y - deltaY);
        } else if (self.touchPoint.y > (self.frame.size.height * 0.7) + self.contentOffset.y) {
            // Audoscroll down
            
            CGFloat targetY = MIN(self.touchPoint.y + (self.frame.size.height / 2.0), self.contentSize.height - 1    );
            CGRect targetRect = CGRectMake(0, targetY, 1, 1);
            
            self.autoscrolling = YES;
            [self scrollRectToVisible:targetRect animated:YES];
            
            CGFloat deltaY = self.touchPoint.y - targetY;
            self.touchPoint = CGPointMake(self.touchPoint.x, self.touchPoint.y - deltaY);
        }
    }
}

@end
