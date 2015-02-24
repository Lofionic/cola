//
//  COLComponentParamater.h
//  ColaLib
//
//  Created by Chris on 23/02/2015.
//  Copyright (c) 2015 Chris Rivers. All rights reserved.
//
#import <Foundation/Foundation.h>

typedef float (^parameterFunction)(float inValue);

@class COLComponent;

@interface COLComponentParameter : NSObject

@property (nonatomic, weak) COLComponent *component;
@property (nonatomic, strong) NSString *name;

@property (nonatomic, strong) parameterFunction function;

-(instancetype)initWithComponent:(COLComponent*)component withName:(NSString*)name;

-(void)setNormalizedValue:(float)newValue;
-(float)getNormalizedValue;

-(void)engineDidRender;
-(float)outputAtDelta:(float)delta;


@end
