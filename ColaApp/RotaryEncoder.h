//
//  RotaryEncoder.h
//  ColaApp
//
//  Created by Chris on 23/03/2015.
//  Copyright (c) 2015 Chris Rivers. All rights reserved.
//
#import <ColaLib/ColaLib.h>
#import <UIKit/UIKit.h>
#import "ModuleControl.h"

@class ControlDescription;
@interface RotaryEncoder : ModuleControl

@property (readonly, weak) COLContinuousParameter *parameter;
@property (nonatomic) double value;

-(instancetype)initWithContinuousParameter:(COLContinuousParameter*)parameter Description:(ControlDescription*)controlDescription;

@end
