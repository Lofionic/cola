//
//  BuildViewScrollView.m
//  ColaApp
//
//  Created by Chris on 22/04/2015.
//  Copyright (c) 2015 Chris Rivers. All rights reserved.
//

#import "BuildViewScrollView.h"

@interface BuildViewScrollView ()

@property CGPoint touchPoint;
@property NSTimer *autoscrollTimer;

@end

@implementation BuildViewScrollView


-(instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {

    }
    return self;
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
    UITouch *touch = [touches anyObject];
    self.touchPoint = [touch locationInView:self];

    [self.autoscrollTimer invalidate];
    self.autoscrollTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(autoScroll) userInfo:nil repeats:YES];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.autoscrollTimer invalidate];
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.autoscrollTimer invalidate];
}

-(void)autoScroll {
    // Scroll if necessary
    if (self.touchPoint.y < (self.frame.size.height / 2.0) + self.bounds.origin.y) {
        // Audoscroll up
        CGFloat targetY = MAX(self.touchPoint.y - (self.frame.size.height / 2.0), 0);
        CGRect targetRect = CGRectMake(0, targetY, 1, 1);
        [self scrollRectToVisible:targetRect animated:YES];
        
        CGFloat deltaY = self.touchPoint.y - targetY;
        self.touchPoint = CGPointMake(self.touchPoint.x, self.touchPoint.y - deltaY);
    } else if (self.touchPoint.y > (self.frame.size.height / 2.0) + self.bounds.origin.y) {
        // Audoscroll down
        CGFloat targetY = MIN(self.touchPoint.y + (self.frame.size.height / 2.0), self.contentSize.height);
        CGRect targetRect = CGRectMake(0, targetY, 1, 1);
        [self scrollRectToVisible:targetRect animated:YES];
        
        CGFloat deltaY = self.touchPoint.y - targetY;
        self.touchPoint = CGPointMake(self.touchPoint.x, self.touchPoint.y - deltaY);
 
    }
}

@end
