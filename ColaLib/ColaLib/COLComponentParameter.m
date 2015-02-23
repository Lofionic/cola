//
//  COLComponentParamater.m
//  ColaLib
//
//  Created by Chris on 23/02/2015.
//  Copyright (c) 2015 Chris Rivers. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "COLComponentParameter.h"

@interface COLComponentParameter() {
    float preValue;
    float postValue;
}

@end

@implementation COLComponentParameter

-(void)setTo:(float)newValue {
    if (newValue >= 0 && newValue <= 1) {
        postValue = newValue;
    }
}

-(void)engineDidRender {
    preValue = postValue;
}

-(float)valueAtDelta:(float)delta {
    
    return ((postValue - preValue) * delta) + preValue;
    
}

@end
