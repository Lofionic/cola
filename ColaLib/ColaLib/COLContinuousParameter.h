//
//  COLComponentParamater.h
//  ColaLib
//
//  Created by Chris on 23/02/2015.
//  Copyright (c) 2015 Chris Rivers. All rights reserved.
//
#import "COLParameter.h"
#import <Foundation/Foundation.h>

typedef float (^parameterFunction)(float inValue);

@class COLComponent;

@interface COLContinuousParameter : COLParameter

@property (nonatomic, strong) parameterFunction function;

-(void)setNormalizedValue:(float)newValue;
-(float)getNormalizedValue;

-(float)outputAtDelta:(float)delta;

@end
