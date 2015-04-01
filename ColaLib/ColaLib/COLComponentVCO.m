//
//  SinWaveComponent.m
//  ColaLib
//
//  Created by Chris on 12/02/2015.
//  Copyright (c) 2015 Chris Rivers. All rights reserved.
//
#import "COLContinuousParameter.h"
#import "COLDiscreteParameter.h"
#import "COLComponentVCO.h"
#import "COLAudioEnvironment.h"
#import "COLComponentInput.h"
#import "COLKeyboardComponent.h"

#define CV_FREQUENCY_RANGE 8372

@interface COLComponentVCO () {
    Float64 phase;
}

@property (nonatomic, strong) COLComponentInput     *keyboardIn;
@property (nonatomic, strong) COLComponentInput     *fmodIn;

@property (nonatomic, strong) COLComponentOutput    *out;

@property (nonatomic, strong) COLDiscreteParameter      *range;
@property (nonatomic, strong) COLDiscreteParameter      *waveform;
@property (nonatomic, strong) COLContinuousParameter    *tune;
@property (nonatomic, strong) COLContinuousParameter    *fmAmt;

@end

@implementation COLComponentVCO

-(instancetype)initWithContext:(COLAudioContext *)context {
    if (self = [super initWithContext:context]) {

    }
    return self;
}

-(void)initializeIO {
    // Inputs
    self.keyboardIn = [[COLComponentInput alloc] initWithComponent:self ofType:kComponentIOType1VOct withName:@"Keyboard In"];
    self.fmodIn = [[COLComponentInput alloc] initWithComponent:self ofType:kComponentIOTypeControl withName:@"FM In"];
    [self setInputs:@[self.keyboardIn, self.fmodIn]];
    
    // Outputs
    self.out = [[COLComponentOutput alloc] initWithComponent:self ofType:kComponentIOTypeAudio withName:@"Out"];
    [self setOutputs:@[self.out]];
    
    // Parameters
    self.range = [[COLDiscreteParameter alloc] initWithComponent:self withName:@"Range" max:4];
    [self.range setSelectedIndex:0];
    self.waveform = [[COLDiscreteParameter alloc] initWithComponent:self withName:@"Waveform" max:5];
    [self.waveform setSelectedIndex:0];
    self.tune = [[COLContinuousParameter alloc] initWithComponent:self withName:@"Tune"];
    [self.tune setNormalizedValue:0.5];
    self.fmAmt = [[COLContinuousParameter alloc] initWithComponent:self withName:@"FM Amt"];
    [self.fmAmt setNormalizedValue:0.5];
    [self setParameters:@[self.range, self.waveform, self.tune, self.fmAmt]];
}

-(void)renderOutputs:(UInt32)numFrames {

    [super renderOutputs:numFrames];

    // Input Buffers
    AudioSignalType *fmBuffer = [self.fmodIn getBuffer:numFrames];
    
    // Keyboard Buffer
    AudioSignalType *kbBuffer = [self.keyboardIn getBuffer:numFrames];

    // Output Buffers
    AudioSignalType *outBuffer = [self.out prepareBufferOfSize:numFrames];

    Float64 sampleRate = [[COLAudioEnvironment sharedEnvironment] sampleRate];
    
    for (int i = 0; i < numFrames; i++) {
        AudioSignalType freq = FLT_MIN;
        
        if ([self.keyboardIn isConnected]) {
            freq = kbBuffer[i];
        }
        
        if ([self.fmodIn isConnected]) {
            float delta = i / (float)numFrames;
            float lfoValue = powf(0.5, (-fmBuffer[i] * [self.fmAmt outputAtDelta:delta]));
            freq *= lfoValue;
        }
        
        phase += (M_PI * freq * CV_FREQUENCY_RANGE) / sampleRate;
        
        outBuffer[i] = sin(phase);;
    }
    
    
    if (phase > 2.0 * M_PI) {
        phase -= (2.0 * M_PI);
    }
}

@end
