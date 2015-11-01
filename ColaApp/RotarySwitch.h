//
//  RotarySwitch.h
//  ColaApp
//
//  Created by Chris on 01/04/2015.
//  Copyright (c) 2015 Chris Rivers. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "ModuleControl.h"

@class ControlDescription;
@interface RotarySwitch : ModuleControl

@property (readonly) CCOLParameterAddress parameter;
@property (nonatomic) NSUInteger selectedIndex;

-(instancetype)initWithDiscreteParameter:(CCOLParameterAddress)parameter Description:(ControlDescription*)controlDescription;

@end