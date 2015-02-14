//
//  COLComponent.m
//  ColaLib
//
//  Created by Chris on 12/02/2015.
//  Copyright (c) 2015 Chris Rivers. All rights reserved.
//
#import "COLAudioEnvironment.m"
#import "COLAudioEngine.m"
#import "COLComponent.h"

@interface COLComponent ()

@end

@implementation COLComponent

-(instancetype)initWithEnvironment:(COLAudioEnvironment*)environment {
    self = [super init];
    if (self) {
        self.environment = environment;
        [self initializeIO];
    }
    return self;
}

-(void)initializeIO {
    
}

-(NSInteger)numberOfOutputs {
    return 0;
}

-(COLComponentOutput *)outputForIndex:(NSInteger)index {
    return nil;
}

-(NSInteger)numberOfInputs {
    return 0;
}

-(COLComponentInput *)inputForIndex:(NSInteger)index {
    return nil;
}

-(void)renderOutput:(COLComponentOutput *)output toBuffer:(AudioSignalType *)outA samples:(UInt32)numFrames {
    
}


@end
