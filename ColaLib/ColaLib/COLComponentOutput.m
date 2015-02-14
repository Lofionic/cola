//
//  COLComponentOutput.m
//  ColaLib
//
//  Created by Chris on 12/02/2015.
//  Copyright (c) 2015 Chris Rivers. All rights reserved.
//
#import "COLComponentOutput.h"
#import "COLComponent.h"

@interface COLComponentOutput ()

@property (nonatomic, weak) COLComponent<COLOutputDelegate> *outputDelegate;

@end

@implementation COLComponentOutput

-(instancetype)initWithComponent:(COLComponent *)component ofType:(kComponentIOType)type {
    
    if (self = [super initWithComponent:component ofType:type]) {
        if ([component conformsToProtocol:@protocol(COLOutputDelegate)]) {
            self.outputDelegate = component;
        } else {
            NSLog(@"Warning : Component for output does not conform to output protocol");
        }
    }
    
    return self;
}

-(void)renderBuffer:(AudioSignalType*)outA samples:(UInt32)numFrames {
     [self.component renderOutput:self toBuffer:outA samples:numFrames];
}
@end
