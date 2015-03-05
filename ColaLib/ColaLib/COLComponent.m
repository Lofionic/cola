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

@property (nonatomic, weak) COLAudioContext *context;
@property (nonatomic, strong) NSArray *inputs;
@property (nonatomic, strong) NSArray *outputs;
@property (nonatomic, strong) NSArray *parameters;
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
-(NSUInteger)numberOfOutputs {
    return [self.outputs count];
}

-(COLComponentOutput *)outputForIndex:(NSUInteger)index {
    if (index < [self.outputs count]) {
        return [self.outputs objectAtIndex:index];
    } else {
        return nil;
    }
}

-(NSUInteger)numberOfInputs {
    return [self.inputs count];
}

-(COLComponentInput *)inputForIndex:(NSUInteger)index {
    if (index < [self.inputs count]) {
        return [self.inputs objectAtIndex:index];
    } else {
        return nil;
    }
}

-(NSUInteger)numberOfParameters {
    return [self.parameters count];
}

-(COLComponentParameter*)parameterForIndex:(NSUInteger)index {
    if (index < [self.parameters count]) {
        return [self.parameters objectAtIndex:index];
    } else {
        NSLog(@"Warning: Invalid parameter index %lu for component %@", (unsigned long)index, self.name);
        return nil;
    }
}

-(void)renderOutputs:(UInt32)numFrames {
    self.hasRendered = YES;
}

// Called when engine render has completed
-(void)engineDidRender {
    self.hasRendered = NO;
    for (COLComponentInput *thisInput in self.inputs) {
        [thisInput engineDidRender];
    }
    
    for (COLComponentParameter *thisParameter in self.parameters) {
        [thisParameter engineDidRender];
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

-(void)parameterDidChange:(COLComponentParameter *)parameter {
    
}

-(void)dealloc {
    NSLog(@"%@ dealloc", self.name);
}

@end
