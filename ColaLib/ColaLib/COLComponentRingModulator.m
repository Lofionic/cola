//
//  COLComponentRingModulator.m
//  ColaLib
//
//  Created by Chris on 27/04/2015.
//  Copyright (c) 2015 Chris Rivers. All rights reserved.
//

#import "COLComponentRingModulator.h"
#import "COLContinuousParameter.h"

@interface COLComponentRingModulator ()

@property (nonatomic, strong) COLComponentInput *input1;
@property (nonatomic, strong) COLComponentInput *input2;

@property (nonatomic, strong) COLComponentOutput *output;

@property (nonatomic, strong) COLContinuousParameter *mix;

@end

@implementation COLComponentRingModulator

-(void)initializeIO {
    self.input1 = [[COLComponentInput alloc] initWithComponent:self ofType:kComponentIOTypeAudio withName:@"In 1"];
    self.input2 = [[COLComponentInput alloc] initWithComponent:self ofType:kComponentIOTypeAudio withName:@"In 2"];
    self.inputs = @[self.input1, self.input2];
    
    self.output = [[COLComponentOutput alloc] initWithComponent:self ofType:kComponentIOTypeAudio withName:@"Out"];
    self.outputs = @[self.output];
    
    self.mix = [[COLContinuousParameter alloc] initWithComponent:self withName:@"Mix"];
    self.parameters = @[self.mix];
}

-(void)renderOutputs:(UInt32)numFrames {
    [super renderOutputs:numFrames];
    
    AudioSignalType *outputBuffer = [self.output prepareBufferOfSize:numFrames];
    AudioSignalType *input1Buffer = [self.input1 getBuffer:numFrames];
    AudioSignalType *input2Buffer = [self.input2 getBuffer:numFrames];
    
    for (int i = 0; i <numFrames; i++) {
        
        outputBuffer[i] = input1Buffer[i] * input2Buffer[i];

    }
}

@end
