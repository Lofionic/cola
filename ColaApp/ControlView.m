//
//  ModuleControl.m
//  ColaApp
//
//  Created by Chris on 01/04/2015.
//  Copyright (c) 2015 Chris Rivers. All rights reserved.
//

#import "ControlView.h"
#import "RotarySwitch.h"
#import "RotaryEncoder.h"

@interface ControlView()

@property (nonatomic) CCOLParameterAddress parameter;

@end

@implementation ControlView

// Factory method for creating a control of the correct type
+(ControlView*)controlForParameter:(CCOLParameterAddress)parameter Description:(ControlDescription*)description ControlType:(ControlType)type
{
    ControlView *result = nil;
    
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

- (instancetype)initWithParameter:(CCOLParameterAddress)parameter Description:(ControlDescription*)description {
    if (self = [super init]) {
        self.parameter = parameter;
    }
    return self;
}


-(void)updateFromParameter {
    // Override to handle updating control value from parameter
}

-(NSObject*)getDictionaryObject {
    // Override to return an NSObject for the current setting
    return nil;
}

-(void)setFromDictionaryObject:(NSObject *)object{
    // Set value from NSObject
}

@end
