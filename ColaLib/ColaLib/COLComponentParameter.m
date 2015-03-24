//
//  COLComponentParamater.m
//  ColaLib
//
//  Created by Chris on 23/02/2015.
//  Copyright (c) 2015 Chris Rivers. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "COLComponent.h"
#import "COLComponentParameter.h"

@interface COLComponentParameter() {
    float normalizedValue;
    
    float preValue;
    float postValue;
    float pendingValue;
    
    float cacheIn;
    float cacheOut;
}

@end

@implementation COLComponentParameter

-(instancetype)initWithComponent:(COLComponent*)component withName:(NSString*)name {
    if (self = [super init]) {
        self.component = component;
        self.name = name;
        
        preValue = 0;
        postValue = 0;
        pendingValue = 0;
    }
    return self;
}

-(void)setNormalizedValue:(float)newValue {
    if (newValue >= 0 && newValue <= 1) {
        pendingValue = newValue;
        [self.component parameterDidChange:self];
    }
}

-(void)engineDidRender {
    preValue = postValue;
    postValue = pendingValue;
}

-(float)outputAtDelta:(float)delta {
    float f = ((postValue - preValue) * delta) + preValue;
    
    if (f == cacheIn) {
        return cacheOut;
    } else {
        cacheIn = f;
        if (self.function) {
            f = self.function(f);
        }
        cacheOut = f;
        return f;
    }
}

-(float)getNormalizedValue {
    return pendingValue;
}

@end
