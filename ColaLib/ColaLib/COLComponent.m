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

@property (nonatomic, weak) COLAudioEnvironment *environment;
@property (nonatomic, strong) NSArray *inputs;
@property (nonatomic, strong) NSArray *outputs;

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

-(void)renderOutput:(COLComponentOutput *)output toBuffer:(AudioSignalType *)outA samples:(UInt32)numFrames {
    
}

-(void)setInputs:(NSArray *)inputs {
    _inputs = inputs;
}

-(void)setOutputs:(NSArray *)outputs {
    _outputs = outputs;
}

@end
