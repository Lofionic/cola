//
//  RotarySwitch.h
//  ColaApp
//
//  Created by Chris on 01/04/2015.
//  Copyright (c) 2015 Chris Rivers. All rights reserved.
//
#import <ColaLib/ColaLib.h>
#import <UIKit/UIKit.h>
#import "ModuleControl.h"

@class ControlDescription;
@interface RotarySwitch : ModuleControl

@property (readonly, weak) COLDiscreteParameter *parameter;
@property (nonatomic) NSUInteger selectedIndex;

-(instancetype)initWithDiscreteParameter:(COLDiscreteParameter*)parameter Description:(ControlDescription*)controlDescription;

@end