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
#import "COLComponentInput.h"
#import "COLComponentOutput.h"

@interface COLComponent ()

@property (nonatomic, weak) COLAudioContext     *context;
@property (nonatomic, strong) NSArray           *inputs;
@property (nonatomic, strong) NSArray           *outputs;

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

// Data source
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

// Render numFrames number of frames into the output buffers
-(void)renderOutputs:(UInt32)numFrames {
    self.hasRendered = YES;
}

// Called when engine render has completed
-(void)engineDidRender {
    self.hasRendered = NO;
    for (COLComponentInput *thisInput in self.inputs) {
        [thisInput engineDidRender];
    }
}

-(void)disconnectAll {
    for (COLComponentOutput* thisOutput in self.outputs) {
        [thisOutput disconnect];
    }
    
    for (COLComponentInput* thisInput in self.inputs) {
        [thisInput disconnect];
    }
}

-(void)dealloc {
    NSLog(@"%@ dealloc", self.name);
}

@end
