//
//  COLComponent.m
//  ColaLib
//
//  Created by Chris on 12/02/2015.
//  Copyright (c) 2015 Chris Rivers. All rights reserved.
//
#import "COLAudioEnvironment.m"
#import "COLAudioEngine.H"
#import "COLComponent.h"

@interface COLComponent ()

@property (nonatomic, weak) COLAudioContext *context;
@property (nonatomic, strong) NSArray *inputs;
@property (nonatomic, strong) NSArray *outputs;
@property (nonatomic) BOOL hasRendered;

@end

@implementation COLComponent

-(instancetype)initWithContext:(COLAudioContext *)context {
    self = [super init];
    if (self) {
        self.context = context;
        [self initializeIO];
    }
    return self;
}

-(void)initializeIO {
    
}

-(NSInteger)numberOfOutputs {
    return [self.outputs count];
}

-(COLComponentOutput *)outputForIndex:(NSInteger)index {
    return [self.outputs objectAtIndex:index];
}

-(NSInteger)numberOfInputs {
    return [self.inputs count];
}

-(COLComponentInput *)inputForIndex:(NSInteger)index {
    return [self.inputs objectAtIndex:index];
}

-(void)renderInputs:(UInt32)numFrames {
    for (COLComponentInput *thisInput in self.inputs) {
        [thisInput renderComponents:numFrames];
    }
}

-(void)renderOutputs:(UInt32)numFrames {
    self.hasRendered = YES;
}

-(void)engineDidRender {
    self.hasRendered = NO;
    for (COLComponentInput *thisInput in self.inputs) {
        [thisInput engineDidRender];
    }
}


@end
