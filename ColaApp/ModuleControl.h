//
//  ModuleControl.h
//  ColaApp
//
//  Created by Chris on 01/04/2015.
//  Copyright (c) 2015 Chris Rivers. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <ColaLib/CCOLTypes.h>
#import "ModuleDescription.h"

typedef enum ControlType {
    Continuous,
    Discrete
} ControlType;

@interface ModuleControl : UIControl

+(ModuleControl*)controlForParameter:(CCOLParameterAddress)parameter Description:(ControlDescription*)description ControlType:(ControlType)type;
-(void)updateFromParameter;

@end
