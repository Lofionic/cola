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
+(ModuleControl*)controlForParameter:(COLParameter*)parameter Description:(ControlDescription*)description {
    
    ModuleControl *result = nil;
    
    if ([parameter isKindOfClass:[COLContinuousParameter class]]) {
        result = [[RotaryEncoder alloc] initWithContinuousParameter:(COLContinuousParameter*)parameter Description:description];
    } else if ([parameter isKindOfClass:[COLDiscreteParameter class]]) {
        result = [[RotarySwitch alloc] initWithDiscreteParameter:(COLDiscreteParameter*)parameter Description:description];
    }
 
    return result;
}


-(void)updateFromParameter {
    // Override to handle updating control value from parameter
}

@end
