//
//  COLComponentMixer2.m
//  ColaLib
//
//  Created by Chris on 06/04/2015.
//  Copyright (c) 2015 Chris Rivers. All rights reserved.
//

#import "COLComponentMixer2.h"
#import "COLContinuousParameter.h"

@interface COLComponentMixer2 ()

@property (nonatomic, strong) COLContinuousParameter *level1;
@property (nonatomic, strong) COLContinuousParameter *level2;

@property (nonatomic, strong) COLComponentInput *input1;
@property (nonatomic, strong) COLComponentInput *input2;

@property (nonatomic, strong) COLComponentOutput *output;

@end

@implementation COLComponentMixer2

-(void)initializeIO {
    self.level1 = [[COLContinuousParameter alloc] initWithComponent:self withName:@"Level 1"];
    self.level2 = [[COLContinuousParameter alloc] initWithComponent:self withName:@"Level 2"];
    [self.level2 setNormalizedValue:0.5];
    [self.level1 setNormalizedValue:0.5];
    [self setParameters:@[self.level1, self.level2]];
    
    self.input1 = [[COLComponentInput alloc] initWithComponent:self ofType:kComponentIOTypeAudio withName:@"In 1"];
    self.input2 = [[COLComponentInput alloc] initWithComponent:self ofType:kComponentIOTypeAudio withName:@"In 2"];
    [self setInputs:@[self.input1, self.input2]];
    
    self.output = [[COLComponentOutput alloc] initWithComponent:self ofType:kComponentIOTypeAudio withName:@"Output"];
    [self setOutputs:@[self.output]];
}

-(void)renderOutputs:(UInt32)numFrames {
    
    [super renderOutputs:numFrames];
    
    AudioSignalType *outputBuffer = [self.output prepareBufferOfSize:numFrames];
    
    AudioSignalType *input1Buffer = [self.input1 getBuffer:numFrames];
    AudioSignalType *input2Buffer = [self.input2 getBuffer:numFrames];
    
    for (int i = 0; i < numFrames; i++) {
        
        float delta = (float)i / numFrames;
        float input1Gain = [self.level1 outputAtDelta:delta];
        float input2Gain = [self.level2 outputAtDelta:delta];
        
        outputBuffer[i] = tanhf(((input1Buffer[i] * input1Gain) + (input2Buffer[i] * input2Gain)) * 4.0);
    }
}


@end
