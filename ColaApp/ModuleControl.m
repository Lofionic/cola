//
//  ModuleControl.m
//  ColaApp
//
//  Created by Chris on 01/04/2015.
//  Copyright (c) 2015 Chris Rivers. All rights reserved.
//

#import "ModuleControl.h"
#import "RotarySwitch.h"
#import "RotaryEncoder.h"

@implementation ModuleControl

// Factory method for creating a control of the correct type
+(ModuleControl*)controlForParameter:(CCOLParameterAddress)parameter Description:(ControlDescription*)description ControlType:(ControlType)type
{
    ModuleControl *result = nil;
    
    switch (type) {
        case Continuous:
            result = [[RotaryEncoder alloc] initWithContinuousParameter:parameter Description:description];
            break;
        case Discrete:
            result = [[RotarySwitch alloc] initWithDiscreteParameter:parameter Description:description];
        default:
            break;
    }
 
    return result;
}


-(void)updateFromParameter {
    // Override to handle updating control value from parameter
}

@end
