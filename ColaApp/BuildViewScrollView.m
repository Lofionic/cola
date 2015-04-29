//
//  BuildViewScrollView.m
//  ColaApp
//
//  Created by Chris on 22/04/2015.
//  Copyright (c) 2015 Chris Rivers. All rights reserved.
//

#import "BuildViewScrollView.h"

@interface BuildViewScrollView ()

@property (nonatomic, strong) NSTimer *scrollRestTimer;
@property CGPoint touchPoint;

@end

@implementation BuildViewScrollView

-(UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {

    // Nothing underneath this view should be hit
    UIView *hit = [super hitTest:point withEvent:event];
    if (!hit) {
        return self;
    } else {
        return hit;
    }
}

@end
